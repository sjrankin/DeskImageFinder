//
//  TestStuff.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/22/25.
//

import SwiftUI

struct TestStuff: View
{
    @State var SearchOptions: SessionsModel = SessionsModel()
    @State var SelectedURLs: [URL] = []
    @State var RunPHashTest: Bool = false
    @State var ShowDirectoryTree: Bool = false
    @State var ShowHierarchicalNodeTest: Bool = false
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Button("Test PHash")
                {
                    RunPHashTest.toggle()
                }
                .sheet(isPresented: $RunPHashTest)
                {
                    PHashTest()
                }
                Spacer()
            }
            .padding()
            HStack
            {
                Button("Directory Tree")
                {
                    ShowDirectoryTree.toggle()
                }
                .sheet(isPresented: $ShowDirectoryTree)
                {
                    DirectoryTreeTest()
                }
                Spacer()
            }
            .padding()
            HStack
            {
                Button("Hierarchical Node View")
                {
                    ShowHierarchicalNodeTest.toggle()
                }
                .sheet(isPresented: $ShowHierarchicalNodeTest)
                {
                    let Test =
                    [
                        TestData.MakeTestData(0),
                        TestData.MakeTestData(1),
                        TestData.MakeTestData(2),
                        TestData.MakeTestData(3)
                    ]
                    HierarchicalNodeTestSheet(TestData: Test)
                }
                Spacer()
            }
            .padding()
            HStack
            {
                Button("Select Directory")
                {
                    let Panel = NSOpenPanel()
                    Panel.allowsMultipleSelection = false
                    Panel.canChooseDirectories = true
                    Panel.canCreateDirectories = false
                    Panel.canChooseFiles = false
                    if Panel.runModal() == .OK
                    {
                        if let DirURL = Panel.url
                        {
                            self.SelectedURLs.append(DirURL)
                        }
                    }
                }
                Button("Clear")
                {
                    SelectedURLs.removeAll()
                }
                Spacer()
            }
            .padding()
            Spacer()
            if SelectedURLs.count == 1
            {
                let Dirs = Files.GetSubDirectoriesIn(Directory: SelectedURLs.first!)
                Text("Sub-Directories")
                    .font(.caption2)
                    .padding(0)
                ScrollView
                {
                    ForEach(Dirs, id: \.self)
                    {
                        dir in
                        HStack
                        {
                            Text(Files.DirectoryFrom(dir, FromDirectory: true))
                            Spacer()
                        }
                    }
                }
                Divider()
                let LookFor = Utilities.MakeExtensionArray(JPG: true, PNG: true, GIF: false, TIFF: false, WEBP: false)
                let RelevantURLs = Files.GetFilesMatching(Extensions: LookFor, In: SelectedURLs.first!).sorted(by: {$0.absoluteString.lowercased() < $1.absoluteString.lowercased()})
                Text("Files of Type")
                    .font(.caption2)
                    .padding(0)
                ScrollView
                {
                    ForEach(RelevantURLs, id: \.self)
                    {
                        SomeFile in
                        HStack
                        {
                            Text(Files.NameFrom(SomeFile))
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 500)
    }
}

#Preview
{
    TestStuff()
}
