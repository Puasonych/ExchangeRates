//
//  Currency.swift
//  
//
//  Created by Erik Basargin on 23/11/2020.
//

import Foundation
import struct SwiftUI.Image
import UIKit.UIImage

public struct Currency: Codable, Identifiable, Hashable {
    
    public static let `default` = Currency("USD")
    
    public let isoCode: String
    
    public init(_ iso: String) {
        self.isoCode = iso
    }
    
}

// MARK: - Identifiable

public extension Currency {
    
    var id: Int { hashValue }
}

// MARK: - Hashable

public extension Currency {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(isoCode)
    }
}

// MARK: - Image access

public extension Currency {
    
    var countryImage: Image? {
        Image.tryLoadImage(String(isoCode.prefix(2)))
    }
}

fileprivate extension Image {
    
    static func tryLoadImage(_ name: String) -> Image? {
        guard let uiImage = UIImage(named: name, in: Bundle.module, compatibleWith: nil) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
}

