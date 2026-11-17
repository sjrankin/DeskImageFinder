//
//  VisionSimilarity.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/22/25.
//

import Foundation
import Vision
import AppKit
import Combine

class VisionSimilarity: SimilarityEngineProtocol
{
    /// Find similar images using the `Vision` framework similarity functionality.
    /// - Parameter With: The model (see `DataModel`) with parameters for determining which files to examine, where, and
    /// how to determine how similar the test images are.
    /// - SeeAlso: https://medium.com/@kamil.tustanowski/comparing-images-using-the-vision-framework-ff13291901ff
    static func FindSimilarImages(With Parameters: DataModel)
    {
        /*
        guard let SourceURL = Parameters.Source else
        {
            return
        }
        guard let Source = Utilities.GetImage(From: SourceURL) else
        {
            return
        }
        guard let source = FeatureProcess(Source) else
        {
            return
        }
        var features = [VNFeaturePrintObservation]()
        Parameters.Results.removeAll()
         */
    }
    
    /// Return the delta distance between two images.
    /// - Parameter Reference: The reference image. Presumed to the the image being searched for.
    /// - Parameter Test: The image to test against the `Reference` image.
    /// - Parameter Parameter: Data model for comparing images.
    /// - Returns: Result comparison between the two images on success, `nil` on error.
    static func GetImageDelta(Reference: NSImage, Test: NSImage, Parameter: DataModel) async -> ComparisonResult?
    {
        Parameter.Results.removeAll()
        let result = await VisionSimilarity(To: Reference, InSet: [Test])
        if let result = result
        {
            if !result.isEmpty
            {
                return result.first
            }
        }
        return nil
    }
    
    /// Preprocesses the passed image. This function will create a feature print observation of a single image that can be reused
    /// in other parts of the code without having to regenerate the observation.
    /// - Parameter Image: The image to preprocess.
    /// - Returns: A feature print observation on success, nil on error.
    static func Preprocess(_ Image: NSImage) async -> VNFeaturePrintObservation?
    {
        return await FeatureProcess(Image)
    }
    
    /// Compare a pre-processed image against the image in the passed URL to determine how far away the two
    /// images are in how they look.
    /// - Parameter Preprocessed: The source image preprocessed in `Preprocess`.
    /// - Parameter CompareToURL: The URL of the image to compare against `Preprocessed`.
    /// - Returns: A comparison result on success, nil on error.
    static func Similarity(Preprocessed: VNFeaturePrintObservation,
                           CompareToURL: URL) async -> SimilarityResult?
    {
        //if let LookAt = await Utilities.GetImage(From: CompareToURL)
        if let LookAtCG = await Utilities.GetCGImage(From: CompareToURL)
        {
            let LookAt = NSImage(cgImage: LookAtCG,
                                 size: NSSize(width: LookAtCG.width, height: LookAtCG.height))
            if let Comparison = await Similarity(Preprocessed: Preprocessed, CompareTo: LookAt)
            {
                let ResultNode = SimilarityResult(Path: CompareToURL,
                                                  Score: Comparison.Distance,
                                                  TargetImage: LookAt,
                                                  Tag: "")
                return ResultNode
            }
        }
        return nil
    }
    
    /// Compare a pre-processed image against a raw image in `CompareTo` to determine how far away the two
    /// images are in how they look.
    /// - Parameter Preprocessed: The source image preprocessed in `Preprocess`.
    /// - Parameter CompareTo: The image to compared against `Preprocessed`.
    /// - Returns: A comparison result on success, nil on error.
    static func Similarity(Preprocessed: VNFeaturePrintObservation,
                                 CompareTo: NSImage) async -> ComparisonResult?
    {
        var features = [VNFeaturePrintObservation]()
        if let testdata = await FeatureProcess(CompareTo)
        {
            features.append(testdata)
            var ftemp: Float = .infinity
            do
            {
                try Preprocessed.computeDistance(&ftemp, to: testdata)
            }
            catch
            {
                print("Error: \(error)")
                return nil
            }
            return ComparisonResult(Distance: ftemp, Original: CompareTo)
        }
        return nil
    }
    
    /// Run the Vision-based similarity engine.
    /// - SeeAlso: https://medium.com/@kamil.tustanowski/comparing-images-using-the-vision-framework-ff13291901ff
    /// - Parameter To: The source image compared against all other images in `InSet`.
    /// - Parameter InSet: The set of images measured against the image in `To`.
    /// - Returns: Array of comparison results.
    static func VisionSimilarity(To Source: NSImage,
                                 InSet LookIn: [NSImage]) async -> [ComparisonResult]?
    {
        guard let source = await FeatureProcess(Source) else
        {
            print("Error processing source image.")
            return nil
        }
        var features = [VNFeaturePrintObservation]()
        var results = [ComparisonResult]()
        for LookAt in LookIn
        {
            if let ImageData = await FeatureProcess(LookAt)
            {
                features.append(ImageData)
                var ftemp: Float = .infinity
                var addresult = true
                do
                {
                    try source.computeDistance(&ftemp, to: ImageData)
                }
                catch
                {
                    addresult = false
                    print("Error: \(error)")
                }
                if addresult
                {
                    results.append(ComparisonResult(Distance: ftemp, Original: LookAt))
                }
            }
        }
        results.sort { $0.Distance < $1.Distance }
        return results
    }
    
    /// Process the passed image to return a feature print observation.
    /// - Parameter image: The image to process.
    /// - Returns: A VNFeaturePrintObservation on success, nil on failure.
    static func FeatureProcess(_ image: NSImage) async -> VNFeaturePrintObservation?
    {
        let cgImage = image.cgImage(forProposedRect: nil,
                                    context: nil,
                                    hints: nil)
        guard let cgImage = cgImage else
        {
            return nil
        }
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage,
                                            orientation: .up,
                                            options: [:])
        do
        {
            try handler.perform([request])
        }
        catch
        {
            print("Feature process error: \(error)")
        }
        guard let result = request.results?.first as? VNFeaturePrintObservation else
        {
            return nil
        }
        return result
    }
}
