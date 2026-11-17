//
//  SessionsModel.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 6/20/25.
//

import Foundation
import Combine
import SwiftUI

/// Contains a data model for how to search and an array of past session data models.
@Observable class SessionsModel
{    
    /// Initializer.
    init()
    {
        let NewCurrent = DataModel()
        Sessions.append(NewCurrent)
    }
    
    /// The current data  model to use for searching.
    var Current: DataModel
    {
        get
        {
            return Sessions.first!
        }
        set
        {
            Sessions[0] = newValue
        }
    }
    
    /// Array of past sessions.
    var Sessions: [DataModel] = []
    
    /// Create a new session and append it to the session array.
    func CreateNewSession()
    {
        let NewCurrent = DataModel()
        Sessions.insert(NewCurrent, at: 0)
    }
    
    /// Duplicate the current session and append it to the session array.
    func DuplicateCurrentSession()
    {
        let Duplicate = DataModel(Previous: Current)
        Sessions.insert(Duplicate, at: 0)
    }
    
    /// Remove all stored sessions. Current session reset.
    func ClearSessions()
    {
        Sessions.removeAll()
        CreateNewSession()
    }
    
    /// Commits the current session (indicating it was used for a search).
    func CommitSession()
    {
        Current.InstanceTimeStamp = Date()
    }
    
    /// Resets the current session to all default values. If no sessions are stored, a new session is
    /// added to the array of sessions. 
    func ResetCurrentSession()
    {
        let NewCurrent = DataModel()
        if Sessions.isEmpty
        {
            Sessions.append(NewCurrent)
        }
        else
        {
            Sessions[0] = NewCurrent
        }
    }
}
