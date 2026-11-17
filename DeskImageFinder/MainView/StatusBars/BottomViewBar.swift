//
//  BottomViewBar.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/4/25.
//

import SwiftUI

struct BottomViewBar: View
{
    @State var Status: ProcessStatusModel? = nil
    
    var body: some View
    {
        if let Status = Status
        {
            switch Status.StatusType
            {
                case .Ready:
                    MakeReady()
                case .SuppliedText:
                    MakeSuppliedText()
                case .Searching:
                    MakeSearching()
                case .Results:
                    MakeSearchResults()
            }
        }
    }
    
    @ViewBuilder func MakeReady() -> some View
    {
        HStack
        {
            Text("Ready")
            Spacer()
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
        .padding(.all, 2)
        .background(Color(nsColor: NSColor.separatorColor))
    }
    
    @ViewBuilder func MakeSuppliedText() -> some View
    {
        HStack
        {
            Text(Status?.StatusMessage ?? "??")
            Spacer()
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
        .padding(.all, 2)
        .background(Color(nsColor: NSColor.separatorColor))
    }
    
    @ViewBuilder func MakeSearching() -> some View
    {
        HStack
        {
            if let Status = Status
            {
                Text("Searching")
                Divider()
                VisualDirectoryPercent()
                Divider()
                VisualPercent()
                Divider()
                Text("\(Status.Current) of \(Status.Total)")
                Divider()
                if let FileURL = Status.RawURL
                {
                    Text("\(Files.SanitizeDirectory(From: FileURL))")
                    Divider()
                }
                Text("\(Status.FileName)")
                Spacer()
            }
        }
        .frame(height: 32)
        .frame(maxWidth: .infinity)
        .padding(.all, 2)
        .background(Color(nsColor: NSColor.separatorColor))
    }
    
    @ViewBuilder func VisualDirectoryPercent() -> some View
    {
        Circle()
            .trim(from: 0.0, to: DirectoryPercent())
            .rotation(.degrees(-90))
            .stroke(Color.indigo, style: StrokeStyle(lineWidth: 5))
            .frame(width: 24, height: 24)
            .help("Visual percent complete for number of directories to search.")
    }
    
    @ViewBuilder func VisualPercent() -> some View
    {
        Circle()
            .trim(from: 0.0, to: ProcessedPercent())
            .rotation(.degrees(-90))
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 5))
            .frame(width: 24, height: 24)
            .help("Visual percent complete for files in the current directory.")
    }
    
    func ProcessedPercent() -> CGFloat
    {
        if let Status = Status
        {
            return CGFloat(Status.Current) / CGFloat(Status.Total)
        }
        return 0.0
    }
    
    func DirectoryPercent() -> CGFloat
    {
        if let Status = Status
        {
            return Status.DirectorySearchedPercent
        }
        return 0.0
    }
    
    @ViewBuilder func MakeSearchResults() -> some View
    {
        if let Status = Status
        {
            HStack
            {
                Text("Results")
                Divider()
                Text("Exact")
                Text("\(Status.ExactCount)")
                    .bold()
                Divider()
                Text("Similar")
                Text("\(Status.SimilarCount)")
                    .bold()
                Divider()
                Text("Other")
                Text("\(Status.Total - (Status.ExactCount + Status.SimilarCount))")
                Spacer()
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            .padding(.all, 2)
            .background(Color(nsColor: NSColor.separatorColor))
        }
    }
}

#Preview
{
    BottomViewBar()
}


enum StatusViewTypes
{
    case SuppliedText
    case Ready
    case Searching
    case Results
}

