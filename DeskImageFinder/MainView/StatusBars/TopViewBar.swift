//
//  TopViewBar.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct TopViewBar: View
{
    @State var Model: DisplayModel
    @State var ResultsModel: SessionsModel
    @State var ShowSearchSummary: Bool = false
    @State var ShowSessionSummary: Bool = false
    
    // Stored data
    @AppStorage("ViewStyle") var ViewStyle: ResultViewTypes = .Thumbnails
    @AppStorage("ShowExact") var ShowExact: Bool = false
    @AppStorage("ShowSimilar") var ShowSimilar: Bool = false
    @AppStorage("ShowAll") var ShowAll: Bool = true
    @AppStorage("ShowSmall") var ShowSmall: Bool = true
    @AppStorage("ShowMedium") var ShowMedium: Bool = true
    @AppStorage("ShowBig") var ShowBig: Bool = true
    @AppStorage("ShowResultType") var ShowResultType: Int = 2
    @AppStorage("ItemSize") var ItemSize: Int = 0
    @AppStorage("SortAscending") var SortAscending: Bool = false
    @AppStorage("GridSortBy") var GridSortBy: String = SortResultsGrid.Similarity.rawValue
    
    var body: some View
    {
        HStack
        {
            Picker(selection: $ViewStyle, label: Text(""))
            {
                Image(systemName: "square.grid.3x3")
                    .tag(ResultViewTypes.Thumbnails)
                Image(systemName: "list.bullet")
                    .tag(ResultViewTypes.List)
                Image(systemName: "list.bullet.indent")
                    .tag(ResultViewTypes.Tree)
            }
            .onChange(of: ViewStyle)
            {
                _, new in
                self.ViewStyle = new
                Model.ResultsViewStyle = new
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
            .frame(width: 100)
            .padding(.leading, 4)
            Divider()
            Picker("Show", selection: $ShowResultType)
            {
                Text("Exact only")
                    .tag(0)
                Text("Exact + Similar")
                    .tag(1)
                Text("All")
                    .tag(2)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 200)
            .onChange(of: ShowResultType)
            {
                old, new in
                ShowResultType = new
                Model.ShowResultTypes = new
            }
            .help("Item sizes")
            .padding(.leading, 4)
            
            ControlGroup
            {
                Toggle(isOn: $Model.GroupResults)
                {
                    Image(systemName: "rectangle.3.group")
                }
                .toggleStyle(.button)
                .help("Group results by similarity class")
                .onChange(of: Model.GroupResults)
                {
                    old, new in
                    if old != new
                    {
                        Model.GroupResults = new
                    }
                }
            }
            .frame(width: 35)
            .padding(.leading, 4)
            Divider()
            Picker("Size", selection: $ItemSize)
            {
                Text("Teeny")
                    .tag(-1)
                Text("Small")
                    .tag(0)
                Text("Medium")
                    .tag(1)
                Text("Large")
                    .tag(2)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
            .onChange(of: ItemSize)
            {
                old, new in
                ItemSize = new
                Model.ItemSize = new
            }
            .help("Item sizes")
            .padding(.leading, 4)
            Divider()
            Picker("Sort by", selection: $Model.GridSortBy)
            {
                Text("Similarty")
                    .tag(SortResultsGrid.Similarity)
                Text("Size")
                    .tag(SortResultsGrid.ImageSize)
                Text("Age")
                    .tag(SortResultsGrid.ImageAge)
                Text("Directory")
                    .tag(SortResultsGrid.Directory)
                Text("Name")
                    .tag(SortResultsGrid.Name)
            }
            .onChange(of: Model.GridSortBy)
            {
                old, new in
                Model.GridSortBy = new
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
            .help("Sorting options")
            .padding(.leading, 4)
            
            ControlGroup
            {
                Button("", systemImage: SortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                {
                    SortAscending = !SortAscending
                    Model.SortAscending = SortAscending
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(.blue)
            }
            .help("Sort \(SortAscending ? "ascending" : "descending")")
            .frame(width: 35)
            .padding(.leading, 4)
            
            Divider()
            
            ControlGroup
            {
                Button("", systemImage: "seal")
                {
                    ShowSearchSummary.toggle()
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .help("Show search summary and other gratuitous information.")
                Button("", systemImage: "sum")
                {
                    ShowSessionSummary.toggle()
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .help("Show session summary and logs.")
            }
            .frame(width: 70)
            .padding(.leading, 4)
            
            Spacer()
        }
        .frame(height: 24)
        .padding(.all, 4)
        .background(Color(nsColor: NSColor.separatorColor))
        .sheet(isPresented: $ShowSearchSummary)
        {
            SummarySheet(Results: ResultsModel)
        }
        .sheet(isPresented: $ShowSessionSummary)
        {
            SessionLog(Results: ResultsModel)
        }
    }
}

#Preview {
    TopViewBar(Model: DisplayModel(),
               ResultsModel: SessionsModel())
}

enum SortResultsGrid: String
{
    case Similarity = "Similarity"
    case ImageSize = "Size"
    case ImageAge = "Age"
    case Directory = "Directory"
    case Name = "Name"
}

enum ResultViewTypes: Int
{
    case Thumbnails = 0
    case List = 1
    case Tree = 2
}
