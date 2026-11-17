//
//  PHash.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/7/25.
//

import Foundation
import AppKit
import CoreGraphics
import CoreImage.CIFilter
import Accelerate

/// Implements a perceptual hashing class for comparing images against each other.
/// - Note: Most functions are `async`.
/// - Note: The algorithm is: 1) Convert the source image to grayscale. 2) Reduce the size of the image
/// (defaulting to 16x16). 3) Calculate the mean pixel value of the reduced image. 4) Compare each pixel
/// in the reduced image to the mean value. 5) Using the results of the mean pixel comparison to generate
/// a hash value.
class PHash
{
    init()
    {
    }
    
    func Compute2(_ Image: NSImage) async -> Double?
    {
        let Reduced = await ResizeImage(Image, To: CGSize(width: 16, height: 16))
        var pixels = [UInt](repeating: 0,
                            count: Int(Reduced.size.width * Reduced.size.height))
        guard let context = CGContext(data: &pixels, width: Int(Reduced.size.width),
                                height: Int(Reduced.size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(Reduced.size.width),
        space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) else
        {
            print("Error creating context")
            return nil
        }
        guard let cgImage = Reduced.cgImage else
        {
            print("Error creating cgimage")
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0,
                                         width: Reduced.size.width,
                                         height: Reduced.size.height))
        var floatpixels = pixels.map{Float($0)}
        var DCTresult = [Float](repeating: 0,
                                count: Int(Reduced.size.width * Reduced.size.height) * 1)
        let DCTLength = vDSP_Length(16 * 16 * 1)
        print("DCTLength=\(DCTLength)")
        guard let setup = vDSP_DCT_CreateSetup(nil, DCTLength, .II) else
        {
            print("Error creating dct setup")
            return nil
        }
        vDSP_DCT_Execute(setup, &floatpixels, &DCTresult)
        
        var DCTLowFreq = [Float]()
        for y in 0 ..< 16
        {
            for x in 0 ..< 16
            {
                DCTLowFreq.append(DCTresult[y * Int(Reduced.size.width) + x])
            }
        }
        print("\(DCTLowFreq)")
        let DCTMean = DCTLowFreq.mean
        let normalized = NormalizeDCTArray(DCTLowFreq, with: DCTMean)
        print("\(normalized)")
        let final = normalized.enumerated().reduce(0)
        {
            (result, element) in
            let (index, digit) = element
            if digit == 0
            {
                return result + (1 << index)
            }
            else
            {
                return result
            }
        }
        print("Final = \(final)")
        return Double(final)
    }
    
    /// Convert the passed array (assumed but not required to be from a DCT) into a normalized `[Int]` array
    /// where if a value in the source array is greater than `with`, the returned array will have a `1`. Else,
    /// the value will be `0`.
    /// - Parameter array: `[Float]` to normalized.
    /// - Parameter with: The mean value that determines the contents of the returned `[Int]`.
    /// - Returns: Normalized array (of same count) based on `array`.
    func NormalizeDCTArray(_ array: [Float], with mean: Float) -> [Int]
    {
        return array.map {$0 > mean ? 1 : 0}
    }
    
    /// Stored bitmap image representation of the reduced image to reduce the number of times
    /// it has to be calculated.
    var ImageRep: NSBitmapImageRep? = nil
    
    /// Convert an `NSImage` to `NSBitmapImageRep`.
    /// - Parameter Image: The `NSImage` to convert.
    /// - Returns: An `NSBitmapImageRep` on success, `nil` on error.
    func MakeRepresentation(_ Image: NSImage) -> NSBitmapImageRep?
    {
        guard let tiff = Image.tiffRepresentation else
        {
            print("MakeRepresentation: Error getting tiff information.")
            return nil
        }
        return NSBitmapImageRep(data: tiff)
    }
    
    /// Compute the perceptual hash value of the passed image. Async function.
    /// - Parameter Image: The image whose phash value will be returned.
    /// - Parameter Reduction: Size to use in the image reduction step. Defaults to 16x16 pixels.
    /// - Returns: The phash value on success, `nil` on failure.
    func Compute(_ Image: NSImage,
                 Reduction: CGSize = CGSize(width: 16, height: 16)) async -> Double?
    {
        guard let Gray = Image.grayscale() else
        {
            print("PHash: Error converting to grayscale")
            return nil
        }
        let Reduced = await ResizeImage(Gray, To: Reduction)
        guard let Mean = await MeanPixel(Reduced) else
        {
            print("PHash: Error calculating mean pixel")
            return nil
        }
        guard let Deltas = await PixelDelta(From: Mean, In: ImageRep) else
        {
            print("PHash: Error calculating pixel deltas")
            return nil
        }
        let Hash = await GenerateHash(From: Deltas)
        return Hash
    }
    
