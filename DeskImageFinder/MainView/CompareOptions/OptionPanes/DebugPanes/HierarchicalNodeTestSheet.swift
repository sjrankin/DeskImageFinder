//
//  HierarchicalNodeTestSheet.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/30/25.
//

import SwiftUI

struct HierarchicalNodeTestSheet: View
{
    @Environment(\.dismiss) var Dismiss
    @State var TestData: [SimilarityResult]
    @State var SelectedID: UUID = UUID()
    @State var Test1: SimilarityResult!
    @State var Test2: SimilarityResult!
    @State var Test3: SimilarityResult!
    @State var Test4: SimilarityResult!
    @State var ItemSize: Int = 1
    
    var body: some View
    {
        VStack
        {
            Text("Hierarchical Node Test")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            HStack
            {
                Picker("", selection: $ItemSize)
                {
                    Text("Teeny")
                        .tag(-1)
                    Text("Small")
                        .tag(0)
                    Text("Medium")
                        .tag(1)
                    Text("Large")
                        .tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
                .onChange(of: ItemSize)
                {
                    _, new in
                    ItemSize = new
                }
                Spacer()
            }
            .padding(.horizontal)
            Divider()
            VStack
            {
                ScrollView
                {
                    ForEach(TestData)
                    {
                        item in
                        HierarchyNodeView(Result: item,
                                          FinalImage: item.TargetImage,
                                          ImageName: item.Tag,
                                          SelectedView: $SelectedID,
                                          ViewSize: $ItemSize)
                        .onTapGesture
                        {
                            SelectedID = item.id
                        }
                        Divider()
                    }
                }
            }
            Divider()
            Button("Close")
            {
                Dismiss()
            }
            .padding(4)
            .padding(.bottom, 6)
        }
        .frame(width: 800, height: 700)
    }
    
    
}

class TestData
{
    static func MakeTestData(_ Index: Int) -> SimilarityResult
    {
        var ImageName = "Bob"
        switch Index
        {
            case 0:
                ImageName = "Bozo"
            case 1:
                ImageName = "Eeee"
            case 2:
                ImageName = "Ignore"
            case 3:
                ImageName = "Yokai"
            default:
                ImageName = "Bob"
        }
        let results = SimilarityResult(Path: URL(string: "/fred/fastbender")!,
                                       Score: 0.25,
                                       TargetImage: NSImage(imageLiteralResourceName: ImageName),
                                       Tag: ImageName)
        return results
    }
}

#Preview
{
    @Previewable @State var Test =
    [
        TestData.MakeTestData(0),
        TestData.MakeTestData(1),
        TestData.MakeTestData(2),
        TestData.MakeTestData(3)
    ]
    
    HierarchicalNodeTestSheet(TestData: Test)
}
