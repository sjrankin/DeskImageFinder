//
//  ResultsTreeView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/24/25.
//

import SwiftUI

struct ResultsTreeView: View
{
    @State var SearchModel: SessionsModel
    @State var Display: DisplayModel
    
    /// Results filtered, sorted and (optionally) grouped per the toolbar, as one flat list.
    var Arranged: [SimilarityResult]
    {
        ResultArranger.Arrange(SearchModel.Current.Results,
                               Search: SearchModel.Current,
                               Filter: Display.ShowResultTypes,
                               SortBy: Display.GridSortBy,
                               Ascending: Display.SortAscending,
                               Group: Display.GroupResults).flatMap(\.Items)
    }
    
    var body: some View
    {
        VStack
        {
            ScrollView(.vertical)
            {
                ForEach(Arranged)
                {
                    result in
                    Group
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
