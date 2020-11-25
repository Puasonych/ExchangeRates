//
//  ServiceError.swift
//  
//
//  Created by Erik Basargin on 24/11/2020.
//

import Foundation

public enum ServiceError: LocalizedError {

    case unknown

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Something was going wrong"
        }
    }

}

