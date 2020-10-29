//
//  NavigationModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/18/20.
//

import Foundation

class NavigationModel: ObservableObject {
    
    @Published var conversationLinkActive = false
    var convoSelection: String? = nil
    //so there is a feature in navigation links where you can define tags, and those tags can be the ID's for the rooms. If I select a tag in say the new room view, make that selected tag value here, and then the conversatinons view is listening, it will transition into the new room we've just made.
    
}
