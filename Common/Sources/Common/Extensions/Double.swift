//
//  Double.swift
//  
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation

public extension Double {

    func goodDecimal() -> Decimal {
        Decimal(string: String(format: "%.2f", self)) ?? 0
    }
    
}
