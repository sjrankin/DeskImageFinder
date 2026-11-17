//
//  DataModel.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI
import Combine

/// Tells the various search engines how to look for similarity and where to look, and which files to test. Also
/// contains the set of results and source image URL.
@Observable class DataModel: Identifiable
{
    var id = UUID()
    
    /// Create a `DataModel` instance used for searching similar images. Default values are used.
    /// - Note: This (empty) constructor is needed because a copy constructor is also present.
    init()
    {
    }
    
    /// Create a `DataModel` instance based on the passed `DataModel` instance. Results
    /// are _not_ duplicated/copied.
    /// - Parameter Previous: The previous `DataModel` to use as a source for the new `DataModel`.
    init(Previous: DataModel)
    {
        self.Source = Previous.Source
        self.UseSourceAsDirectory = Previous.UseSourceAsDirectory
        self.UsePhotos = Previous.UsePhotos
        self.StopAt = Previous.StopAt
        self.SearchQuantity = Previous.SearchQuantity
        self.SearchDepth = Previous.SearchDepth
        self.SearchDirectories = Previous.SearchDirectories
        self.SearchSubDirectories = Previous.SearchSubDirectories
        self.ExactValue = Previous.ExactValue
        self.SimilarValue = Previous.SimilarValue
        self.IgnoreColor = Previous.IgnoreColor
        self.MustMatchSourceSize = Previous.MustMatchSourceSize
        self.ExcludeBigImage = Previous.ExcludeBigImage
        self.DimensionTooBig = Previous.DimensionTooBig
        self.SearchGIF = Previous.SearchGIF
        self.SearchJPG = Previous.SearchJPG
        self.SearchTIFF = Previous.SearchTIFF
        self.SearchWEBP = Previous.SearchWEBP
        self.SearchHEIC = Previous.SearchHEIC
        self.SearchPNG = Previous.SearchPNG
        self.UseSize = Previous.UseSize

        // Don't duplicate results of previous searches.
        self.Results = [SimilarityResult]()
        self.ExactCount = 0
        self.SimilarCount = 0
        self.SearchCount = 0
        self.ExactDirectories = Set<URL>()
        self.SimilarDirectories = Set<URL>()
        self.SearchDirectories = [URL]()
        self.LogMessages.removeAll()
        self.UnsearchedDirectoryCount = 0
        self.DirectoriesCompletedPercent = 0.0
    }
    
    /// Timestamp for the given `DataModel` instance. If `nil`, the current session instance has not yet
    /// be committed.
    var InstanceTimeStamp: Date? = nil
    
    /// URL of the source image to compare against other images.
    var Source: URL?
    
    /// If true, use the directory of the source file as the directory to search.
    var UseSourceAsDirectory: Bool = false

    /// If true, use the built-in Pictures Library to search.
    /// - Note: the pictures library is not well supported in terms of application use and is best
    /// ignored
    var UsePhotos: Bool = false

    /// Array of results. Cleared when a search is started.
    var Results: [SimilarityResult] = []
    
    /// Number of searched images that exactly match the source.
    var ExactCount: Int = 0
    
    /// Number of searched images that are similar to the source.
    var SimilarCount: Int = 0
    
    /// Total number of items compared (which may be less than the total number of items due to
    /// various search settings).
    var SearchCount: Int = 0

    /// Stop searching after this number of matches is found. Set to `Int.max` to effectively search all images.
    var StopAt: Int = Int.max
    
    /// Stop searching after examining this number of files.
    var SearchQuantity: Int = Int.max

    /// How deep to look into sub-directories. Set to `Int.max` to effectively search as deeply as possible.
    var SearchDepth: Int = Int.max
    
    /// Set of directories that contain exact images.
    var ExactDirectories: Set<URL> = []
    
    /// Set of directories that contain similar images.
    var SimilarDirectories: Set<URL> = []

    /// Array of directories (and sub-directories) to search.
    var SearchDirectories: [URL] = []
    /*
    /// Search subdirectories of source directories.
    var SearchSubdirectories: Bool = true
*/
    /// If `true`, sub-directories are searched. If `false` no sub-directories are searched (regardless of `SearchDepth`).
    var SearchSubDirectories: Bool = true
    
    /// Number of unsearched directories.
    var UnsearchedDirectoryCount: Int = 0
    
    /// Perent of directories searched.
    var DirectoriesCompletedPercent: Double = 0.0

    /// Value to indicate an exact match. The similarity score must be between `0.0` and this value.
    var ExactValue: Float = 0.0

    /// Value to indicate a similar match. The similarity score must be between `ExactValue` and this value. Scores
    /// greater than this value are considered total mismatches.
    var SimilarValue: Float = 0.35

    /// If `true`, images are converted internally to grayscale for comparison purposes. If `false`, no conversion is
    /// done. (_Note: Source images are left untouched._)
    var IgnoreColor: Bool = false

    /// If the source image and test image have different dimensions, the test image is ignored and not tested. Can be
    /// overridden by `UseSize`
    var MustMatchSourceSize: Bool = false

    /// Don't test images if any dimension is greater than the contents of `DimensionTooBig`.
    var ExcludeBigImage: Bool = true
    
    /// If `ExcludeBigImage` is true, the value here is used to determine if the image is too big.
    var DimensionTooBig: Double = 10000.0
    
    /// Test all .jpg, .jpeg files.
    var SearchJPG: Bool = true

    /// Test all .png files.
    var SearchPNG: Bool = true

    /// Test all .tiff, .tif files.
    var SearchTIFF: Bool = false

    /// Test all .webp files.
    var SearchWEBP: Bool = true

    /// Test all .gif files. Animated gifs are ignored.
    var SearchGIF: Bool = false

    /// Test all .heic files. Animated images are ignored.
    var SearchHEIC: Bool = false

    /// Convert all images to the supplied image size. If nil, no conversion done. If non-nil, this value
    /// overrides `MustMatchSourceSize`
    var UseSize: CGSize? = nil
    
    /// Clears the set of results.
    func ClearResults()
    {
        ExactCount = 0
        SimilarCount = 0
        SearchCount = 0
        Source = nil
        Results.removeAll()
        ExactDirectories.removeAll()
        SimilarDirectories.removeAll()
    }
    
    /// Returns the result class (exact, similar, not close) for a given score and the current class values
    /// for `ExactValue` and `SimilarValue`.
    /// - Parameter With: The score to test.
    /// - Returns: The result class for the passed score.
    func ResultType(With Score: Float) -> ResultTypes
    {
        if Score <= ExactValue
        {
            return .Exact
        }
        if Score > ExactValue && Score <= SimilarValue
        {
            return .Similar
        }
        return .All
    }
    
    /// Holds all log messages.
    var LogMessages = [String]()
    
    /// Add a log message.
    /// - Parameter Message: The message to add.
    func AddLog(_ Message: String)
    {
        LogMessages.append(Message)
    }
    
    /// Clears all log messages.
    func ClearLogMessages()
    {
        LogMessages.removeAll()
    }
}

/// Classifications for results of similarity testing.
enum ResultTypes
{
    /// Exact match.
    case Exact
    /// Similar match.
    case Similar
    /// Not exact or similar.
    case All
}
