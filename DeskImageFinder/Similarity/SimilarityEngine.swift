//
//  SimilarityEngine.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/22/25.
//

import Foundation
import AppKit
import Vision
import Combine

class SimilarityEngine
{
    /// Run a visual similarity engine with the specified parameters.
    /// - Parameter Engine: Determines which engine to use.
    /// - Parameter With: Search/similarity parameters in the `DataModel` object.
    static func Run(_ Engine: SimilarityEngines,
                    With Parameters: DataModel)
    {
        Parameters.Results.removeAll()
        switch Engine
        {
            case .Histogram:
                break
                
            case .PHash:
                break
                
            case .Vision:
                VisionSimilarity.FindSimilarImages(With: Parameters)
        }
    }
    
    static func Run(Engine: SimilarityEngines,
                    Reference: NSImage,
                    Against: NSImage,
                    With Parameters: DataModel) async -> ComparisonResult?
    {
        Parameters.Results.removeAll()
        switch Engine
        {
            case .Histogram:
                return nil
                
            case .PHash:
                return nil
                
            case .Vision:
                return await VisionSimilarity.GetImageDelta(Reference: Reference,
                                                            Test: Against,
                                                            Parameter: Parameters)
        }
    }
}

/// Available (more or less) image similarity engines.
enum SimilarityEngines
{
    /// Use the `Vision` image similarity feature from the Vision API.
    case Vision
    
    /// Use `pHash` image perceptual hash..
    case PHash
    
    /// Use multiple histograms for similarity.
    case Histogram
}
