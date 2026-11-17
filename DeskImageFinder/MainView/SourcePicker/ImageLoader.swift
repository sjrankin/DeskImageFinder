//
//  ImageLoader.swift
//  DeskImageFinder
//
//  Source from https://www.hackingwithswift.com/forums/macos/nsimage-in-swiftui-for-macos/2382
//  Edited by Stuart Rankin on 5/21/25.
//

import SwiftUI
import Combine
import AppKit

/// Provides services related to loading images from the file system.
@Observable class ImageLoader
{
    var image: NSImage?
    var Loaded: Bool = false
    var FileURL: URL? = nil
    
    /// Clear the loaded image and associated data.
    func Clear()
    {
        Loaded = false
        image = nil
        FileURL = nil
    }
    
    /// Load and image from `with`. The image loading is done in a background thread and will be
    /// stored in `image` when available.
    func LoadImage(with url: URL)
    {
        Loaded = false
        DispatchQueue.global(qos: .background).async
        {
            [weak self] in
            guard let self = self else
            {
                return
            }
            do {
                let data = try Data(contentsOf: url)
                guard let image = NSImage(data: data) else
                {
                    print("Error creating NSImage from \(url.absoluteString)")
                    return
                }
                DispatchQueue.main.async
                {
                    [weak self] in
                    self?.image = image
                    self?.Loaded = true
                    self?.FileURL = url
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    /// DO NOT USE
    func AsyncLoadImage(with url: URL) async
    {
        Loaded = false
        
        do {
            let data = try Data(contentsOf: url)
            guard let image = NSImage(data: data) else
            {
                print("Error creating NSImage from \(url.absoluteString)")
                return
            }
            self.image = image
            self.Loaded = true
            self.FileURL = url
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    /// Loads an image from the supplied URL.
    /// - Parameter From: The URL where the image resides.
    /// - Returns: `NSImage` created from `From` on success, 1x1 image on failure.
    static func LoadImage(From: URL) -> NSImage
    {
        do
        {
            let data = try Data(contentsOf: From)
            guard let image = NSImage(data: data) else
            {
                return NSImage(size: CGSize(width: 1, height: 1))
            }
            return image
        }
        catch
        {
            return NSImage(size: CGSize(width: 1, height: 1))
        }
    }
}
