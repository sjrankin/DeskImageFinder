//
//  FileTypesView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/22/25.
//

import SwiftUI

struct FileTypesView: View
{
//    @State var SearchOptions: DataModel = DataModel()
    @State var SearchOptions: SessionsModel = SessionsModel()
    
    var body: some View {
        VStack
        {
            HStack
            {
                Text("Image file types to examine")
                Spacer()
            }
            .padding(.horizontal, 4)
            HStack
            {
                VStack
                {
                    HStack
                    {
                        Text("File types")
                            .bold()
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchJPG,
                                   StoreIn: SearchOptions.Current.SearchJPG,
                                   PromptText: "JPG",
                                   HelpText: "Search JPG files.")
                        .padding(.leading)
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchPNG,
                                   StoreIn: SearchOptions.Current.SearchPNG,
                                   PromptText: "PNG",
                                   HelpText: "Search PNG files.")
                        .padding(.leading)
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchTIFF,
                                   StoreIn: SearchOptions.Current.SearchTIFF,
                                   PromptText: "TIFF",
                                   HelpText: "Search TIFF files.")
                        .padding(.leading)
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchWEBP,
                                   StoreIn: SearchOptions.Current.SearchWEBP,
                                   PromptText: "WEBP",
                                   HelpText: "Search WEBP files.")
                        .padding(.leading)
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchGIF,
                                   StoreIn: SearchOptions.Current.SearchGIF,
                                   PromptText: "GIF",
                                   HelpText: "Search GIF files. Animated GIFs ignored.")
                        .padding(.leading)
                        Spacer()
                    }
                    HStack
                    {
                        ToggleView(ToggleValue: SearchOptions.Current.SearchHEIC,
                                   StoreIn: SearchOptions.Current.SearchHEIC,
                                   PromptText: "HEIC",
                                   HelpText: "Search HEIC files. Animated GIFs ignored.")
                        .padding(.leading)
                        Spacer()
                    }
                }
                .padding(4)
                Spacer()
            }
            .border(.gray)
            .padding(4)
            Spacer()
        }
        .frame(height: 300)
    }
}

struct ToggleView: View
{
    @State var ToggleValue: Bool = false
    @State var StoreIn: Bool = false
    @State var PromptText: String = "Toggle prompt"
    @State var HelpText: String = ""
    
    var body: some View
    {
        HStack
        {
            Toggle(isOn: $ToggleValue)
            {
                Text(PromptText)
                    .bold()
            }
            .toggleStyle(.switch)
            .onChange(of: ToggleValue)
            {
                old, new in
                ToggleValue = new
                StoreIn = ToggleValue
            }
            Spacer()
        }
        .help(HelpText)
    }
}

#Preview {
    FileTypesView()
}
