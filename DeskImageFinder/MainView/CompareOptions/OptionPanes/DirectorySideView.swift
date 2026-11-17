//
//  DirectorySideView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import SwiftUI

struct DirectorySideView: View
{
    @State var SearchOptions: SessionsModel = SessionsModel()
//    @State var SearchOptions: DataModel = DataModel()
    @State var SelectedURLs: [URL] = []
    @State var Depth: String = ""
    @AppStorage("SubDirectorySearchDepth") var SubDirectorySearchDepth: Int = Int.max
    @AppStorage("SearchSubDirectories") var SearchSubDirectories: Bool = true
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("Search in Directories")
            Spacer()
            ScrollView
            {
                NavigationStack
                {
                    List
                    {
                        ForEach(SearchOptions.Current.SearchDirectories,
                                id: \.self)
                        {
                            item in
                            DirectoryLine(Raw: item)
                                .contextMenu
                            {
                                Button(action:
                                        {
                                    SearchOptions.Current.SearchDirectories = SearchOptions.Current.SearchDirectories.filter({$0 != item})
                                }){
                                    Text("Delete")
                                }
                            }
                        }
                    }
                    .border(.gray)
                    .frame(height: 280)
                }
            }
            HStack
            {
                Button("Add")
                {
                    let Panel = NSOpenPanel()
                    Panel.allowsMultipleSelection = true
                    Panel.canChooseDirectories = true
                    Panel.canCreateDirectories = false
                    Panel.canChooseFiles = false
                    if Panel.runModal() == .OK
                    {
                        self.SelectedURLs = Panel.urls
                        for SomeURL in self.SelectedURLs
                        {
                            if !SearchOptions.Current.SearchDirectories.contains(SomeURL)
                            {
                                SearchOptions.Current.SearchDirectories.append(SomeURL)
                            }
                        }
                    }
                }
                Button("Clear")
                {
                    SearchOptions.Current.SearchDirectories.removeAll()
                }
            }
            Divider()
            VStack
            {
                HStack
                {
                    Toggle(isOn: $SearchSubDirectories)
                    {
                        Text("Search sub-directories")
                    }
                    .toggleStyle(.switch)
                    .onChange(of: SearchSubDirectories)
                    {
                        old, new in
                        SearchSubDirectories = new
                        SearchOptions.Current.SearchSubDirectories = SearchSubDirectories
                    }
                    Spacer()
                }
                .help("Search subdirectories of source directories")

                HStack
                {
                    Text("Directory search depth")
                    TextField("", text: $Depth)
                        .frame(width: 60)
                        .onChange(of: Depth)
                    {
                        old, new in
                        Depth = new
                        if let newDepth = Int(new)
                        {
                            if newDepth == 0
                            {
                                // Depth of 0 is not allowed.
                                SearchOptions.Current.SearchDepth = 1
                                Depth = "1"
                            }
                            else
                            {
                                SearchOptions.Current.SearchDepth = newDepth
                            }
                        }
                        else
                        {
                            SearchOptions.Current.SearchDepth = .max
                            Depth = ""
                        }
                        SubDirectorySearchDepth = SearchOptions.Current.SearchDepth
                        let _ = print("SearchDepth=\(SearchOptions.Current.SearchDepth)")
                    }
                    if SubDirectorySearchDepth == Int.max
                    {
                        Text("search to the bottom")
                            .font(.footnote.smallCaps())
                    }
                    Spacer()
                }
                .help("Stop searching after reaching the specified depth of sub-directories. Leave blank to recurse to the bitter end.")
            }
                Spacer()
        }
        .padding()
        .onAppear
        {
            if SubDirectorySearchDepth == Int.max
            {
                Depth = ""
            }
            else
            {
                Depth = "\(SubDirectorySearchDepth)"
            }
        }
    }
}

struct DirectoryLine: View
{
    @State var Raw: URL? = nil
    
    var body: some View
    {
        if let RawURL = Raw
        {
            HStack
            {
                Text(Files.DirectoryFrom(RawURL, FromDirectory: true))
                Spacer()
            }
        }
    }
}

#Preview
{
    DirectorySideView()
}
