//
//  ResultsView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct ResultsView: View
{
    @State var Results: [SimilarityResult] = []
    @State var Model: DisplayModel
    @State var SearchModel: SessionsModel
    
    var body: some View
    {
        switch Model.ResultsViewStyle
        {
            case .Thumbnails:
                ResultsGridView(SearchModel: SearchModel,
                                Display: Model)
                .padding(.vertical, -8)
            case .List:
                ResultsListView(SearchModel: SearchModel,
                                Display: Model)
                .padding(.vertical, -8)
            case .Tree:
                HierarchyView(SearchModel: SearchModel,
                              Display: Model)
                    .padding(.vertical, -8)
        }
    }
}

#Preview
{
    ResultsView(Model: DisplayModel(),
                SearchModel: SessionsModel())
}
