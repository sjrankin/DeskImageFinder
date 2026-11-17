//
//  SessionLog.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/20/25.
//

import SwiftUI

struct SessionLog: View
{
    @Environment(\.dismiss) var Dismiss
    @State var Results: SessionsModel? = nil
    @State var LogTitle: String = ""
    @State var TappedID: UUID? = nil
    
    var body: some View
    {
        VStack
        {
            Text("Session Summary and Log")
                .font(.largeTitle)
                .padding(.top, 4)
            Divider()
            NavigationSplitView
            {
                SessionList()
            }
        detail:
            {
                VStack
                {
                    HStack
                    {
                        Text(LogTitle)
                            .font(.headline)
                            .bold()
                            .padding(.horizontal)
                        Spacer()
                    }
                    Divider()
                    if let TappedID = TappedID
                    {
                        if let TappedModel = ResultFor(ID: TappedID)
                        {
                            SearchDetails(TappedModel)
                        }
                    }
                }
            }
            Divider()
            Button("Close")
            {
                Dismiss()
            }
            .padding(4)
            .padding(.bottom, 4)
        }
        .frame(width: 800, height: 800)
    }
    
    func ResultFor(ID: UUID) -> DataModel?
    {
        if let AllResults = Results?.Sessions
        {
            for SomeResult in AllResults
            {
                if SomeResult.id == ID
                {
                    return SomeResult
                }
            }
        }
        return nil
    }
    
    @ViewBuilder func SearchDetails(_ model: DataModel) -> some View
    {
        VStack
        {
            List
            {
                if let source = model.Source
                {
                    HStack
                    {
                        if let NiceURL = source.absoluteString.removingPercentEncoding
                        {
                            Text("Source")
                            Text(NiceURL)
                                .bold()
                            Spacer()
                        }
                    }
                }
                HStack
                {
                    Text("Exact matches")
                    Text("\(model.ExactCount)")
                        .bold()
                    Spacer()
                }
                HStack
                {
                    Text("Similar matches")
                    Text("\(model.SimilarCount)")
                        .bold()
                    Spacer()
                }
                HStack
                {
                    Text("Total compared")
                    Text("\(model.SearchCount)")
                        .bold()
                    Spacer()
                }
                HStack
                {
                    Text("Exact threshold")
                    Text("≤ \(model.ExactValue)")
                        .bold()
                    Spacer()
                }
                HStack
                {
                    Text("Similar threshold")
                    Text("\(model.ExactValue) >= \(model.SimilarValue)")
                        .bold()
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder func SessionList() -> some View
    {
        VStack
        {
            if let AllSessions = Results?.Sessions
            {
                List
                {
                    ForEach(AllSessions, id: \.id)
                    {
                        result in
                        if let DateResult = result.InstanceTimeStamp
                        {
                            HStack
                            {
                                Button(SessionTimeStamp(From: DateResult))
                                {
                                    LogTitle = SessionTimeStamp(From: DateResult)
                                    TappedID = result.id
                                }
                                .buttonStyle(.borderless)
                                .padding(.horizontal, 2)
                                Spacer()
                            }
                        }
                    }
                    HStack
                    {
                        Button("Summary")
                        {
                            print("Summary tapped")
                            LogTitle = "Summary"
                        }
                        .buttonStyle(.borderless)
                        .padding(.horizontal)
                        Spacer()
                    }
                }

            }
            Spacer()
        }
    }
    
    func SessionTimeStamp(From: Date) -> String
    {
        let Formatting = Date.FormatStyle(date: .abbreviated, time: .shortened)
        let Nice = From.formatted(Formatting)
        return Nice
    }
}

#Preview
{
    SessionLog()
}
