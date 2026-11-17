//
//  ImageUtilities.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/6/25.
//

import Foundation
import AppKit
import CoreGraphics
import CoreImage.CIFilter

extension NSImage
{
    func grayscale() -> NSImage?
    {
        let cg = self.CGImage
        let bitmap = NSBitmapImageRep(cgImage: cg)
        guard let grayscale = bitmap.converting(to: .genericGray,
                                                renderingIntent: .default) else
        {
            return nil
        }
        let grayscaleImage = NSImage(size: self.size)
        grayscaleImage.addRepresentation(grayscale)
        return grayscaleImage
    }
    
    // https://stackoverflow.com/questions/24595908/swift-nsimage-to-cgimage
    var CGImage: CGImage {
        get {
            let imageData = self.tiffRepresentation!
            let source = CGImageSourceCreateWithData(imageData as CFData, nil).unsafelyUnwrapped
            let maskRef = CGImageSourceCreateImageAtIndex(source, Int(0), nil)
            return maskRef.unsafelyUnwrapped
        }
    }
}
