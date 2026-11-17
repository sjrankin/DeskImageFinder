//
//  SearchOptionsView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/22/25.
//

import SwiftUI

struct SearchOptionsView: View
{
    @Environment(\.dismiss) var Dismiss
    @State var SearchOptions: SessionsModel
//    @State var SearchOptions: DataModel
    @AppStorage("OptionsTab") var SelectedTab: Int = 0
    
    var body: some View
    {
        VStack
        {
            Text("Similarity Search Options")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            TabView(selection: $SelectedTab)
            {
                QuickOptionView(SearchOptions: SearchOptions)
                    .tabItem
                {
                    Text("Quick")
                }
                .tag(0)
                
                OptionSideView(SearchOptions: SearchOptions)
                    .tabItem
                {
                    Text("Similarity")
                }
                .tag(1)
                
                DirectorySideView(SearchOptions: SearchOptions)
                    .tabItem
                {
                    Text("Directories")
                }
                .tag(2)
                FileTypesView(SearchOptions: SearchOptions)
                    .tabItem
                {
                    Text("File Types")
                }
                .tag(3)
                TestStuff(SearchOptions: SearchOptions)
                    .tabItem
                {
                    Text("Test")
                }
                .tag(4)
            }
            .tabViewStyle(SidebarAdaptableTabViewStyle())
            Divider()
            Button("Close")
            {
                Dismiss()
            }
            .padding(4)
            .padding(.bottom, 6)
        }
    }
}

struct SearchFlagsView: View
{
    @State var SearchOptions: DataModel
    
    var body: some View
    {
        VStack
        {
            Text("Flags to control search")
        }
    }
}

struct DirectorySearchView: View
{
    @State var SearchOptions: DataModel
    
    var body: some View
    {
        VStack
        {
            Text("select directories to search")
        }
    }
}

#Preview {
    SearchOptionsView(SearchOptions: SessionsModel())
}
