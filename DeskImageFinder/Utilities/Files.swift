//
//  Files.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/8/25.
//

import Foundation
import AppKit

// MARK: - File-Related Functionality

/// Utility functions related to files.
class Files
{
    /// Returns file attributes for the file at the passed URL.
    /// - Parameter url: The URL of the file whose attributes will be returned.
    /// - Returns: Array of a tuple of key/value pairs. Empty array returned on error.
    static func FileAttributes(_ url: URL?) -> [(String, String)]
    {
        guard let url = url else
        {
            return []
        }
        var results = [(String, String)]()
        do
        {
            let Attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let FileSize = Attributes[.size] as? NSNumber
            {
                results.append(("File size", String(format: "%.2f MB", FileSize.doubleValue / 1024 / 1024)))
            }
            if let CreateDate = Attributes[.creationDate] as? Date
            {
                results.append(("Created", DateFormatter.localizedString(from: CreateDate, dateStyle: .medium, timeStyle: .medium)))
            }
            if let ModifiedDate = Attributes[.modificationDate] as? Date
            {
                results.append(("Modified", DateFormatter.localizedString(from: ModifiedDate, dateStyle: .medium, timeStyle: .medium)))
            }
        }
        catch
        {
            return [("Error", "Error getting file attributes")]
        }
        return results
    }
    
    /// Returns metadata stored in an image specified by the passed URL.
    /// - Parameter url: The URL of the image whose metadata will be returned.
    /// - Returns: Array of tuples with key/value pairs for the metadata. Empty array returned on error.
    static func ImageMetaData(_ url: URL?) -> [(String, String)]
    {
        guard let url = url else
        {
            return []
        }
        do
        {
            let ImageData = try Data(contentsOf: url)
            guard let ImageSource = CGImageSourceCreateWithData(ImageData as CFData, nil) else
            {
                return []
            }
            if let Metadata = CGImageSourceCopyPropertiesAtIndex(ImageSource, 0, nil) as? [AnyHashable: Any]
            {
                var results: [(String, String)] = []
                for (Key, Value) in Metadata
                {
                    results.append(("\(Key)", "\(Value)"))
                }
                return results
            }
        }
        catch
        {
            return []
        }
        return []
    }
    
    /// Gets the name of a file from the passed URL.
    /// - Parameter url: The URL whose name portion will be returned. If this value is `nil`, an empty
    /// string will be returned.
    /// - Returns: The name portion of the passed URL. Empty string if `url` is `nil`.
    static func NameFrom(_ url: URL?) -> String
    {
        if let url = url
        {
            return url.lastPathComponent
        }
        else
        {
            return ""
        }
    }
    
    /// Returns the extension of the file at the URL.
    /// - Parameter url: The URL whose file extension will be returned.
    /// - Returns: Extension of the file at the URL. Empty string on error.
    static func ExtensionFrom(_ url: URL?) -> String
    {
        guard let url = url else
        {
            return ""
        }
        return url.pathExtension
    }
    
    /// Returns the name of the directory from the passed path URL.
    /// - Parameter Path: The path that contains the directory name.
    /// - Parameter IncludeName: If true, the name of the file is included.
    /// - Returns: The name of the directory. Empty string on error.
    static func DirectoryFromFilePath(_ Path: URL, IncludeName: Bool) -> String
    {
        let name = Path.absoluteString
        if name.isEmpty
        {
            return ""
        }
        var parts = name.split(separator: "/")
        parts.removeFirst()
        if IncludeName
        {
            parts.removeLast()
        }
        var final = ""
        for index in 0 ..< parts.count
        {
            final += String(parts[index]) + "/"
        }
        return "/" + final
    }
    
    /// Remove the file name portion from the passed URL.
    /// - Parameter From: The URL whose file name will be removed.
    /// - Returns: String version of the passed URL with the file name removed.
    static func RemoveFileName(From: URL) -> String
    {
        var parts = [String.SubSequence]()
        parts = From.deletingLastPathComponent().path.split(separator: "/")
        var final = ""
        for index in 2 ..< parts.count
        {
            final += String(parts[index]) + "/"
        }
        return "/" + final
    }
    
    /// Remove the file name portion from the passed URL.
    /// - Parameter Original: The URL whose file name will be returned.
    /// - Returns: New URL based on `Original` with the file name portion removed. Nil on error.
    static func RemoveFileName(Original: URL) -> URL?
    {
        let Stringed = RemoveFileName(From: Original)
        return URL(string: Stringed)
    }
    
    /// Gets the directory portion from the passed URL.
    /// - Parameter url: The URL whose directory name will be returned.
    /// - Parameter FromDirectory: Set to `true` if the URL is from a directory (eg, not a file). Defaults
    /// to `false`.
    /// - Returns: The directory portion of the passed URL. Empty string on error.
    static func DirectoryFrom(_ url: URL?, FromDirectory: Bool = false) -> String
    {
        if let url = url
        {
            var parts = [String.SubSequence]()
            if FromDirectory
            {
                parts = url.path.split(separator: "/")
            }
            else
            {
                parts = url.deletingLastPathComponent().path.split(separator: "/")
            }
            var final = ""
            for index in 2 ..< parts.count
            {
                final += String(parts[index]) + "/"
            }
            return "/" + final
        }
        else
        {
            return ""
        }
    }
    
