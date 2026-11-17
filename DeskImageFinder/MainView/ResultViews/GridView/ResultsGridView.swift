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
   
    var body: some View
    {
        let Side = Display.TileSide
        let Groups = ResultArranger.Arrange(SearchModel.Current.Results,
                                            Search: SearchModel.Current,
                                            Filter: Display.ShowResultTypes,
                                            SortBy: Display.GridSortBy,
                                            Ascending: Display.SortAscending,
                                            Group: Display.GroupResults)
        ScrollView(.vertical)
        {
            LazyVStack(alignment: .leading, spacing: 8)
            {
                ForEach(Groups)
                {
                    Section in
                    if let Title = Section.Title
                    {
                        Text("\(Title) (\(Section.Items.count))")
                            .font(.headline)
                            .padding(.horizontal, 8)
                            .padding(.top, 24)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: Side), spacing: 8)], spacing: 8)
                    {
                        ForEach(Section.Items)
                        {
                            result in
                            GridThumbnailView(image: result.TargetImage,
                                              ImageURL: result.Path,
                                              ImageName: Files.NameFrom(result.Path),
                                              score: result.Score,
                                              width: Side - 64,
                                              height: Side - 64,
                                              Search: SearchModel.Current)
                            .frame(width: Side, height: Side)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)))
        }
    }
}

#Preview
{
    ResultsGridView(SearchModel: SessionsModel(),
                    Display: DisplayModel())
}
