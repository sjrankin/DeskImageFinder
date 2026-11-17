//
//  PHashTest.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/7/25.
//

import SwiftUI

struct PHashTest: View
{
    @Environment(\.dismiss) var Dismiss
    @State var SourceURL: URL? = nil
    @State var Loader = ImageLoader()
    var PHasher = PHash()
    @State var TestResult: Double? = nil
    
    var body: some View
    {
        VStack
        {
            Text("PHash Test")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            Button("Load and Go")
            {
                let Panel = NSOpenPanel()
                Panel.allowsMultipleSelection = false
                Panel.canChooseDirectories = true
                if Panel.runModal() == .OK
                {
                    self.TestResult = nil
                    self.SourceURL = Panel.url
                    Task
                    {
                        await self.Loader.AsyncLoadImage(with: self.SourceURL!)
                        if let Target = self.Loader.image
                        {
//                            TestResult = await PHasher.Compute(Target)
                            TestResult = await PHasher.Compute2(Target)
                        }
                    }
                }
            }
            VStack
            {
                if let TestImage = self.Loader.image
                {
                    Image(nsImage: TestImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320, height: 320)
                    if let Result = TestResult
                    {
                        HStack
                        {
                            Text("PHash:")
                            Text("\(Result)")
                                .bold()
                        }
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
    }
}

#Preview
{
    PHashTest()
}
