//
//  FullImageView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/25/25.
//

import SwiftUI

struct FullImageView: View
{
    @Environment(\.dismiss) var Dismiss
    @State var FullImage: NSImage? = nil
    @State var ImageURL: URL? = nil
    
    var body: some View
    {
        if let TheImage = FullImage
        {
            VStack
            {
                Text(Files.NameFrom(ImageURL))
                    .font(.headline)
                    .padding(.top, 4)
                Divider()
                VStack
                {
                    Image(nsImage: TheImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 1600, maxHeight: 1600)
                }
                .frame(maxWidth: 1200, maxHeight: 1200)
                    Divider()
                    VStack
                    {
                        List
                        {
                            if ImageURL != nil
                            {
                                InfoListItemView(Header: "Name", Detail: Files.NameFrom(ImageURL))
                                InfoListItemView(Header: "Volume", Detail: Files.VolumeFrom(ImageURL))
                                InfoListItemView(Header: "Directory", Detail: Files.DirectoryFrom(ImageURL))
                            }
                            InfoListItemView(Header: "Image dimensions", Detail: "\(FullImage?.size.width ?? 0) x \(FullImage?.size.height ?? 0)")
                            if ImageURL != nil
                            {
                                ForEach(Files.FileAttributes(ImageURL), id: \.0)
                                {
                                    SomeAttribute in
                                    InfoListItemView(Header: SomeAttribute.0, Detail: SomeAttribute.1)
                                }
                                ForEach(Files.ImageMetaData(ImageURL), id: \.0)
                                {
                                    SomeAttribute in
                                    InfoListItemView(Header: SomeAttribute.0, Detail: SomeAttribute.1)
                                }
                                if let TheURL = ImageURL
                                {
                                    InfoListItemView(Header: "URL", Detail: TheURL.absoluteString)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                Divider()
                HStack
                {
                    if let TheURL = ImageURL
                    {
                        Button("Show in Finder", systemImage: "folder")
                        {
                            // Opens the file's directory in Finder with the file selected.
                            NSWorkspace.shared.activateFileViewerSelecting([TheURL])
                        }
                        .help("Open the image's directory in Finder with the image selected.")
                    }
                    Button("Close")
                    {
                        Dismiss()
                    }
                }
                .padding(4)
                .padding(.bottom, 6)
            }
            .frame(maxHeight: NSScreen.main!.visibleFrame.size.height - 100)
        }
    }
}

#Preview
{
    FullImageView(FullImage: NSImage(named: "Bob"), ImageURL: nil)
}
