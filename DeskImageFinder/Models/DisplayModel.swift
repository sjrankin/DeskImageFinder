//
//  DisplayModel.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import Foundation
import Combine
import SwiftUI

/// Flags on how to display the similarity results.
@Observable class DisplayModel
{
    /// How to display the result view.
    var ResultsViewStyle: ResultViewTypes = ResultViewTypes.Thumbnails
    
    /// What to display in the annotation section of the thumbnail.
    var ThumbnailAnnotation: ThumbnailAnnotations = .Similarity

    /// Which results to show: 0 = exact only, 1 = exact and similar, 2 = all
    var ShowResultTypes: Int = 2
    
    /// Group results into similarity categories.
    var GroupResults: Bool = true
    
    /// Size of result items. 0 = Small, 1 = Medium, 2 = Big
    var ItemSize: Int = 0
    
    /// How to sort the results grid.
    var GridSortBy: SortResultsGrid = .Similarity
    
    /// Sort fields in ascending order.
    var SortAscending: Bool = true
    
    /// Side length of a grid tile for the current `ItemSize`. -1 = Teeny, 0 = Small, 1 = Medium, 2 = Large.
    var TileSide: CGFloat
    {
        switch ItemSize
        {
            case ...(-1):
                return 130.0
            case 1:
                return 220.0
            case 2:
                return 300.0
            default:
                return 160.0
        }
    }

    /// Returns the number of columns of thumbnails in the grid view depending on the width of the view.
    /// - Parameter For: The width of the view.
    /// - Returns: Number of columns of thumbnails.
    static func GridColumnCount(For Width: CGFloat) -> Int
    {
        var ColumnCount = 2
        switch Width
        {
            case 0.0 ... 400.0:
                ColumnCount = 2
            case 400.0 ... 500.0:
                ColumnCount = 3
            case 500.0 ... 700.0:
                ColumnCount = 4
            case 700.0 ... 900.0:
                ColumnCount = 5
            case 900.0 ... 1300.0:
                ColumnCount = 6
            case 1300.0 ... 1700.0:
                ColumnCount = 7
            default:
                ColumnCount = 8
        }
        print("View width: \(Width), ColumnCount=\(ColumnCount)")
        return ColumnCount
    }
}

/// Annotations on thumbnails.
enum ThumbnailAnnotations: Int
{
    /// No annotations.
    case None = 0
    /// Similarity values.
    case Similarity = 1
    /// File names.
    case Name = 2
}