    /// Sanitized (eg, makes nicer looking) the passed directory URL.
    /// - Parameter From: The URL to sanitize.
    /// - Returns: String of the sanitized URL.
    static func SanitizeDirectory(From: URL) -> String
    {
        var dir = DirectoryFromFilePath(From, IncludeName: false)
        dir = dir.replacingOccurrences(of: "/Volumes/", with: "")
        var parts = dir.components(separatedBy: "/")
        if parts.last == ""
        {
            parts.removeLast()
        }
        parts.removeLast()
        var working = ""
        for part in parts
        {
            working += part + "/"
        }
        working.removeLast()
        working = working.removingPercentEncoding ?? ""
        return working
    }
    
    /// Sanitized (eg, makes nicer looking) the passed directory URL.
    /// - Parameter From: The URL to sanitize.
    /// - Returns: Sanitized URL.
    static func SanitizeDirectory(_ From: URL) -> URL?
    {
        let working = SanitizeDirectory(From: From)
        return URL(string: working)
    }
    
    /// Returns the volume name from the passed URL.
    /// - Parameter url: The URL whose volume name will be returned.
    /// - Returns: The volume name from the passed URL. Empty string on error.
    static func VolumeFrom(_ url: URL?) -> String
    {
        if let url = url
        {
            do
            {
                let resources = try url.resourceValues(forKeys: [.volumeNameKey])
                if let VolumeName = resources.volumeName
                {
                    return VolumeName
                }
                return "huh?"
            }
            catch
            {
                return "resource not found"
            }
        }
        else
        {
            return "no url"
        }
    }
    
    /// Returns an `NSImage` from the passed URL.
    /// - Parameter From: The URL to use to load the image.
    /// - Returns: An `NSImage` from the passed URL on success, `nil` on error.
    /// - Warning: `NSImage` is _not_ `Sendable` (because it's mutable) so don't call this function where `Sendable` is expected.
    static func GetImage(From URL: URL) -> NSImage?
    {
        return NSImage(contentsOf: URL)
    }
    
