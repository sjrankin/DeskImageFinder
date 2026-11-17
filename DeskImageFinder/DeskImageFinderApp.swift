//
//  DeskImageFinderApp.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/20/25.
//

import SwiftUI

@main
struct DeskImageFinderApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene
    {
        WindowGroup
        {
            NavigationStack
            {
                MainView()
            }
            .navigationTitle("Similar Image Finder")
        }
    }
}
