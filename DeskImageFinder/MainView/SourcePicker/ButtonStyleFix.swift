//
//  ButtonStyleFix.swift
//  DeskImageFinder
//
//  Created by Stuart Rankin on 5/21/25.
//

import SwiftUI

struct ButtonStyleFix: ButtonStyle
{
    let BGColor: Color
    let FGColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View
    {
        configuration.label
            .padding()
            .frame(maxHeight: 24)
            .foregroundColor(configuration.isPressed ? BGColor : FGColor)
            .background(configuration.isPressed ? Color.white : BGColor)
            .cornerRadius(6.0)
            .bold()
    }
}