    /// Given the set of values from the mean to pixel comparisons, generate a single hash value. Async function.
    /// - Parameter From: Array of `Int`s indicating whether the pixel value at a given image location is greater (`1`)
    /// than the mean or less (`0`) than the mean.
    /// - Returns: Hash value calculated from the passed data in `From`.
    func GenerateHash(From: [Int]) async -> Double
    {
        var Hash: Double = 0
        for index in 0 ..< From.count
        {
            Hash += Double(pow(2.0, Double(From[index])))
        }
        return Hash
    }
    
    /// Get the delta of each pixel in the reduced image against the mean of the reduced image. Async function.
    /// - Parameter From: The mean value to use to compared against each pixel.
    /// - Parameter In: The reduced image bitmap representation.
    /// - Returns: Array of `Int`s, indicating whether a given pixel is greater (1) or less (0) than the
    /// mean pixel value.
    func PixelDelta(From Mean: Double, In Rep: NSBitmapImageRep?) async -> [Int]?
    {
        guard let Rep = Rep else
        {
            print("PixelDelta: Invalid image representation")
            return nil
        }
        var PixelDeltas: [Int] = []
        for Y in 0 ..< Int(Rep.size.height)
        {
            for X in 0 ..< Int(Rep.size.width)
            {
                let pixel = await Pixel(Rep, X: X, Y: Y)
                let delta = Mean > Double(pixel) ? 0 : 1
                PixelDeltas.append(delta)
            }
        }
        return PixelDeltas
    }
    
    /// Resized the passed image. Async function.
    /// - Parameter Image: The image to resize.
    /// - Parameter To: The new size of the image.
    /// - Returns: New image at the specified size.
    func ResizeImage(_ Image: NSImage, To NewSize: CGSize) async -> NSImage
    {
        let scratch = NSImage(size: NewSize)
        scratch.lockFocus()
        let GCContext = NSGraphicsContext.current
        GCContext?.imageInterpolation = .high
        let NewRect = NSRect(x: 0, y: 0, width: NewSize.width, height: NewSize.height)
        Image.draw(in: NewRect)
        scratch.unlockFocus()
        return scratch
    }
    
    /// Get the mean pixel value for the image. Async function.
    /// - Parameter Image: The image whose mean pixel value will be returned.
    /// - Returns: Mean pixel value on success, nil on failure.
    func MeanPixel(_ Image: NSImage) async -> Double?
    {
        if ImageRep == nil
        {
            guard let irep = MakeRepresentation(Image) else
            {
                print("MeanPixel: Error creating image representation")
                return nil
            }
            ImageRep = irep
        }
        if let ImageRep = ImageRep
        {
            var sum: Double = 0.0
            for x in 0 ..< Int(Image.size.width)
            {
                for y in 0 ..< Int(Image.size.height)
                {
                    sum += await Double(Pixel(ImageRep, X: x, Y: y))
                }
            }
            return sum / (Double(Image.size.width) * Double(Image.size.height))
        }
        return nil
    }
    
    /// Get the pixel in the passed `NSBitmapImageRep` at the passed coordinates. Async function.
    /// - Parameter Image: The NSBitmapImageRep where the pixel lives.
    /// - Parameter X: The horizontal coordinate of the pixel.
    /// - Parameter Y: The vertical coordinate of the pixel.
    /// - Returns: The pixel value.
    func Pixel(_ Image: NSBitmapImageRep, X: Int, Y: Int) async -> Int
    {
        var PValue: Int = 0
        Image.getPixel(&PValue, atX: X, y: Y)
        return PValue
    }
}

extension NSImage
{
    var cgImage: CGImage?
    {
        get
        {
            var rect = NSRect(origin: .zero, size: self.size)
            return self.cgImage(forProposedRect: &rect,
                                context: NSGraphicsContext.current,
                                hints: nil)
        }
    }
}

// - MARK: [Float] Extensions

extension [Float]
{
    /// Returns the mean value of the contents of the array. Returns 0 if there are no
    /// elements in the array.
    var mean: Float
    {
        guard self.count > 0 else
        {
            return 0.0
        }
        return self.reduce(0, +) / Float(self.count)
    }
}
