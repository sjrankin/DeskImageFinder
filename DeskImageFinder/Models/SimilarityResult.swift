//
//  SimilarityResult.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import Foundation
import SwiftUI

/// Contains one image similarity result.
struct SimilarityResult: Identifiable, Equatable, Hashable
{
    /// Required by protocols and for use when displaying results in SwiftUI.
    let id = UUID()
    /// Path to the image.
    let Path: URL
    /// How close to the source image this given image is. A score of 0.0 is an exact match, and higher
    /// values indicate less similarity.
    var Score: Float
    /// The tested image.
    let TargetImage: NSImage
    /// General use tag value.
    let Tag: String
    
    /// Get a file name based on `Path`.
    func FileName() -> String
    {
        return Files.NameFrom(Path)
    }
}
