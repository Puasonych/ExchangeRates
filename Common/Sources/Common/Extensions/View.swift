//
//  View.swift
//  
//
//  Created by Erik Basargin on 24/11/2020.
//

import SwiftUI

public extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
