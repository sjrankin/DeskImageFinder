//
//  ResultArranger.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 11/17/26.
//

import Foundation

/// A titled run of results. When results are not grouped, a single group with no title is used.
struct ResultGroup: Identifiable
{
    /// Identifies the group in SwiftUI.
    let id: String
    /// Title shown above the group, or nil for an ungrouped list.
    let Title: String?
    /// Results in the group, already sorted.
    let Items: [SimilarityResult]
}

/// Filters, sorts, and groups similarity results according to the toolbar settings.
enum ResultArranger
{
    /// Arrange results for display.
    /// - Parameter Results: All results of the search.
    /// - Parameter Search: The search model. Used to classify results as exact, similar or other.
    /// - Parameter Filter: Which results to show: 0 = exact only, 1 = exact and similar, 2 = all.
    /// - Parameter SortBy: The field to sort by.
    /// - Parameter Ascending: If true, sort low to high (A to Z, smallest, oldest, most similar first).
    /// - Parameter Group: If true, split the results into exact, similar, and other groups.
    /// - Returns: The groups to display. Empty groups are omitted.
    static func Arrange(_ Results: [SimilarityResult],
                        Search: DataModel,
                        Filter: Int,
                        SortBy: SortResultsGrid,
                        Ascending: Bool,
                        Group: Bool) -> [ResultGroup]
    {
        let Visible = Results.filter
        {
            Include(Search.ResultType(With: $0.Score), Filter: Filter)
        }
        var Sorted = Sort(Visible, By: SortBy, Ascending: Ascending)
        // The source (original) image always comes first, ahead of anything with the same score.
        if let Index = SourceIndex(In: Sorted, Search: Search), Index > 0
        {
            Sorted.insert(Sorted.remove(at: Index), at: 0)
        }
        if !Group
        {
            return Sorted.isEmpty ? [] : [ResultGroup(id: "All", Title: nil, Items: Sorted)]
        }
        let Classes: [(ResultTypes, String)] = [(.Exact, "Exact matches"),
                                                (.Similar, "Similar"),
                                                (.All, "Other")]
        return Classes.compactMap
        {
            (Class, Title) in
            let Items = Sorted.filter {Search.ResultType(With: $0.Score) == Class}
            return Items.isEmpty ? nil : ResultGroup(id: Title, Title: Title, Items: Items)
        }
    }

    /// Finds the source image in a list of results.
    /// - Note: Matches on the resolved file path first, then on the file name, and finally on the file name without
    ///   its extension (for exact matches only), so a source saved under another extension is still found.
    private static func SourceIndex(In Results: [SimilarityResult], Search: DataModel) -> Int?
    {
        guard let Source = Search.Source else
        {
            return nil
        }
        let SourcePath = Source.resolvingSymlinksInPath().standardizedFileURL.path.lowercased()
        if let Index = Results.firstIndex(where: {$0.Path.resolvingSymlinksInPath().standardizedFileURL.path.lowercased() == SourcePath})
        {
            return Index
        }
        let SourceName = Source.lastPathComponent.lowercased()
        if let Index = Results.firstIndex(where: {$0.Path.lastPathComponent.lowercased() == SourceName})
        {
            return Index
        }
        let SourceStem = Source.deletingPathExtension().lastPathComponent.lowercased()
        return Results.firstIndex
        {
            $0.Score <= Search.ExactValue &&
            $0.Path.deletingPathExtension().lastPathComponent.lowercased() == SourceStem
        }
    }
    
    /// Determines if a result class passes the "show" filter.
    private static func Include(_ ResultType: ResultTypes, Filter: Int) -> Bool
    {
        switch Filter
        {
            case 0:
                return ResultType == .Exact
            case 1:
                return ResultType == .Exact || ResultType == .Similar
            default:
                return true
        }
    }

    /// Sort results. Ties are broken by score and then name so the order is stable.
    static func Sort(_ Results: [SimilarityResult],
                     By Field: SortResultsGrid,
                     Ascending: Bool) -> [SimilarityResult]
    {
        // Read file attributes once per result, not once per comparison.
        var FileSizes = [UUID: Int]()
        var FileDates = [UUID: Date]()
        if Field == .ImageSize || Field == .ImageAge
        {
            for Result in Results
            {
                let Values = try? Result.Path.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                FileSizes[Result.id] = Values?.fileSize ?? 0
                FileDates[Result.id] = Values?.creationDate ?? .distantPast
            }
        }

        return Results.sorted
        {
            (LHS, RHS) in
            var Order: Foundation.ComparisonResult
            switch Field
            {
                case .Similarity:
                    Order = Compare(LHS.Score, RHS.Score)
                case .ImageSize:
                    Order = Compare(FileSizes[LHS.id] ?? 0, FileSizes[RHS.id] ?? 0)
                case .ImageAge:
                    Order = Compare(FileDates[LHS.id] ?? .distantPast, FileDates[RHS.id] ?? .distantPast)
                case .Directory:
                    Order = LHS.Path.deletingLastPathComponent().path
                        .localizedStandardCompare(RHS.Path.deletingLastPathComponent().path)
                case .Name:
                    Order = LHS.FileName().localizedStandardCompare(RHS.FileName())
            }
            if Order == .orderedSame
            {
                Order = Compare(LHS.Score, RHS.Score)
            }
            if Order == .orderedSame
            {
                Order = LHS.FileName().localizedStandardCompare(RHS.FileName())
            }
            if Order == .orderedSame
            {
                return false
            }
            return Ascending ? Order == .orderedAscending : Order == .orderedDescending
        }
    }

    private static func Compare<T: Comparable>(_ LHS: T, _ RHS: T) -> Foundation.ComparisonResult
    {
        LHS < RHS ? .orderedAscending : (LHS > RHS ? .orderedDescending : .orderedSame)
    }
}
