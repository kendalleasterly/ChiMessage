//
//  View+Extension.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

extension View {
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    func cf() -> Colors {
        
        return Colors()
        
    }
    
    func centered() -> some View {
        
        return self.modifier(Centered())
        
    }
    
}

#if canImport(UIKit)
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemThinMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
#endif

struct Centered: ViewModifier {
    
    func body(content: Content) -> some View {
        
        return HStack {
            Spacer()
            content
            Spacer()
        }
        
    }
}
