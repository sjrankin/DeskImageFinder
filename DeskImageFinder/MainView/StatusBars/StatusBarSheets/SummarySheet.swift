//
//  SummarySheet.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/6/25.
//

import SwiftUI
import Foundation

struct SummarySheet: View
{
    @Environment(\.dismiss) var Dismiss
    @State var Results: SessionsModel? = nil
    
    var body: some View
    {
        VStack
        {
            Text("Search Summary")
                .font(.largeTitle)
                .padding(.top, 4)
            Divider()
            if let Model = Results
            {
                VStack
                {
                    HStack
                    {
                        Text("Summary")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        Spacer()
                    }
                    HStack
                    {
                        Text("Exact matches")
                        Text("\(Model.Current.ExactCount)")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack
                    {
                        Text("Similar matches")
                        Text("\(Model.Current.SimilarCount)")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack
                    {
                        Text("Did not match")
                        Text("\(Model.Current.SearchCount - (Model.Current.ExactCount + Model.Current.SimilarCount))")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack
                    {
                        Text("Total comparisons")
                        Text("\(Model.Current.SearchCount)")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                Divider()
                VStack
                {
                    HStack
                    {
                        Text("Directories")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        Spacer()
                    }
                    Divider()
                    HStack
                    {
                        if let Results = Results
                        {
                            VStack
                            {
                                HStack
                                {
                                    DirectoryList(With: Results.Current, ForExact: true)
                                        .frame(width: 350, height: 100)
                                    Spacer()
                                }
                                Spacer()
                            }
                            Divider()
                            VStack
                            {
                                HStack
                                {
                                    DirectoryList(With: Results.Current, ForExact: false)
                                        .frame(width: 350, height: 100)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            else
            {
                Text("No data available.")
            }
            Divider()
            VStack
            {
                HStack
                {
                    Text("Search Criteria")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    Spacer()
                }
                if let Model = Results
                {
                    HStack
                    {
                        Text("Exact")
                            .bold()
                        Text("0.0 to")
                        Text("\(Model.Current.ExactValue)")
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    HStack
                    {
                        Text("Similar")
                            .bold()
                        Text("\(Model.Current.ExactValue) ≥")
                        Text("\(Model.Current.SimilarValue)")
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    HStack
                    {
                        Text("Ignore color")
                            .bold()
                        Text("\(Model.Current.IgnoreColor.YesNo)")
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    HStack
                    {
                        Text("Must match source image size")
                            .bold()
                        Text("\(Model.Current.MustMatchSourceSize)")
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    HStack
                    {
                        Text("Search file types")
                            .bold()
                        Text(MakeFileTypeList(From: Model))
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    HStack
                    {
                        Text("Search in")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                }
            }
            Divider()
            Spacer()
            Divider()
            Button("Close")
            {
                Dismiss()
            }
            .padding(4)
        }
        .frame(width: 800, height: 800)
    }
    
    func MakeFileTypeList(From Model: SessionsModel/*DataModel*/) -> String
    {
        var stemp = ""
        if Model.Current.SearchJPG
        {
            stemp = "JPG"
        }
        if Model.Current.SearchPNG
        {
            if !stemp.isEmpty
            {
                stemp += " "
            }
            stemp += "PNG"
        }
        if Model.Current.SearchTIFF
        {
            if !stemp.isEmpty
            {
                stemp += " "
            }
            stemp += "TIF"
        }
        if Model.Current.SearchWEBP
        {
            if !stemp.isEmpty
            {
                stemp += " "
            }
            stemp += "WEBP"
        }
        if Model.Current.SearchGIF
        {
            if !stemp.isEmpty
            {
                stemp += " "
            }
            stemp += "GIF"
        }
        if Model.Current.SearchHEIC
        {
            if !stemp.isEmpty
            {
                stemp += " "
            }
            stemp += "HEIC"
        }

        return stemp
    }
    
    @ViewBuilder func DirectoryList(With Model: DataModel,
                                    ForExact: Bool) -> some View
    {
        VStack
        {
            HStack
            {
                Text(ForExact ? "Exact" : "Similar")
                    .bold()
                    .padding(.horizontal, 4)
                Spacer()
            }
            Divider()
            VStack
            {
                ScrollView
                {
                    if ForExact
                    {
                        ForEach(Array(Model.ExactDirectories), id: \.self)
                        {
                            SomeDir in
                            DirectoryEntry(For: SomeDir)
                        }
                    }
                    else
                    {
                        ForEach(Array(Model.SimilarDirectories), id: \.self)
                        {
                            SomeDir in
                            DirectoryEntry(For: SomeDir)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder func DirectoryEntry(For: URL) -> some View
    {
        HStack
        {
            let OnlyDir = For.absoluteString.replacingOccurrences(of: "/Volumes/", with: "")
            Text(OnlyDir)
            Spacer()
            Button("", systemImage: "folder")
            {
                let SemiFinal = "file:///Volumes/" + For.absoluteString + "/"
                if let Final = URL(string: SemiFinal)
                {
                    print("Opening: \(Final.absoluteString)")
                    NSWorkspace.shared.open(Final)
                }
            }
            .help("Open the directory in a Finder window.")
            .buttonStyle(.borderless)
            .foregroundStyle(.blue)
        }
        .padding(.horizontal, 4)
    }
}

#Preview
{
    SummarySheet()
}

extension Bool
{
    var YesNo: String
    {
        return self ? "Yes" : "No"
    }
}
