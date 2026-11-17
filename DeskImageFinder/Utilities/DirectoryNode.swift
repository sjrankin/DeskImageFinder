//
//  DirectoryNode.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/28/25.
//

import Foundation

// MARK: - DirectoryNode

/// Struct to extend `URL` to be usable in an array with SwiftUI.
struct URL2: Identifiable, Hashable
{
    /// ID of the structure.
    let id = UUID()
    /// The URL payload.
    var url: URL
    {
        didSet
        {
            WasAssigned = true
        }
    }
    var WasAssigned: Bool = false
}

/// Contains information on one directory and an array of sub-directories directly under the directory.
struct DirectoryNode: Identifiable, Hashable, Comparable
{
    /// Required for SwiftUI
    let id = UUID()
    /// URL of the directory.
    var DirectoryURL: URL? = nil
    /// Files in the directory.
    var Files: [URL2] = [URL2]()
    /// Sub-directories.
    var Children: [DirectoryNode] = []
    /// Search results for a given directory.
    var Results: [SimilarityResult]?
    
    /// Implements `Comparable`.
    static func < (lhs: DirectoryNode, rhs: DirectoryNode) -> Bool
    {
        return lhs.PrettyNameWithoutScheme < rhs.PrettyNameWithoutScheme
    }
    
    /// Returns a pretty version of the contents of `DirectoryURL`.
    var PrettyName: String
    {
        if let TheURL = DirectoryURL
        {
            return TheURL.absoluteString.removingPercentEncoding ?? TheURL.absoluteString
        }
        else
        {
            return ""
        }
    }
    
    /// Returns a prettified URL with percent encoding and schemes removed.
    var PrettyNameWithoutScheme: String
    {
        if let TheURL = DirectoryURL
        {
            guard var components = URLComponents(string: TheURL.absoluteString) else
            {
                return ""
            }
            components.scheme = nil
            guard var working = components.string else
            {
                return ""
            }
            working = working.replacingOccurrences(of: "///Volumes", with: "")
            return working.removingPercentEncoding ?? working
        }
        return ""
    }
    
    /// Add a file to the array of files.
    /// - Parameter Address: URL of the file.
    mutating func AddFile(_ Address: URL)
    {
        Files.append(URL2(url: Address))
    }
    
    /// Add a sub-directory to the array of sub-directories.
    /// - Parameter Address: URL of the sub-directory.
    mutating func AddChild(_ Address: URL)
    {
        Children.append(DirectoryNode(DirectoryURL: Address, Files: [], Children: []))
    }
    
    /// Add a child node to the array of sub-directories.
    /// - Parameter NewNode: New sub-directory node.
    mutating func AddChildNode(_ NewNode: DirectoryNode)
    {
        Children.append(NewNode)
    }
    
    /// Return a flat map of the contents of the current `DirectoryNode` and all children.
    /// - Parameter: SkipEmptyDirectories: If true, empty directories will not be returned (though any sub-directories
    /// with files will be). Defaults to `false`.
    /// - Returns: Array of `DirectoryNode`s.
    func FlatMap(SkipEmptyDirectories Skip: Bool = false) -> [DirectoryNode]
    {
        return FlatMap(From: self)
    }
    
    /// Return a flat map of the contents of the passed `DirectoryNode` and all its children.
    /// - Parameter: SkipEmptyDirectories: If true, empty directories will not be returned (though any sub-directories
    /// with files will be). Defaults to `false`.
    /// - Returns: Array of `DirectoryNode`s.
    func FlatMap(From Node: DirectoryNode,
                 SkipEmptyDirectories Skip: Bool = false) -> [DirectoryNode]
    {
        var Nodes = [DirectoryNode]()
        if Node.Files.isEmpty
        {
            if !Skip
            {
                // Add the empty (eg, no files) node.
                Nodes.append(Node)
            }
        }
        // Add all of the children.
        for SubDir in Node.Children
        {
            Nodes.append(contentsOf: FlatMap(From: self, SkipEmptyDirectories: Skip))
        }
        return Nodes
    }
}
