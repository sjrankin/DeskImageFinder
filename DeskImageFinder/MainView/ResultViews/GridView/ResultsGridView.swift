//
//  ResultsGridView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct ResultsGridView: View
{
    @State var SearchModel: SessionsModel
    @State var Display: DisplayModel
    @State var Columns: [GridItem] = [GridItem(.flexible()),
                                      GridItem(.flexible()),
                                      GridItem(.flexible()),
                                      GridItem(.flexible())]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            LazyVGrid(columns: Columns)
            {
                ForEach(SearchModel.Current.Results.sorted(by: {$0.Score < $1.Score}), id: \.self)
                {
                    result in
                    if ShowResult(With: result.Score, Filter: Display.ShowResultTypes)
                    {
                        GridThumbnailView(image: result.TargetImage,
                                          ImageURL: result.Path,
                                          ImageName: Files.NameFrom(result.Path),
                                          score: result.Score,
                                          Search: SearchModel.Current)
                        .padding(.vertical, 10)
                        .frame(width: 160, height: 160)
                    }
                }
            }
            .padding(.bottom, 32)
            .onGeometryChange(for: CGRect.self)
            {
                proxy in
                proxy.frame(in: .global)
            } action:
            {
                new in
                let GridViewWidth = new.width
                let ColumnCount = DisplayModel.GridColumnCount(For: GridViewWidth)
                self.Columns = Array(repeating: GridItem(.flexible()),
                                     count: ColumnCount)
            }
            .background(Color(NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)))
        }
    }
    
    /// Filters a given item depending on the comparison result and how the user set the filter.
    /// - Parameter With: The score of the image comparison.
    /// - Parameter Filter: The UI filter setting as per the user.
    /// - Returns: True if the score meets the filter, false if not.
    func ShowResult(With Score: Float, Filter: Int) -> Bool
    {
        let ResultType = SearchModel.Current.ResultType(With: Score)
        switch Filter
        {
            case 0:
                return ResultType == .Exact
            case 1:
                return (ResultType == .Exact || ResultType == .Similar)
            case 2:
                return true
            default:
                return true
        }
    }
}

#Preview
{
    ResultsGridView(SearchModel: SessionsModel(),
                    Display: DisplayModel())
}
