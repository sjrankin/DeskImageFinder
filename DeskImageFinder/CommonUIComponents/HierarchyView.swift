//
//  HierarchyView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/27/25.
//

import SwiftUI

struct HierarchyView: View
{
    @State var ParentNode: DirectoryNode? = nil
    @State var SearchModel: SessionsModel? = nil
    @State var Display: DisplayModel? = nil
    let LightColor = NSColor.quaternarySystemFill
    let DarkColor = NSColor.windowBackgroundColor
    
    var body: some View
    {
        if let Parent = ParentNode
        {
            MakeHierarchyView(From: Parent)
        }
    }
    
    @ViewBuilder func MakeHierarchyView(From Node: DirectoryNode) -> some View
    {
        ScrollView
        {
            PopulateHierarchyView(From: Node)
                .background(Color(nsColor: LightColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 0.5))
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .background(Color(nsColor: LightColor))
        .padding(-8)
    }
    
    @ViewBuilder func PopulateHierarchyView(From Node: DirectoryNode,
                                            Level: Int = 0) -> some View
    {
        AnyView(VStack
        {
            DisclosureGroup(content:
                                {
                ForEach(Node.Children.sorted(), id: \.self)
                {
                    child in
                    PopulateHierarchyView(From: child, Level: Level + 1)
                        .background(Level.isMultiple(of: 2) ? Color(nsColor: DarkColor) : Color(nsColor: LightColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 0.5))
                        .padding(.vertical, 2)
                        .padding(.leading, 2)
                        .padding(.trailing, 4)
                }
                FileList(From: Node)
            }, label:
                                {
                MakeDirectoryTitle(From: Node.DirectoryURL,
                                   Last: Level == 0 ? false : true)
            })
            .padding(.leading, CGFloat((Level + 1) * 8))
        })
    }
    
    @ViewBuilder func FileList(From Node: DirectoryNode) -> some View
    {
        let FilesInDirectory = Node.Files.sorted { (lhs: URL2, rhs: URL2) in
            return lhs.url.lastPathComponent < rhs.url.lastPathComponent
        }
        ForEach(FilesInDirectory, id: \.id)
        {
            item in
            HStack
            {
                Text(PrettyFileName(item.url))
                Spacer()
            }
        }
        /*
        ForEach(Array(Node.Files.enumerated()), id: \.offset)
        {
            index, item in
            HStack
            {
                Text(PrettyFileName(item.url))
                Spacer()
            }
        }
         */
    }
    
    /// Return a directory title view.
    /// - Parameter With: The name of the directory.
    /// - Returns: View with the title and a pretty header image.
    @ViewBuilder func MakeDirectoryTitle(With Name: String) -> some View
    {
        HStack
        {
            Image(systemName: "folder")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.blue)
            Text(Name)
                .bold()
            Spacer()
        }
    }
    
    /// Return a directory title view.
    /// - Parameter From: The URL of the directory.
    /// - Parameter Last: If `true`, only the immediate directory name is returned, not the path.
    /// Otherwise, you get everything.
    /// - Returns: View with the title and a pretty header image.
    @ViewBuilder func MakeDirectoryTitle(From: URL?,
                                         Last: Bool = true) -> some View
    {
        if let From = From
        {
            HStack
            {
                Image(systemName: "folder")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.blue)
                Text(PrettyPrintDirectory(Path: From, LastOnly: Last))
                    .bold()
                Spacer()
            }
        }
        else
        {
            EmptyView()
        }
    }
    
    /// Return only the directory portion of the passed URL.
    /// - Parameter Path: The full URL to the directory.
    /// - Parameter LastOnly: If true, only the directory is returned otherwise the entire path is returned
    /// (but pretty-printed).
    func PrettyPrintDirectory(Path: URL, LastOnly: Bool) -> String
    {
        if LastOnly
        {
            let OnlyDir = Path.lastPathComponent
            return OnlyDir
        }
        else
        {
            return Files.PrettyNameWithoutScheme(Path)
        }
    }
    
    @ViewBuilder func MakeResultView(With Result: SimilarityResult) -> some View
    {
        HStack
        {
            GridThumbnailView()
        }
    }
    
    func PrettyFileName(_ FileURL: URL) -> String
    {
        let last = FileURL.lastPathComponent
        return last
    }
}

#Preview
{
    HierarchyView()
}
