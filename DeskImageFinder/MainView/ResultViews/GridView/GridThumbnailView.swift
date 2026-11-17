//
//  GridThumbnailView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

struct GridThumbnailView: View
{
    @State var image: NSImage? = nil
    @State var ImageURL: URL? = nil
    @State var ImageName: String = ""
    @State var DirectoryName: String = ""
    @State var score: Float = 0.0
    @State var width: Double = 120.0
    @State var height: Double = 120.0
    @State var ShowLargerImage: Bool = false
    @State var ContextLargerImage: Bool = false
    @State var Search: DataModel = DataModel()
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            if let FinalImage = image
            {
                VStack(alignment: .center)
                {
                    Spacer()
                    Image(nsImage: FinalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .padding(-4)
                    VStack
                    {
                        if !DirectoryName.isEmpty
                        {
                            HStack
                            {
                                Text(DirectoryName)
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 12))
                                    .padding(2)
                                    .help(ImageName)
                                Spacer()
                            }
                        }
                        if !ImageName.isEmpty
                        {
                            HStack
                            {
                                Text(ImageName)
                                    .font(.system(size: 12))
                                    .padding(.leading, 2)
                                    .help(ImageName)
                                Spacer()
                            }
                        }
                        HStack
                        {
                            SimilaritySymbol(For: score,
                                             Close: Search.ExactValue,//CloseValue,
                                             Far: Search.SimilarValue)//FarValue)
                            Text("\(NiceScore(score))")
                                .font(.system(size: 10.0))
                            Spacer()
                        }
                        .padding(.top, -4)
                    }
                    .frame(height: (geometry.size.height - height) + 14)
                    .background(Color(NSColor(calibratedRed: 0.69, green: 0.69, blue: 0.69, alpha: 0.85)))
                }
                .onTapGesture(count: 2)
                {
                    ShowLargerImage.toggle()
                    //print("**** ShowLargerImage=\(ShowLargerImage)")
                }
                .sheet(isPresented: $ShowLargerImage)
                {
                    //let _ = print(">>>> ShowLargerImage=\(ShowLargerImage)")
                    FullImageView(FullImage: FinalImage,
                                  ImageURL: ImageURL)
                }
                /*
                .contextMenu
                {
                    Button("View image")
                    {
                        ContextLargerImage.toggle()
                        print("++++ ContextLargerImage=\(ContextLargerImage)")
                    }
                    .sheet(isPresented: $ContextLargerImage)
                    {
                        let _ = print(">*>* ContextLargerImage=\(ContextLargerImage)")
                        FullImageView(FullImage: FinalImage,
                                      ImageURL: ImageURL)
                    }
                }
                 */
                .background(Color(NSColor(calibratedRed: 0.72, green: 0.72, blue: 0.72, alpha: 0.85)))
                .cornerRadius(5.0)
                .overlay(RoundedRectangle(cornerRadius: 5.0)
                    .stroke(.gray.opacity(0.65), lineWidth: 0.5))
            }
        }
    }
    
    @ViewBuilder func SimilaritySymbol(For Score: Float,
                                       Close: Float,
                                       Far: Float,
                                       SymbolSize: CGFloat = 12.0) -> some View
    {
        let TestScore = abs(Score)
        if TestScore == 0.0
        {
            Image(systemName: "circle.fill")
                .resizable()
                .foregroundStyle(.green, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
        else if abs(TestScore) >= Far
        {
            Image(systemName: "triangle.fill")
                .resizable()
                .foregroundStyle(.red, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
        else
        {
            Image(systemName: "square.fill")
                .resizable()
                .foregroundStyle(.yellow, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
    }
    
    func NiceScore(_ score: Float) -> String
    {
        return String(format: "%.\(4)f", score)
    }
}

struct GridThumbnailView_Debug: View
{
    @Binding var image: NSImage?
    @State var ImageURL: URL? = nil
    @State var ImageName: String = ""
    @State var score: Float = 0.0
    @State var width: Double = 120.0
    @State var height: Double = 120.0
    @State var CloseValue: Float = 0.1
    @State var FarValue: Float = 0.4
    @State var ShowLargerImage: Bool = false
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            if let FinalImage = image
            {
                VStack(alignment: .center)
                {
                    Spacer()
                    Image(nsImage: FinalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                    VStack
                    {
                        if !ImageName.isEmpty
                        {
                            HStack
                            {
                                Text(ImageName)
                                    .font(.system(size: 12))
                                    .padding(2)
                                Spacer()
                            }
                        }
                        HStack
                        {
                            SimilaritySymbol(For: score,
                                             Close: CloseValue,
                                             Far: FarValue)
                            Text("\(NiceScore(score))")
                                .font(.system(size: 10.0))
                            Spacer()
                        }
                    }
                    .frame(width: width, height: geometry.size.height - height)
                    .background(Color(NSColor(calibratedRed: 0.69, green: 0.69, blue: 0.69, alpha: 0.85)))
                }
                .onTapGesture(count: 2)
                {
                    ShowLargerImage.toggle()
                }
                .sheet(isPresented: $ShowLargerImage)
                {
                    FullImageView(FullImage: FinalImage,
                                  ImageURL: ImageURL)
                }
                .background(Color(NSColor(calibratedRed: 0.72, green: 0.72, blue: 0.72, alpha: 0.85)))
                .cornerRadius(5.0)
                .overlay(RoundedRectangle(cornerRadius: 5.0)
                    .stroke(.gray.opacity(0.65), lineWidth: 0.5))
            }
        }
    }
    
    @ViewBuilder func SimilaritySymbol(For Score: Float,
                                       Close: Float,
                                       Far: Float,
                                       SymbolSize: CGFloat = 12.0) -> some View
    {
        let TestScore = abs(Score)
        if TestScore == 0.0
        {
            Image(systemName: "circle.fill")
                .resizable()
                .foregroundStyle(.green, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
        else if abs(TestScore) >= Far
        {
            Image(systemName: "triangle.fill")
                .resizable()
                .foregroundStyle(.red, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
        else
        {
            Image(systemName: "square.fill")
                .resizable()
                .foregroundStyle(.yellow, .white)
                .frame(width: SymbolSize, height: SymbolSize)
                .padding(2)
        }
    }
    
    func NiceScore(_ score: Float) -> String
    {
        return String(format: "%.\(4)f", score)
    }
}

#Preview
{
    GridThumbnailView(image: NSImage(named: "Bob"))
}
