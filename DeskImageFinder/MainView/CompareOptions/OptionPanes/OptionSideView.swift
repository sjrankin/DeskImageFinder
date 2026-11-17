//
//  OptionSideView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import SwiftUI

struct OptionSideView: View
{
    //@State var SearchOptions: DataModel = DataModel()
    @State var SearchOptions: SessionsModel = SessionsModel()
    @AppStorage("StopAfter") var StopAfter: String = ""
    @AppStorage("SearchQuantity") var SearchQuantity: String = "\(Int.max)"
    @State var Exact: String = "0.0"
    @State var CloseEnough: String = "0.35"
    @AppStorage("MustMatchSourceSize") var MustMatchSourceSize: Bool = false
    @AppStorage("IgnoreColor") var IgnoreColor: Bool = false
    @State var ForceSize: Bool = false
    @AppStorage("CompareSize") var CompareSize: String = "128x128"
    @AppStorage("ExcludeBigImages") var ExcludeBigImages: Bool = true
    @AppStorage("MaxDirDepth") var MaxDirDepth: String = ""
    
    var body: some View
    {
        VStack
        {
            ScrollView
            {
                HStack
                {
                    Text("Exact match value")
                    TextField("", text: $Exact)
                        .frame(width: 60)
                        .onChange(of: Exact)
                    {
                        old, new in
                        Exact = new
                        if let newExact = Float(Exact)
                        {
                            SearchOptions.Current.ExactValue = newExact
                        }
                        else
                        {
                            SearchOptions.Current.ExactValue = 0.0
                        }
                    }
                    Text("0.0 to this value is an exact match.")
                        .font(.caption)
                    Spacer()
                }
                .help("Determines exact matches - any value equal or less than this is considered exact.")
                
                HStack
                {
                    Text("Similarity match value")
                    TextField("", text: $CloseEnough)
                        .frame(width: 60)
                        .onChange(of: CloseEnough)
                    {
                        old, new in
                        CloseEnough = new
                        if let newSimilar = Float(CloseEnough)
                        {
                            SearchOptions.Current.SimilarValue = newSimilar
                        }
                        else
                        {
                            SearchOptions.Current.SimilarValue = 0.35
                        }
                    }
                    Text("Greater than exact match value to this value is similar. Values greater than this are non-similar.")
                        .font(.caption)
                    Spacer()
                }
                .help("Determines the value range for similar images. Values greater than this value are considered dissimilar.")
                
                /*
                HStack
                {
                    Text("Search n files")
                    TextField("", text: $SearchQuantity)
                        .frame(width: 60)
                        .onChange(of: SearchQuantity)
                    {
                        old, new in
                        StopAfter = new
                        if let NewQuantity = Int(SearchQuantity)
                        {
                            SearchOptions.SearchQuantity = NewQuantity
                        }
                        else
                        {
                            SearchOptions.SearchQuantity = Int.max
                        }
                    }
                    Spacer()
                }
                .help("Stop searching after examining the specified number of files.")
                
                HStack
                {
                    Text("Stop after n matches")
                    TextField("", text: $StopAfter)
                        .frame(width: 60)
                        .onChange(of: StopAfter)
                    {
                        old, new in
                        StopAfter = new
                        if let newDepth = Int(StopAfter)
                        {
                            SearchOptions.SearchDepth = newDepth
                        }
                        else
                        {
                            SearchOptions.SearchDepth = Int.max
                        }
                    }
                    Spacer()
                }
                .help("Stop searching after matching the specified number of images.")
                */
                
                HStack
                {
                    Toggle(isOn: $IgnoreColor)
                    {
                        Text("Ignore color")
                    }
                    .toggleStyle(.switch)
                    .onChange(of: IgnoreColor)
                    {
                        old, new in
                        IgnoreColor = new
                        SearchOptions.Current.IgnoreColor = IgnoreColor
                    }
                    Spacer()
                }
                .help("Do all comparisons in grayscale. Good for morphological similarity.")
                
                HStack
                {
                    Toggle(isOn: $MustMatchSourceSize)
                    {
                        Text("Images sizes must be identical")
                    }
                    .toggleStyle(.switch)
                    .onChange(of: MustMatchSourceSize)
                    {
                        old, new in
                        MustMatchSourceSize = new
                        SearchOptions.Current.MustMatchSourceSize = MustMatchSourceSize
                    }
                    Spacer()
                }
                .help("Only search for similarity in images the same dimensions as the source image.")

                HStack
                {
                    Toggle(isOn: $ExcludeBigImages)
                    {
                        Text("Do not test large images")
                    }
                    .toggleStyle(.switch)
                    .onChange(of: ExcludeBigImages)
                    {
                        old, new in
                        ExcludeBigImages = new
                        SearchOptions.Current.ExcludeBigImage = ExcludeBigImages
                    }
                    Spacer()
                }
                .help("Do not test any image with any dimension greater than \(Int(SearchOptions.Current.DimensionTooBig)) pixels.")
                
                VStack
                {
                    HStack
                    {
                        Toggle(isOn: $ForceSize)
                        {
                            Text("Resize images for comparison")
                        }
                        .toggleStyle(.switch)
                        .onChange(of: ForceSize)
                        {
                            old, new in
                            ForceSize = new
                        }
                        Spacer()
                    }
                    HStack
                    {
                        Text("Resize images to")
                        TextField("", text: $CompareSize)
                            .frame(width: 120)
                            .onChange(of: CompareSize)
                        {
                            old, new in
                            CompareSize = new
                            SearchOptions.Current.UseSize = Utilities.GetDimensions(From: CompareSize)
                            print("SearchOptions.UseSize = \(String(describing: SearchOptions.Current.UseSize))")
                        }
                        .disabled(!ForceSize)
                        Spacer()
                    }
                    .padding(.leading, 10)
                }
                .help("Enter the size to use for comparison. Format is width,height or width x height.")
                
                Spacer()
            }
        }
        .padding()
        .frame(height: 350)
    }
}

#Preview
{
    OptionSideView()
}
