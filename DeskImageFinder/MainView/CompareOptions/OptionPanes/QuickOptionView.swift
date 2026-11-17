//
//  QuickOptionView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/23/25.
//

import SwiftUI

struct QuickOptionView: View
{
//    @State var SearchOptions: DataModel
    @State var SearchOptions: SessionsModel
    @State var OtherDirectory: Bool = false
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("Quick and dirty way to set options for searching for similarity. Other than the options here, everything else is set to default values. (You can still change them in other setting pages if you want.)")
                Spacer()
            }
            Divider()
            HStack
            {
                Text("Search Directory")
                ControlGroup
                {
                    Toggle(isOn: $SearchOptions.Current.UseSourceAsDirectory)
                    {
                        Text("Source")
                    }
                    .toggleStyle(.button)
                    .help("Use the source image's directory as the search directory.")
                    .onChange(of: SearchOptions.Current.UseSourceAsDirectory)
                    {
                        old, new in
                        if old != new
                        {
                            SearchOptions.Current.UseSourceAsDirectory = new
                            if SearchOptions.Current.UseSourceAsDirectory
                            {
                                OtherDirectory = false
                                SearchOptions.Current.UsePhotos = false
                            }
                        }
                    }
                    Toggle(isOn: $SearchOptions.Current.UsePhotos)
                    {
                        Text("Photos")
                    }
                    .toggleStyle(.button)
                    .help("Search the Photos Library for images that match the source image.")
                    .onChange(of: SearchOptions.Current.UsePhotos)
                    {
                        old, new in
                        if old != new
                        {
                            SearchOptions.Current.UsePhotos = new
                            if SearchOptions.Current.UsePhotos
                            {
                                OtherDirectory = false
                                SearchOptions.Current.UseSourceAsDirectory = false
                            }
                        }
                    }
                    Toggle(isOn: $OtherDirectory)
                    {
                        Text("Other")
                    }
                    .toggleStyle(.button)
                    .help("Use the directory list.")
                    .onChange(of: OtherDirectory)
                    {
                        old, new in
                        if old != new
                        {
                            OtherDirectory = new
                            if OtherDirectory
                            {
                                SearchOptions.Current.UsePhotos = false
                                SearchOptions.Current.UseSourceAsDirectory = false
                            }
                        }
                    }
                }
                .frame(width: 170)
                .padding(.leading, 4)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(height: 300)
    }
}

#Preview
{
    QuickOptionView(SearchOptions: SessionsModel())
}
