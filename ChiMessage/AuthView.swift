//
//  AuthView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import SwiftUI
import GoogleSignIn

struct AuthView: View {
    
    @ObservedObject var navModel: NavigationModel
    @ObservedObject var userModel: UserModel
    @ObservedObject var googleDeleage: GoogleDelagate
    var conversationModel: ConversationModel
    
    init(navModel: NavigationModel, googleDeleage: GoogleDelagate) {
        
        self.navModel = navModel
        self.googleDeleage = googleDeleage
        
        let userModel = UserModel()
        self.userModel = userModel
        self.conversationModel = ConversationModel(userModel: userModel)
        
    }
    
    var body: some View {
        
        NavigationView{
            
            if let instance = GIDSignIn.sharedInstance(){
                if !instance.hasPreviousSignIn() {
                    
                    SignInButton()
                        .padding()
                } else {
                    if googleDeleage.isCreation{
                        NameStepView(model: userModel, navModel: navModel)

                    } else {
                        
                        ConversationsView(model: conversationModel, navModel: navModel)
                    }
                }
            }
        }
        .onAppear {
            print("auth view appeared")
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            
            
//            userModel.listen()
            
        }.navigationTitle(Text("ChiMessage"))
    }
}

struct SignInButton: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GIDSignInButton {
        
        let button = GIDSignInButton()
        button.colorScheme = .dark
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
}
