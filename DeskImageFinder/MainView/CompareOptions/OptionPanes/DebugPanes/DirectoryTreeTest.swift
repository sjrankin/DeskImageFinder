//
//  DirectoryTreeTest.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/24/25.
//

import SwiftUI

struct DirectoryTreeTest: View
{
    @Environment(\.dismiss) var Dismiss
    @State var RootDirectory: URL? = nil
    @State var Enumerating: Bool = false
    @State var TopNode: DirectoryNode = DirectoryNode()
    @State var HaveData: Bool = false
    @State var StructureEnabled: Bool = false
    @State var ShowWaiting: Bool = false
    
    var body: some View
    {
        VStack
        {
            Text("Directory Tree Test")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            HStack
            {
                Button("Select Directory")
                {
                    StructureEnabled = true
                    let Panel = NSOpenPanel()
                    Panel.allowsMultipleSelection = false
                    Panel.canChooseDirectories = true
                    Panel.canCreateDirectories = false
                    Panel.canChooseFiles = false
                    if Panel.runModal() == .OK
                    {
                        RootDirectory = Panel.url
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            HStack
            {
                Text("Root Directory")
                if let Root = RootDirectory
                {
                    Text(Files.PrettyNameWithoutScheme(Root))
                        .bold()
                }
                Spacer()
            }
            .padding(.horizontal)
            if let Root = RootDirectory
            {
                VStack
                {
                    HStack
                    {
                        Button("Structure")
                        {
                            StructureEnabled = false
                            ShowWaiting = true
                            Task
                            {
                                TopNode = DirectoryNode(DirectoryURL: Root)
                                TopNode = await Files.MakeDirectoryTree(Directory: Root)
                                HaveData.toggle()
                                ShowWaiting = false
                            }
                        }
                        .disabled(!StructureEnabled)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            Divider()
            if HaveData
            {
                HierarchyView(ParentNode: TopNode)
                    .frame(width: 780, height: 500)
            }
            else
            {
                if ShowWaiting
                {
                    ProgressView()
                }
            }
            Spacer()
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
    
    @ViewBuilder func ShowBusy() -> some View
    {
        VStack
        {
            Spacer()
            HStack
            {
                Spacer()
                ProgressView()
                    .tint(.indigo)
                    .controlSize(.large)
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview
{
    DirectoryTreeTest()
}
