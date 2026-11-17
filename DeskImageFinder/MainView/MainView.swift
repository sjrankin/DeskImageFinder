//
//  MainView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct MainView: View
{
    @State var Model: DisplayModel = DisplayModel()
    @State var SearchModel = SessionsModel()
    @State var ResultsInfo: String = "Something interesting here."
    @State var EmptyString: String = ""
    var ProcessState: ProcessStatusModel = ProcessStatusModel()

    // App storage for persistent model field storage.
    // Display model data
    @AppStorage("ViewStyle") var ViewStyle: ResultViewTypes = .Thumbnails
    @AppStorage("ShowResultType") var ShowResultType: Int = 2
    @AppStorage("ItemSize") var ItemSize: Int = 0
    @AppStorage("SortAscending") var SortAscending: Bool = false
    @AppStorage("GridSortBy") var GridSortBy: String = SortResultsGrid.Similarity.rawValue
     
    // Process model data
    @AppStorage("SubDirectorySearchDepth") var SubDirectorySearchDepth: Int = Int.max
    @AppStorage("SearchSubDirectories") var SearchSubDirectories: Bool = true
    @AppStorage("StopAt") var StopAt: Int = Int.max
    @AppStorage("SearchQuantity") var SearchQuantity: Int = Int.max
    @AppStorage("ExactValue") var ExactValue: Double = 0.0
    @AppStorage("SimilarValue") var SimilarValue: Double = 0.35
    @AppStorage("IgnoreColor") var IgnoreColor: Bool = false
    @AppStorage("MustMatchSourceSize") var MustMatchSourceSize: Bool = false
    @AppStorage("ExcludeBigImage") var ExcludeBigImage: Bool = true
    @AppStorage("DimensionTooBig") var DimensionTooBig: Double = 10000.0
    @AppStorage("SearchJPG") var SearchJPG: Bool = true
    @AppStorage("SearchPNG") var SearchPNG: Bool = true
    @AppStorage("SearchTIFF") var SearchTIFF: Bool = true
    @AppStorage("SearchWEBP") var SearchWEBP: Bool = true
    @AppStorage("SearchGIF") var SearchGIF: Bool = true
    @AppStorage("SearchHEIC") var SearchHEIC: Bool = true
    @AppStorage("UseSizeWidth") var UseSizeWidth: Double = 0.0
    @AppStorage("UseSizeHeight") var UseSizeHeight: Double = 0.0
    @AppStorage("UseSourceAsDirectory") var UseSourceAsDirectory: Bool = false
    @AppStorage("UsePhotos") var UsePhotos: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            NavigationSplitView
            {
                SourcePicker(SearchModel: SearchModel,
                             Annotation: $ResultsInfo,
                             ProcessState: ProcessState)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: .infinity)
                    .onChange(of: SearchModel.Current.Results)
                {
                    old, new in
                    
                }
            }
        detail:
            {
                VStack
                {
                    TopViewBar(Model: Model,
                                  ResultsModel: SearchModel)
                    ResultsView(Model: Model,
                                SearchModel: SearchModel)
                    BottomViewBar(Status: ProcessState)
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
        .onAppear()
        {
            ProcessState.StatusType = .Ready
            RetrieveSettings()
        }
    }
    
    /// Synchronize display settings between the display setting model and app storage.
    func RetrieveSettings()
    {
        // Display model
        Model.ShowResultTypes = ShowResultType
        Model.ResultsViewStyle = ViewStyle
        Model.ItemSize = ItemSize
        Model.SortAscending = SortAscending
        Model.GridSortBy = SortResultsGrid(rawValue: GridSortBy) ?? .Similarity

        // Search model
        SearchModel.Current.SearchDepth = SubDirectorySearchDepth
        SearchModel.Current.SearchSubDirectories = SearchSubDirectories
        SearchModel.Current.ExactValue = Float(ExactValue)
        SearchModel.Current.SimilarValue = Float(SimilarValue)
        SearchModel.Current.IgnoreColor = IgnoreColor
        SearchModel.Current.MustMatchSourceSize = MustMatchSourceSize
        SearchModel.Current.ExcludeBigImage = ExcludeBigImage
        SearchModel.Current.DimensionTooBig = DimensionTooBig
        SearchModel.Current.SearchJPG = SearchJPG
        SearchModel.Current.SearchPNG = SearchPNG
        SearchModel.Current.SearchTIFF = SearchTIFF
        SearchModel.Current.SearchWEBP = SearchWEBP
        SearchModel.Current.SearchGIF = SearchGIF
        SearchModel.Current.SearchHEIC = SearchHEIC
        if UseSizeWidth == 0.0 || UseSizeHeight == 0.0
        {
            SearchModel.Current.UseSize = nil
        }
        else
        {
            SearchModel.Current.UseSize = CGSize(width: CGFloat(UseSizeWidth), height: CGFloat(UseSizeHeight))
        }
        SearchModel.Current.UseSourceAsDirectory = UseSourceAsDirectory
        SearchModel.Current.UsePhotos = UsePhotos
    }
}

#Preview
{
    MainView()
}
