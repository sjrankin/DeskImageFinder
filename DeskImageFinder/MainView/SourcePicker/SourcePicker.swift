//
//  SourcePicker.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import SwiftUI
import PhotosUI
import Photos
import UniformTypeIdentifiers

struct SourcePicker: View
{
    @State var SearchModel: SessionsModel
    @Binding var Annotation: String
    @State var ProcessState: ProcessStatusModel? = nil
    @State var ShowImporter: Bool = false
    @State var SelectedImages: [PhotosPickerItem] = []
    @State var SourceURL: URL? = nil
    @State var Loader = ImageLoader()
    @State var ShowImageInfo: Bool = false
    @State var ShowOptions: Bool = false
    @State var ShowDebugSheet: Bool = false
    @State var ShowPickerView: Bool = false
    @State var PickerItem: PhotosPickerItem? = nil
    @State var PhotoPickedItem: PhotosPickerItem? = nil
    @State var PhotoLibraryPhoto: NSImage? = nil
    @State var Total: Int = 0
    @State var Current: Int = 0
    @State var Results = [SimilarityResult]()
    
    var body: some View
    {
        VStack
        {
            VStack
            {
                VStack
                {
                    if self.Loader.Loaded
                    {
                        Text("Source Image")
                            .font(.system(size: 18, weight: .bold))
                            Image(nsImage: Loader.image!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320, height: 320)
                        HStack(alignment: .center)
                        {
                            Text(Files.NameFrom(self.Loader.FileURL))
                                .font(.caption)
                            Button(action: {ShowImageInfo.toggle()},
                                   label:
                                    {
                                Image(systemName: "info.circle")
                            })
                            .buttonStyle(.borderless)
                            .foregroundStyle(.blue)
                        }
                        .sheet(isPresented: $ShowImageInfo)
                        {
                            ImageInfoView(ImageURL: self.Loader.FileURL,
                                          ActualImage: self.Loader.image)
                        }
                    }
                    else
                    {
                        HStack
                        {
                            
                        }
                        .frame(width: 320, height: 320)
                        .padding(16)
                        .background(.gray)
                        .cornerRadius(5.0)
                        .overlay(RoundedRectangle(cornerRadius: 5.0)
                            .stroke(.gray.opacity(0.65), lineWidth: 0.5))
                        .dropDestination(for: URL.self)
                        {
                            items, location in
                            if items.count >= 1
                            {
                                self.SourceURL = items.first
                                self.Loader.LoadImage(with: self.SourceURL!)
                                self.SearchModel.Current.Source = self.SourceURL
                                return true
                            }
                            else
                            {
                                return false
                            }
                        }
                    }
                }
                Spacer()
                Button("Load Image")
                {
                    if SearchModel.Current.UsePhotos
                    {
                        ShowPickerView.toggle()
                    }
                    else
                    {
                        ShowImporter.toggle()
                        let Panel = NSOpenPanel()
                        Panel.allowsMultipleSelection = false
                        Panel.canChooseDirectories = true
                        if Panel.runModal() == .OK
                        {
                            self.SourceURL = Panel.url
                            self.Loader.LoadImage(with: self.SourceURL!)
                            self.SearchModel.Current.Source = self.SourceURL
                        }
                    }
                }
                .help("Select an image to look for similar images.")
                .buttonStyle(.borderedProminent)
                .photosPicker(isPresented: $ShowPickerView,
                              selection: $PickerItem,
                              matching: .images,
                              photoLibrary: .shared())
                .onChange(of: PickerItem)
                {
                    _, new in
                    Task
                    {
                        if let Something = new
                        {
                            if let ImageData = try? await Something.loadTransferable(type: Data.self)
                            {
                                self.PhotoLibraryPhoto = NSImage(data: ImageData)
                            }
                        }
                    }
                }
                Button("Search Options")
                {
                    ShowOptions.toggle()
                }
                .help("Search the source directory or specify the search locations here")
                .sheet(isPresented: $ShowOptions)
                {
                    SearchOptionsView(SearchOptions: SearchModel)
                }
                Button("Clear")
                {
                    SearchModel.Current.ClearResults()
                    ProcessState?.Reset()
//                    SearchModel.Results.removeAll()
//                    SearchModel.Source = nil
                    Loader.Clear()
                }
            }
            Divider()
            VStack
            {
                Button("Search")
                {
                    if let theurl = self.SearchModel.Current.Source
                    {
                        let dir = Files.DirectoryFromFilePath(theurl, IncludeName: true)
                        if !dir.isEmpty
                        {
                            Task
                            {
//                                SearchModel.CreateNewSession()
//                                SearchModel.Current.ClearResults()
                                SearchModel.DuplicateCurrentSession()
                                if let thedir = URL(string: dir),
                                   let SourceImage = self.Loader.image//,
                                   //let SourceObservation = await VisionSimilarity.Preprocess(SourceImage)
                                {
                                    Task
                                    {
                                        let AllDirs = Files.GetAllDirectories(In: [thedir],
                                                                              MaxDepth: 1)
                                        for SomeDir in AllDirs
                                        {
                                            print(SomeDir.absoluteString.removingPercentEncoding ?? SomeDir.absoluteString)
                                        }
                                        if ProcessState != nil
                                        {
#if true
                                            SearchModel.CommitSession()
                                            self.SearchModel.Current.Results.removeAll()
                                            await self.SearchModel.Current.Results = Utilities.LoadImages(From: AllDirs,
                                                                                                          With: SearchModel.Current,
                                                                                                          DoCompare: true,
                                                                                                          Reference: self.Loader.image,
                                                                                                          Status: ProcessState!,
                                                                                                          Search: SearchModel)
#else
                                            await self.SearchModel.Results = Utilities.LoadImages(In: thedir,
                                                                                                  With: SearchModel,
                                                                                                  DoCompare: true,
                                                                                                  Reference: self.Loader.image,
                                                                                                  Status: ProcessState!)
                                            #endif
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(ButtonStyleFix(BGColor: .green, FGColor: .white))
                .disabled(!Loader.Loaded)
                Button("Debug")
                {
                    ShowDebugSheet.toggle()
                }
                .padding(.top, 16)
                .sheet(isPresented: $ShowDebugSheet)
                {
                    DebugView(SearchOptions: SearchModel)
                }
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func PrettyStatusString(_ Current: Int, _ Total: Int, File: URL) -> String
    {
        let FileName = Files.NameFrom(File)
        if Total <= 0
        {
            return FileName
        }
        return String("\(Current + 1) of \(Total) \(FileName)")
    }
}

struct DataURL: Transferable
{
    let url: URL
    static var transferRepresentation: some TransferRepresentation
    {
        FileRepresentation(contentType: .data)
        {
            data in
            SentTransferredFile(data.url)
        } importing:
        {
            received in
            Self(url: received.file)
            /*
            let copy = try FileManager.default.url(for: .picturesDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: .picturesDirectory,
                                                   create: true)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return DataURL(url: copy)
             */
        }
    }
}

struct ValidDroppedTypes: Identifiable, Codable, Transferable
{
    let id: UUID
    let data: Data
    let Title: String
    
    static var transferRepresentation: some TransferRepresentation
    {
        CodableRepresentation(contentType: .image)
        ProxyRepresentation(exporting: \.Title)
    }
}

#Preview
{
    @Previewable @State var TestAnnotation: String = "Your mileage may vary"
    SourcePicker(SearchModel: SessionsModel(),
                 Annotation: $TestAnnotation)
}
