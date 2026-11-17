//
//  Utilities.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import Foundation
import AppKit
import CoreImage

/// Miscellaneous utility functions.
@MainActor class Utilities
{
    /// Returns a `CGImage` from the passed URL.
    /// - Parameter From: The URL to use to load the image.
    /// - Returns: A `CGImage` from the passed URL on success, `nil` on error.
    static func GetCGImage(From: URL) -> CGImage?
    {
        guard let CImage = CGImageSourceCreateWithURL(From as CFURL, nil) else
        {
            return nil
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(CImage, 0, nil) else
        {
            return nil
        }
        return cgImage
    }
    
    /// Return an array of similarity results based on `From`. Just before returning, this function will create
    /// a new search session.
    /// - Parameter From: Array of image URLs on the local file system.
    /// - Parameter With: Determines how to search/compare.
    /// - Parameter DoCompare: Determines if a given image specified by an URL in `From` should
    /// be compared against `Reference`.
    /// - Parameter Reference: The reference image (image to be compared to all others). Considered
    /// the source image.
    /// - Parameter Status: Status reporting model.
    /// - Parameter Search: Search controller.
    /// - Returns: Array of similarity results.
    static func LoadImages(From: [URL],
                           With Model: DataModel,
                           DoCompare: Bool = false,
                           Reference: NSImage? = nil,
                           Status: ProcessStatusModel,
                           Search: SessionsModel) async -> [SimilarityResult]
    {
        Model.UnsearchedDirectoryCount = From.count
        var results = [SimilarityResult]()
        for SomeURL in From
        {
            Model.UnsearchedDirectoryCount -= 1
            let num = From.count - Model.UnsearchedDirectoryCount
            Model.DirectoriesCompletedPercent = Double(num) / Double(From.count)
            Status.DirectorySearchedPercent = Model.DirectoriesCompletedPercent
            results.append(contentsOf: await SearchForSimilarImages(In: SomeURL,
                                                                    With: Model,
                                                                    DoCompare: DoCompare,
                                                                    Reference: Reference,
                                                                    Status: Status))
        }
        //Search.DuplicateCurrentSession()
        return results
    }
    
    /// Create an array of `NSImage`s from the contents of the specified directory and settings in `Model`. This function will
    /// potentially process the image to match the requirements of `With`.
    /// - Note: Given the potentially long amount of time to read image data and create images, this is an `async` function.
    /// - Parameter In: The URL of the directory that contains the images to process.
    /// - Parameter With: The `DataModel` with settings to potentially filter which images to add.
    /// - Parameter DoCompare: If true, compare the loaded image with the reference image.
    /// - Parameter Reference: The reference image to use if `DoCompare` is true.
    /// - Parameter Status: Object that stores and publishes the current processing status.
    /// - Returns: Array of potentially processed images encapsulated in a `Result` object.
    static func SearchForSimilarImages(In Directory: URL,
                                       With Model: DataModel,
                                       DoCompare: Bool = false,
                                       Reference: NSImage? = nil,
                                       Status: ProcessStatusModel) async -> [SimilarityResult]
    {
        guard var Reference = Reference else
        {
            return []
        }
        let ExtList = MakeExtensionArray(JPG: Model.SearchJPG, PNG: Model.SearchPNG,
                                         GIF: Model.SearchGIF, TIFF: Model.SearchTIFF,
                                         WEBP: Model.SearchWEBP, HEIC: Model.SearchHEIC)
        let URLList = Files.GetFilesMatching(Extensions: ExtList, In: Directory)
        var Results = [SimilarityResult]()
        Status.Current = 0
        Status.Total = URLList.count
        Status.Processing = true
        Status.StatusType = .Searching
        let SourceSize = NSSize(width: Reference.size.width, height: Reference.size.height)
        if Model.IgnoreColor
        {
            if let source = Reference.grayscale()
            {
                Reference = source
            }
            else
            {
                return []
            }
        }
        for SomeURL in URLList
        {
            if let SomeImage = NSImage(contentsOfFile: SomeURL.path)
            {
                if Model.ExcludeBigImage
                {
                    let TestSize = NSSize(width: SomeImage.size.width, height: SomeImage.size.height)
                    if TestSize.width > Model.DimensionTooBig || TestSize.height > Model.DimensionTooBig
                    {
                        continue
                    }
                }
                if Model.MustMatchSourceSize
                {
                    let TestSize = NSSize(width: SomeImage.size.width, height: SomeImage.size.height)
                    if TestSize != SourceSize
                    {
                        continue
                    }
                }
                var TestImage = SomeImage
                if Model.IgnoreColor
                {
                    if let grayed = SomeImage.grayscale()
                    {
                        TestImage = grayed
                    }
                    else
                    {
                        continue
                    }
                }
                Status.Current += 1
                /*
                 if Status.Current >= Model.SearchQuantity
                 {
                 print("Reached total requested search count: \(Status.Current) >= \(Model.SearchQuantity)")
                 break
                 }
                 if Status.ExactCount == Model.ExactCount
                 {
                 print("Reached exact search count: \(Status.ExactCount) == \(Model.ExactCount)")
                 break
                 }
                 */
                Status.RawURL = SomeURL
                Status.FileName = Files.NameFrom(SomeURL)
                if let result = await SimilarityEngine.Run(Engine: .Vision,
                                                           Reference: Reference,
                                                           Against: TestImage,
                                                           With: Model)
                {
                    let ResultNode = SimilarityResult(Path: SomeURL,
                                                      Score: result.Distance,
                                                      TargetImage: SomeImage,
                                                      Tag: "")
                    Results.append(ResultNode)
                    Model.SearchCount += 1
                    
                    if ResultNode.Score <= Model.ExactValue
                    {
                        Model.ExactCount += 1
                        if let sanitized = Files.SanitizeDirectory(SomeURL)
                        {
                            Model.ExactDirectories.insert(sanitized)
                        }
                    }
                    else
                    {
                        if ResultNode.Score <= Model.SimilarValue
                        {
                            Model.SimilarCount += 1
                            if let sanitized = Files.SanitizeDirectory(SomeURL)
                            {
                                Model.SimilarDirectories.insert(sanitized)
                            }
                        }
                    }
                }
            }
        }
        Status.Processing = false
        Status.ExactCount = Model.ExactCount
        Status.SimilarCount = Model.SimilarCount
        Status.StatusType = .Results
        return Results.sorted { $0.Score < $1.Score }
    }
    
    /// Process a given image as per the settings from the user. This may include converting the image to grayscale and/or
    /// resizing the image. Converting to grayscale affects only comparison and will avoid color-based differences. Resizing images
    /// to the same size and potentially smaller, may decrease processing time.
    /// - Parameter TestImage: The image to process.
    /// - Parameter With: The `DataModel` with user-set settings.
    /// - Returns: Processed image. If nil, no processing was done, or an error occurred.
    static func ProcessForComparison(_ TestImage: NSImage, With Model: DataModel) -> NSImage?
    {
        var DidProcess = false
        var Processed = TestImage
        if Model.IgnoreColor
        {
            if let cgImage = TestImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            {
                let ciImage = CIImage(cgImage: cgImage)
                if let filter = CIFilter(name: "CIPhotoEffectMono")
                {
                    filter.setValue(ciImage, forKey: kCIInputImageKey)
                    let context = CIContext()
                    if let output = filter.outputImage
                    {
                        if let nextImage = context.createCGImage(output, from: output.extent)
                        {
                            Processed = NSImage(cgImage: nextImage, size: TestImage.size)
                            DidProcess = true
                        }
                    }
                }
            }
        }
        if let NewSize = Model.UseSize
        {
            Processed = ResizeImage(Processed, to: NewSize)
            DidProcess = true
        }
        if DidProcess
        {
            return Processed
        }
        return nil
    }
    
    /// Resize an NSImage.
    /// - Parameter image: The image used to create a new image with the specified size. The passed source image
    /// remains untouched.
    /// - Parameter to: New image size.
    /// - Returns: New NSImage in the new size.
    static func ResizeImage(_ image: NSImage, to size: NSSize) -> NSImage
    {
        let Resized = NSImage(size: size)
        Resized.lockFocus()
        image.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
        Resized.unlockFocus()
        return Resized
    }
    
    /// Create an array of extension names based on the image types.
    /// - Parameters
    ///     - **JPG**: Determines if "jpg" and "jpeg" are in the returned array.
    ///     - **PNG**: Determines if "png" is in the returned array.
    ///     - **GIF**: Determines if "gif" is in the returned array.
    ///     - **TIFF**: Determines if "tif" and "tiff" are in the returned array.
    ///     - **WEBP**: Determines if "webp" is in the returned array.
    ///     - **HEIC**: Determines if "heif" is in the returned array.
    ///  - Returns: Array of extension names.
    static func MakeExtensionArray(JPG: Bool, PNG: Bool, GIF: Bool = false,
                                   TIFF: Bool = false, WEBP: Bool = false,
                                   HEIC: Bool = false) -> [String]
    {
        var Exts = [String]()
        if JPG
        {
            Exts.append("jpg")
            Exts.append("jpeg")
        }
        if PNG
        {
            Exts.append("png")
        }
        if GIF
        {
            Exts.append("gif")
        }
        if TIFF
        {
            Exts.append("tiff")
            Exts.append("Tif")
        }
        if WEBP
        {
            Exts.append("webp")
        }
        if HEIC
        {
            Exts.append("heic")
        }
        return Exts
    }
    
    /// Parse a user-entered dimensional size for image comparison.
    /// - Note: This function expects the size to be in the format of `wxh` or `w,h`.
    /// - Parameter From: The string to parse.
    /// - Returns: `CGSize` containing the user's new size. On error, `100x100` is returned.
    static func GetDimensions(From: String) -> CGSize
    {
        if From.isEmpty
        {
            return CGSize(width: 100, height: 100)
        }
        let xparts = From.components(separatedBy: "x")
        let commaparts = From.components(separatedBy: ",")
        if xparts.count == 1 && commaparts.count == 1
        {
            // No commas or "x" found in the string.
            return CGSize(width: 100, height: 100)
        }
        // For the rest of the code here, only the first two components are used.
        if commaparts.count > 1
        {
            let w = Double(commaparts[0]) ?? 100
            let h = Double(commaparts[1]) ?? 100
            return CGSize(width: w, height: h)
        }
        if xparts.count > 1
        {
            let w = Double(xparts[0]) ?? 100
            let h = Double(xparts[1]) ?? 100
            return CGSize(width: w, height: h)
        }
        return CGSize(width: 100, height: 100)
    }
}
