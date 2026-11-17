//
//  Searcher.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import Foundation
import AppKit
import Vision

class Searcher
{
    public static func FindSimilarImages(To Source: NSImage,
                                         InSet LookIn: [NSImage],
                                         With Method: SimularityMethods = .Vision) -> [ComparisonResult]?
    {
        if LookIn.isEmpty
        {
            return nil
        }
        
        switch Method
        {
            case .Histogram:
                break
                //return HistogramSimularity(To: Source, InSet: LookIn)
                
            case .Vision:
                return VisionSimularity(To: Source, InSet: LookIn)
                
            case .PHash:
                break
                //return PHashSimularity(To: Source, InSet: LookIn)
        }
        return nil
    }
    
    static func HistogramSimularity(To Source: NSImage,
                                    InSet LookIn: [NSImage]) -> [NSImage]?
    {
        return nil
    }
    
    //https://medium.com/@kamil.tustanowski/comparing-images-using-the-vision-framework-ff13291901ff
    static func VisionSimularity(To Source: NSImage,
                                 InSet LookIn: [NSImage]) -> [ComparisonResult]?
    {
        guard let source = FeatureProcess(Source) else
        {
            print("Error processing source image.")
            return nil
        }
        var features = [VNFeaturePrintObservation]()
        var results = [ComparisonResult]()
        for LookAt in LookIn
        {
            if let featuredata = FeatureProcess(LookAt)
            {
                features.append(featuredata)
                var ftemp: Float = .infinity
                var addresult = true
                do
                {
                    try source.computeDistance(&ftemp, to: featuredata)
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
    
    static func FeatureProcess(_ image: NSImage) -> VNFeaturePrintObservation?
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
    
    static func PHashSimularity(To Source: NSImage,
                                InSet LookIn: [NSImage]) -> [NSImage]?
    {
        /*
         if let SourceHash = SwiftImageHash.phash(image: Source)
         {
         print("Source image hash: \(SourceHash)")
         for Target in LookIn
         {
         if let hash = SwiftImageHash.phash(image: Target)
         {
         print(" Target: \(hash)")
         }
         }
         }
         return nil
         */
        return nil
    }
}

enum SimularityMethods: Int
{
    case Histogram = 0
    case Vision = 1
    case PHash = 2
}

struct ComparisonResult: Identifiable, Hashable, Equatable
{
    let id = UUID()
    let Distance: Float
    let Original: NSImage
}

