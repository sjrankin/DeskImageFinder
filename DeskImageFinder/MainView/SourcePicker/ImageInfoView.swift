//
//  ImageInfoView.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import SwiftUI
import ImageIO

struct ImageInfoView: View
{
    @Environment(\.dismiss) var Dismiss
    var ImageURL: URL?
    var ActualImage: NSImage?
    
    var body: some View
    {
        VStack
        {
            Text("Image Information")
                .font(.headline)
                .padding(.top, 4)
            Divider()
            if ImageURL == nil
            {
                Spacer()
                Text("No image information available.")
                Spacer()
            }
            else
            {
                VStack
                {
                    if let TheImage = ActualImage
                    {
                        Image(nsImage: TheImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .padding()
                    }
                    VStack
                    {
                        List
                        {
                            InfoListItemView(Header: "Name", Detail: Files.NameFrom(ImageURL))
                            InfoListItemView(Header: "Volume", Detail: Files.VolumeFrom(ImageURL))
                            InfoListItemView(Header: "Directory", Detail: Files.DirectoryFrom(ImageURL))
                            InfoListItemView(Header: "Image size", Detail: "\(ActualImage?.size.width ?? 0) x \(ActualImage?.size.height ?? 0)")
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
                            InfoListItemView(Header: "URL", Detail: ImageURL!.absoluteString)
                        }
                    }
                }
            }
            Button("Close")
            {
                Dismiss()
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
}

struct InfoListItemView: View
{
    @State var Header: String
    @State var Detail: String
    
    var body: some View
    {
        HStack
        {
            Text(Header)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(Detail)
        }
    }
}

#Preview
{
    ImageInfoView(ImageURL: nil, ActualImage: nil)
}
