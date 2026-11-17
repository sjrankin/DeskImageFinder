//
//  ProcessStatusModel.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/30/25.
//

import Foundation
import Combine

@Observable @MainActor class ProcessStatusModel
{
    /// Is processing flag.
    var Processing: Bool = false
    
    /// Total files to process.
    var Total: Int = 0
    
    /// Percent directories searched.
    var DirectorySearchedPercent: CGFloat = 0.0
    
    /// Current index of file being processed.
    var Current: Int = 0
    
    /// URL of the file being processed.
    var RawURL: URL? = nil
    
    /// Name of file being processed.
    var FileName: String = ""
    
    /// Type of status to display.
    var StatusType: StatusViewTypes = .Ready
    
    /// Message to display in the status.
    var StatusMessage: String = ""
    
    /// Number of exact matches (see `DataModel`).
    var ExactCount: Int = 0
    
    /// Number of similar matches (see `DataModel`).
    var SimilarCount: Int = 0
    
    /// Resets the status.
    func Reset()
    {
        Processing = false
        Total = 0
        Current = 0
        FileName = ""
        StatusType = .Ready
        StatusMessage = ""
        ExactCount = 0
        SimilarCount = 0
        DirectorySearchedPercent = 0.0
    }
}
