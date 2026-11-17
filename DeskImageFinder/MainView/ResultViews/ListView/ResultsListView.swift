//
//  ResultsListView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct ResultsListView: View
{
    @State var SearchModel: SessionsModel
    @State var Display: DisplayModel
    @State var Columns: [GridItem] = [GridItem(.flexible())]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            LazyVGrid(columns: Columns)
            {
                ForEach(SearchModel.Current.Results.sorted
                        {
                    (lhs: SimilarityResult, rhs: SimilarityResult) in
                    /*
                     if Display.GridSortBy == .Name
                     {
                     return Display.SortAscending ? lhs.FileName() > rhs.FileName() :
                     lhs.FileName() < rhs.FileName()
                     }
                     return Display.SortAscending ? lhs.Score > rhs.Score : lhs.Score < rhs.Score
                     */
                    SortResults(LHS: lhs, RHS: rhs)
                }, id: \.self)
                {
                    result in
                    if ShowResult(With: result.Score, Filter: Display.ShowResultTypes)
                    {
                        ResultListItem(image: result.TargetImage,
                                       ImageURL: result.Path,
                                       ImageName: Files.NameFrom(result.Path),
                                       Score: result.Score,
                                       Display: Display,
                                       Search: SearchModel.Current)
                        .frame(height: Height(For: Display))
                        Divider()
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding(.bottom, 32)
    }
    
    /// Compare two similarity result structures for sorting.
    /// - Parameter LHS: The left hand side structure.
    /// - Parameter RHS: The right hand side structure.
    /// - Returns : True if LHS is greater than RHS, false otherwise.
    /// - Note: Sort order and which fields are used are defined in `Display` and set by the UI.
    func SortResults(LHS: SimilarityResult, RHS: SimilarityResult) -> Bool
    {
        if Display.GridSortBy == .Name
        {
            return Display.SortAscending ? LHS.FileName() > RHS.FileName() :
            LHS.FileName() < RHS.FileName()
        }
        return Display.SortAscending ? LHS.Score > RHS.Score
        : LHS.Score < RHS.Score
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
    
    func Height(For: DisplayModel) -> CGFloat
    {
        switch For.ItemSize
        {
            case 0:
                return 48.0
                
            case 1:
                return 80.0
                
            case 2:
                return 120.0
                
            default:
                return 48.0
        }
    }
}

#Preview
{
    ResultsListView(SearchModel: SessionsModel(),
                    Display: DisplayModel())
}
