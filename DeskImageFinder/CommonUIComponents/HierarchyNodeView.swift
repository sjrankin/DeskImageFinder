//
//  HierarchyNodeView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/29/25.
//

import SwiftUI

struct HierarchyNodeView: View
{
    @State var Result: SimilarityResult? = nil
    @State var FinalImage: NSImage = NSImage(imageLiteralResourceName: "Bob")
    @State var ImageName: String = "Bob"
    @State var ShowImageInfo: Bool = false
    @Binding var SelectedView: UUID
    @Binding var ViewSize: Int
    @State var Loader = ImageLoader()
    let SelectedColor = Color(nsColor: NSColor.selectedTextBackgroundColor)
    let NormalColor = Color(nsColor: NSColor.alternatingContentBackgroundColors.first!)
    
    var body: some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                VStack(alignment: .center)
                {
                    Spacer()
                    HStack
                    {
                        Image(nsImage: FinalImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: GetSize(For: .ImageSize, With: ViewSize),
                                   height: GetSize(For: .ImageSize, With: ViewSize))
                            .padding(-4)
                        Divider()
                        VStack
                        {
                            if !ImageName.isEmpty
                            {
                                HStack
                                {
                                    Text(ImageName)
                                        .font(.system(size: GetSize(For: .FontSize, With: ViewSize),
                                                      weight: .bold))
                                        .padding(.leading, 2)
                                        .help(ImageName)
                                    Spacer()
                                }
                            }
                            if let Result = Result
                            {
                                HStack
                                {
                                    SimilaritySymbol(For: Result.Score,
                                                     Close: 0.0,
                                                     Far: 0.4)
                                    Text("\(NiceScore(Result.Score))")
                                        .font(.system(size: GetSize(For: .ScoreFontSize, With: ViewSize)))
                                    Spacer()
                                }
                                .padding(.top, -4)
                            }
                        }
                        Divider()
                        VStack
                        {
                            Spacer()
                            HStack
                            {
                                Button(action:
                                        {
                                    ShowImageInfo.toggle()
                                },
                                       label:
                                        {
                                    Image(systemName: "info.circle")
                                })
                                .buttonStyle(.borderless)
                                .foregroundStyle(.blue)
                                .help("Displays information about the image.")
                                .sheet(isPresented: $ShowImageInfo)
                                {
                                    let _ = print("info!")
                                    if let FileURL = self.Result?.Path
                                    {
                                        ImageInfoView(ImageURL: FileURL,
                                                      ActualImage: ImageLoader.LoadImage(From: FileURL))
                                    }
                                }
                            }
                            .frame(width: GetSize(For: .InfoColumnWidth, With: ViewSize))
                            Spacer()
                        }
                    }
                }
                .frame(height: GetSize(For: .MainFrameHeight, With: ViewSize))
                .padding()
                Spacer()
            }
            .padding(.bottom, -16)
            .padding(.top, -24)
            .background(SelectedView == Result!.id ? SelectedColor : NormalColor)
            Spacer()
        }
    }
    
    @ViewBuilder func SimilaritySymbol(For Score: Float,
                                       Close: Float,
                                       Far: Float) -> some View
    {
        let TestScore = abs(Score)
        if TestScore == 0.0
        {
            Image(systemName: "circle.fill")
                .resizable()
                .foregroundStyle(.green, .white)
                .frame(width: GetSize(For: .SymbolSize, With: ViewSize),
                       height: GetSize(For: .SymbolSize, With: ViewSize))
                .padding(2)
        }
        else if abs(TestScore) >= Far
        {
            Image(systemName: "triangle.fill")
                .resizable()
                .foregroundStyle(.red, .white)
                .frame(width: GetSize(For: .SymbolSize, With: ViewSize),
                       height: GetSize(For: .SymbolSize, With: ViewSize))
                .padding(2)
        }
        else
        {
            Image(systemName: "square.fill")
                .resizable()
                .foregroundStyle(.yellow, .white)
                .frame(width: GetSize(For: .SymbolSize, With: ViewSize),
                       height: GetSize(For: .SymbolSize, With: ViewSize))
                .padding(2)
        }
    }
    
    func NiceScore(_ score: Float) -> String
    {
        return String(format: "%.\(4)f", score)
    }
    
    func PrettyFileName(_ FileURL: URL) -> String
    {
        let last = FileURL.lastPathComponent
        return last
    }
    
    func GetSize(For: UIElements, With Size: Int) -> CGFloat
    {
        var ReturnedValue: CGFloat? = nil
        switch Size
        {
            case -1:
                ReturnedValue = TeenyDictionary[For]
                
            case 0:
                ReturnedValue = SmallDictionary[For]
                
            case 1:
                ReturnedValue = MediumDictionary[For]
                
            case 2:
                ReturnedValue = LargeDictionary[For]
                
            default:
                ReturnedValue = nil
        }
        if let Value = ReturnedValue
        {
            return Value
        }
        return 0.0
    }
    
    let TeenyDictionary: [UIElements: CGFloat] =
    [
        .ImageSize: 36,
        .FontSize: 11,
        .SymbolSize: 8,
        .ScoreFontSize: 8,
        .MainFrameHeight: 52,
        .InfoColumnWidth: 20
    ]
    
    let SmallDictionary: [UIElements: CGFloat] =
    [
        .ImageSize: 48,
        .FontSize: 10,
        .SymbolSize: 10,
        .ScoreFontSize: 10,
        .MainFrameHeight: 64,
        .InfoColumnWidth: 20
    ]
    
    let MediumDictionary: [UIElements: CGFloat] =
    [
        .ImageSize: 64,
        .FontSize: 14,
        .SymbolSize: 12,
        .ScoreFontSize: 12,
        .MainFrameHeight: 80,
        .InfoColumnWidth: 36
    ]
    
    let LargeDictionary: [UIElements: CGFloat] =
    [
        .ImageSize: 96,
        .FontSize: 18,
        .SymbolSize: 14,
        .ScoreFontSize: 14,
        .MainFrameHeight: 110,
        .InfoColumnWidth: 36
    ]
    
    enum UIElements
    {
        case ImageSize
        case FontSize
        case SymbolSize
        case ScoreFontSize
        case MainFrameHeight
        case InfoColumnWidth
    }
}

#Preview
{
    @Previewable @State var SomeResult = SimilarityResult(Path: URL(string: "/fred/fastbender")!,
                                                          Score: 0.25,
                                                          TargetImage: NSImage(imageLiteralResourceName: "Bob"),
                                                          Tag: "Bob")
    @Previewable @State var Selected = UUID()
    @Previewable @State var ViewSize: Int = 1
    HierarchyNodeView(Result: SomeResult,
                      FinalImage: NSImage(imageLiteralResourceName: "Bob"),
                      ImageName: "Bob",
                      SelectedView: $Selected,
                      ViewSize: $ViewSize)
}
