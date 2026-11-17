//
//  DebugView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/25/25.
//

import SwiftUI

struct DebugView: View
{
    @Environment(\.dismiss) var Dismiss
    @State var SearchOptions: SessionsModel
    @AppStorage("OptionsTab") var SelectedTab: Int = 0
    
    var body: some View
    {
        VStack
        {
            Text("Debug")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            TabView(selection: $SelectedTab)
            {
                DebugThumbnailView()
                    .tabItem
                {
                    Text("Thumbnail")
                }
                .tag(0)
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

#Preview
{
    DebugView(SearchOptions: SessionsModel())
}
