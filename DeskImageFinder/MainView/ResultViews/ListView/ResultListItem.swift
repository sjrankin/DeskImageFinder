//
//  ResultListItem.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/7/25.
//

import SwiftUI

struct ResultListItem: View
{
    @State var image: NSImage? = nil
    @State var ImageURL: URL? = nil
    @State var ImageName: String = ""
    @State var Score: Float = 0.0
    @State var ShowLargerImage: Bool = false
    @State var Display: DisplayModel
    @State var Search: DataModel = DataModel()
    
    var body: some View
    {
        HStack
        {
            if let image = image
            {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: ThumbnailSize(With: Display),
                           height: ThumbnailSize(With: Display))
                    .padding(.horizontal, 4)
            }
            HStack
            {
                SimilaritySymbol(For: Score,
                                 Close: Search.ExactValue,//CloseValue,
                                 Far: Search.SimilarValue)//FarValue)
                Text("\(NiceScore(Score))")
                    .font(.system(size: ScoreFontsize(With: Display)))
            }
            .padding(.horizontal, 4)
            HStack
            {
                Text(ImageName)
                    .font(.system(size: NameFontSize(With: Display)))
                    .bold()
            }
            Spacer()
        }
        .onTapGesture(count: 2)
        {
            ShowLargerImage.toggle()
        }
        .sheet(isPresented: $ShowLargerImage)
        {
            FullImageView(FullImage: image,
                          ImageURL: ImageURL)
        }
    }
    
    func ThumbnailSize(With: DisplayModel) -> CGFloat
    {
        switch With.ItemSize
        {
            case 0:
                return 56.0
                
            case 1:
                return 84.0
                
            case 2:
                return 116.0
                
            default:
                return 56.0
        }
    }
    
    func ScoreFontsize(With: DisplayModel) -> CGFloat
    {
        switch With.ItemSize
        {
            case 0:
                return 12.0
                
            case 1:
                return 20.0
                
            case 2:
                return 36.0
                
            default:
                return 12.0
        }
    }
    
    func NameFontSize(With: DisplayModel) -> CGFloat
    {
        switch With.ItemSize
        {
            case 0:
                return 14.0
                
            case 1:
                return 24.0
                
            case 2:
                return 40.0
                
            default:
                return 12.0
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
    ResultListItem(Display: DisplayModel())
}
