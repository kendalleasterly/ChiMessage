//
//  TextField+Extension.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/7/20.
//

import SwiftUI

extension NSTextField { // << workaround !!!
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
