//
//  SwiftUIView.swift
//  
//
//  Created by Erik Basargin on 24/11/2020.
//

import SwiftUI
import SafariServices

public struct SafariView: UIViewControllerRepresentable {
    
    // MARK: - Public properties
    
    public let url: URL
    
    // MARK: - Initializers
    
    public init(_ url: URL) {
        self.url = url
    }
    
    // MARK: - Public methods

    public func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        return controller
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
