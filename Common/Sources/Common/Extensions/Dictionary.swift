//
//  Dictionary.swift
//  
//
//  Created by Erik Basargin on 23/11/2020.
//

import Foundation

public extension Dictionary {

    static func + (left: Dictionary, right: Dictionary) -> Dictionary {
        var result = left
        for element in right {
            result[element.key] = element.value
        }
        return result
    }

}
