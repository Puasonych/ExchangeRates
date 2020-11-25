//
//  LoadingIndicatorView.swift
//  ExchangeRates
//
//  Created by Erik Basargin on 22/11/2020.
//

import SwiftUI

public struct LoadingIndicatorView: View {
    
    // MARK: - Public properties
    
    public let loaderColor: Color
    
    // MARK: - Internal properties
    
    @State var isAnimating: Bool = false
    
    // MARK: - Initializers
    
    public init(_ color: Color = .accentColor) {
        loaderColor = color
    }
    
    // MARK: - Computed properties
    
    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<5) { index in
                Group {
                    point(by: index, with: geometry)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
                .animation(Animation
                .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                .repeatForever(autoreverses: false))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .foregroundColor(loaderColor)
        .onAppear {
            self.isAnimating = true
        }
    }
    
    // MARK: - Internal methods
    
    func point(by index: Int, with geometry: GeometryProxy) -> some View {
        Circle()
            .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
            .scaleEffect(isAnimating ? 0.2 + CGFloat(index) / 5 : 1 - CGFloat(index) / 5)
            .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
    }
}

// MARK: - Previews

struct LoadingIndicatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        LoadingIndicatorView()
    }
}