    /// Returns a list of all file URLs in the passed directory.
    /// - Parameter Directory: The URL of the directory whose list of files will be returned.
    /// - Returns: Array of URLs.
    static func GetFilesIn(Directory: URL) -> [URL]
    {
        var URLs: [URL] = []
        do
        {
            URLs = try FileManager.default.contentsOfDirectory(at: Directory,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
        }
        catch
        {
            print("error: \(error)")
            return URLs
        }
        return URLs
    }
    
    /// Return the URL of all files in a given directory that have an extension in `Extensions`.
    /// - Parameter Extensions: Array of extensions that determine which URLs are returned. Each string in
    /// this array must be lowercase and contain no `.` characters.
    /// - Parameter In: The directory whose files will be returned (provided they match an extension).
    /// - Returns: Array of URLs of matching files.
    static func GetFilesMatching(Extensions: [String], In Directory: URL) -> [URL]
    {
        var Results = [URL]()
        let FileURLs = GetFilesIn(Directory: Directory)
        for FileURL in FileURLs
        {
            let Extension = ExtensionFrom(FileURL).lowercased()
            if Extensions.contains(Extension)
            {
                Results.append(FileURL)
            }
        }
        return Results
    }
    
    /// Returns the number of files that match the filter in `With` in the specified directory.
    /// - Parameter Directory: The URL of the directory for which the count of files will be returned.
    /// - Parameter With: The data model that indicates which files to include in the count of files.
    /// - Returns: The number of files in the specified directory that matches the passed filter.
    @MainActor static func FileCountInDirectory(_ Directory: URL, With Model: DataModel) -> Int
    {
        let ExtList = Utilities.MakeExtensionArray(JPG: Model.SearchJPG, PNG: Model.SearchPNG,
                                         GIF: Model.SearchGIF, TIFF: Model.SearchTIFF,
                                         WEBP: Model.SearchWEBP, HEIC: Model.SearchHEIC)
        let URLList = GetFilesMatching(Extensions: ExtList, In: Directory)
        return URLList.count
    }
    
    /// Returns a list of files in the passed directory that match the filter in `WithModel`.
    /// - Parameter Directory: The directory whose file URLs will be returned.
    /// - Parameter With: Determines the filter for which file URLs are returned.
    /// - Returns: Array of URLs for files that match the filter.
    @MainActor static func FilesInDirectory(_ Directory: URL, With Model: DataModel) -> [URL]
    {
        let ExtList = Utilities.MakeExtensionArray(JPG: Model.SearchJPG, PNG: Model.SearchPNG,
                                         GIF: Model.SearchGIF, TIFF: Model.SearchTIFF,
                                         WEBP: Model.SearchWEBP, HEIC: Model.SearchHEIC)
        let URLList = GetFilesMatching(Extensions: ExtList, In: Directory)
        return URLList
    }
    
    /// Returns an array of URLs for sub-directories of the passed directory.
    /// - Note: Hidden directories are ignored.
    /// - Parameter Directory: The URL of the parent directory whose sub-directories will be returned.
    /// - Returns: Array of sub-directories of `Directory`.
    static func GetSubDirectoriesIn(Directory: URL) -> [URL]
    {
        var URLs: [URL] = []
        do
        {
            URLs = try FileManager.default.contentsOfDirectory(at: Directory,
                                                               includingPropertiesForKeys: nil,
                                                               options: [.skipsHiddenFiles])
            let SubURLs = URLs.filter{ $0.hasDirectoryPath }
            return SubURLs
        }
        catch
        {
            return []
        }
    }
    
    /// Returns an array of URLs for sub-directories of the passed directory.
    /// - Note: Hidden directories are ignored.
    /// - Parameter Directory: The URL of the parent directory whose sub-directories will be returned.
    /// - Returns: Array of sub-directories of `Directory`.
    /// - Note: Async function to prevent the UI from freezing.
    static func AsyncGetSubDirectoriesIn(Directory: URL) async -> [URL]
    {
        var URLs: [URL] = []
        do
        {
            URLs = try FileManager.default.contentsOfDirectory(at: Directory,
                                                               includingPropertiesForKeys: nil,
                                                               options: [.skipsHiddenFiles])
            let SubURLs = URLs.filter{ $0.hasDirectoryPath }
            return SubURLs
        }
        catch
        {
            return []
        }
    }
    
    /// Create a tree of sub-directories from the passed URL.
    /// - Parameter Directory: The source URL.
    /// - Returns: A `DirectoryNode` containing the file structure.
    static func MakeDirectoryTree(Directory Source: URL) async -> DirectoryNode
    {
        var Me = DirectoryNode(DirectoryURL: Source)
        let FileList = GetFilesIn(Directory: Source).filter({!$0.hasDirectoryPath})
        for File in FileList
        {
            Me.Files.append(URL2(url: File))
        }
        let SubDirs = await AsyncGetSubDirectoriesIn(Directory: Source)
        Me.Children = [DirectoryNode]()
        for Dir in SubDirs
        {
            let Descendents = await MakeDirectoryTree(Directory: Dir)
            Me.Children.append(Descendents)
        }
        return Me
    }
    
    /// Returns a unique array of all directories and sub-directories in the passed array of directories.
    /// - Parameter In: Array of directories to examine.
    /// - Parameter MaxDepth: The depth of sub-directories desired. Defaults to `Int.Max` which
    /// is effectively infinity (it evaluates to over nine septillion). If you want to only see the current directory (and
    /// no sub-directories), set this value to `1`.
    /// - Parameter CurrentDepth: **Not indended to be set by the caller.** Contains the current depth
    /// of searching sub-directories.
    /// - Returns: Array of unique directories.
    /// - Note: If you set `MaxDepth` to `0`, control will immediately return with an empty array.
    /// - Note: Uniqueness is determined by the raw path stored in a set.
    static func GetAllDirectories(In Directories: [URL],
                                  MaxDepth NoDeeperThan: Int = Int.max,
                                  CurrentDepth Level: Int = 0) -> [URL]
    {
        if Level >= NoDeeperThan
        {
            return []
        }
        var Working = Set<URL>()
        for Directory in Directories
        {
            if Working.contains(Directory)
            {
                continue
            }
            Working.insert(Directory)
            for Child in GetSubDirectoriesIn(Directory: Directory)
            {
                if Child.hasDirectoryPath
                {
                    Working.insert(Child)
                    Working.formUnion(GetAllDirectories(In: [Child],
                                                        MaxDepth: NoDeeperThan,
                                                        CurrentDepth: Level + 1))
                }
            }
        }
        return Array(Working)
    }
    
    /// Returns a prettified URL with percent encoding and schemes removed.
    static func PrettyNameWithoutScheme(_ TheURL: URL) -> String
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
    
    /// Print a debug tree of a given `DirectoryNode`.
    /// - Parameter Node: The top of the `DiretoryNode` structure where to start printing the contents.
    /// - Parameter Level: Used internally to adjusted leading spaces.
    /// - Returns: String indended per tree depth of the directory name structure.
    static func DebugTree(_ Node: DirectoryNode, Level: Int = 0) -> String
    {
        var stemp = String(repeating: "", count: Level) + "\(Node.PrettyNameWithoutScheme)\n"
        for Child in Node.Children
            {
                stemp += DebugTree(Child, Level: Level + 1)
            }
        return stemp
    }
}
