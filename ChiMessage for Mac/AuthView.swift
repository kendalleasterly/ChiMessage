//
//  ContentView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI
import FirebaseAuth


struct AuthView: View {
    
    @EnvironmentObject var authModel: AuthModel
    
    @ObservedObject var navModel: NavigationModel
    @ObservedObject var userModel: UserModel
    var conversationModel: ConversationModel
    
    init(navModel: NavigationModel) {
        
        let userModel = UserModel()
        self.userModel = userModel
        self.conversationModel = ConversationModel(userModel: userModel)
        self.navModel = navModel
        
    }
    
    var body: some View {
        Group{
            if authModel.isSignedIn {
                
                ConversationsView(model: conversationModel, navModel: navModel)
                
            } else {
                SignUpFlow()
            }
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
}

//struct AuthView: View {
//
//    @EnvironmentObject var authModel: AuthModel
//    @State var email = ""
//    @State var passowrd = ""
//
//    var body: some View {
//
//        return VStack {
//            Text("hahaha")
//
//            if authModel.isSignedIn {
//                return Text("horay!")
//            } else {
//                return VStack {
//                    TextField("email", text: $email)
//
//                    TextField("passowrd", text: $passowrd)
//
//                    Button {
//                        authModel.createUser(email: email, password: passowrd)
//                    } label: {
//                        Text("create user")
//                    }
//
//                    Button(action: {
//                        authModel.logOut()
//                    }, label: {
//                        Text("log out")
//                    })
//
//                }
//            }
//        }
//    }
//}

