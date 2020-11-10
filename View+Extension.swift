//
//  View+Extension.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 11/7/20.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

extension View {
    
    func cf() -> Colors {
        
        return Colors()
        
    }

    
    func centered() -> some View {
        
        return self.modifier(Centered())
        
    }
    
    func leading() -> some View {
        return self.modifier(Leading())
    }
    
    func top() -> some View {
        return self.modifier(Top())
    }
    
    
    //MARK: -Platform Specific Customizations
    func secondaryLabelColor() -> Color {
        
        
        #if os(iOS)
        return Color(UIColor.secondaryLabel)
        #endif
        
        #if os(macOS)
        return Color(NSColor.secondaryLabelColor)
        #endif
        
    }
        
    
    func tertiaryLabelColor() -> Color {
        
        
        #if os(iOS)
        return Color(UIColor.tertiaryLabel)
        #endif
        
        #if os(macOS)
        return Color(NSColor.tertiaryLabelColor)
        #endif
        
    }
    
    
    
    func contactSize() -> CGFloat {
        
        #if os(iOS)
        return 40
        #endif
        
        #if os(macOS)
        return 35
        #endif
        
    }
    
    
}

extension Text {
    
    func contactText() -> Text {
        
        
        #if os(iOS)
        return self.font(.callout).fontWeight(.semibold)
        #endif
        
        #if os(macOS)
//        return self.font(.system(size: 16, weight: .semibold))
        return self.fontWeight(.semibold)
        #endif
    }
    
    func body() -> Text {
        
        #if os(iOS)
        return self.font(.callout)
        #endif
        
        #if os(macOS)
        return self.font(.system(size: 16))
        #endif
        
    }
    
    func title() -> Text {
        
        #if os(iOS)
        return self.font(.title).fontWeight(.bold)
        #endif
        
        #if os(macOS)
        return self.font(.system(size: 17)).fontWeight(.medium)
        #endif
        
    }
    
}

struct Centered: ViewModifier {
    
    func body(content: Content) -> some View {
        
        return HStack {
            Spacer()
            content
            Spacer()
        }
        
    }
}


struct Leading: ViewModifier {
    
    func body(content: Content) -> some View {
        
        return HStack {
            
            content
            Spacer()
        }
        
    }
}

struct Top: ViewModifier {
    
    func body(content: Content) -> some View {
        
        return VStack {
            
            content
            Spacer()
        }
        
    }
}



#if os(macOS)

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

//struct TopNotRoundedView: NSViewRepresentable {
//    
//    var cornerRadius: CGFloat
//    
//    func makeNSView(context: Context) -> some NSView {
//        let rect = NSRect(x: 1, y: 1, width: 1, height: 1)
//        let view = NSView(frame: rect)
//        
//        return view
//    }
//    
//    func updateNSView(_ nsView: NSView, context: Context) {
//        
//        nsView.layer!.cornerRadius = cornerRadius
//        nsView.layer!.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//    }
//    
//}

#endif
