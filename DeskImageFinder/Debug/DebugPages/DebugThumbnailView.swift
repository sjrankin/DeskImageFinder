//
//  DebugThumbnailView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/25/25.
//

import SwiftUI

struct DebugThumbnailView: View
{
    @State var CurrentImage: String = "Bob"
    @State var ImageToView: NSImage? = NSImage(named: "Bob")
    @State var SampleImages: [SampleImage] = []
    let ImageNames =
    [
        "16Cents", "24Cents", "Bob", "Bozo",
        "Cheese", "Clocks", "Disgutipated",
        "Dragon", "EEK", "Eeee", "EyeBall", "Frankfurter",
        "Future", "Gorn", "Horror", "Ignore", "Lena", "Naomi",
        "No", "Oh", "Puzzle", "splonk", "Sweaty",
        "TheTick", "Universe", "What", "WhyMe",
        "Wolverton1", "Wolverton2", "Wolverton3", "Yokai"
    ]
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            HStack
            {
                VStack
                {
                    List
                    {
                        ForEach(SampleImages, id: \.self)
                        {
                            SampleImage in
                            HStack
                            {
                                Text(SampleImage.Name)
                                Spacer()
                            }
                            .background(CurrentImage == SampleImage.Name ? .yellow : .clear)
                            .padding(.horizontal, 4)
                                .highPriorityGesture(
                                    TapGesture().onEnded
                                    {
                                        CurrentImage = SampleImage.Name
                                    }
                                )
                        }
                    }
                }
                .frame(width: geometry.size.width * 0.3)
                VStack
                {
                        GridThumbnailView_Debug(image: $ImageToView,
                                                ImageName: "Big Bad Bob",
                                                score: 0.0)
                            .frame(width: 160, height: 160)
                            .onChange(of: CurrentImage)
                    {
                        old, new in
                        self.ImageToView = self.ImageFor(Name: new)!
                    }
                }
                .frame(width: geometry.size.width *  0.7)
            }
        }
        .frame(height: 400)
        .onAppear
        {
            PopulateSampleImages()
        }
    }
    
    func ImageFor(Name: String) -> NSImage?
    {
        if let TheImage = SampleImages.filter({$0.Name == Name}).first?.Actual
        {
            return TheImage
        }
        return nil
    }
    
    func PopulateSampleImages()
    {
        for ImageName in ImageNames
        {
            if let AddMe = MakeSampleImage(ImageName)
            {
                SampleImages.append(AddMe)
            }
        }
        return
    }
    
    func MakeSampleImage(_ Name: String) -> SampleImage?
    {
        guard let TheImage = NSImage(named: Name) else
        {
            return nil
        }
        return SampleImage(Name: Name, Actual: TheImage)
    }
}

#Preview
{
    DebugThumbnailView()
}

struct SampleImage: Identifiable, Hashable, Equatable
{
    let id = UUID()
    let Name: String
    let Actual: NSImage
}
