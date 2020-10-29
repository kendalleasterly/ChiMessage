//
//  AuthView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import SwiftUI
import GoogleSignIn

struct AuthView: View {
    
    @EnvironmentObject var navModel: NavigationModel
    @ObservedObject var userModel = UserModel()
    @ObservedObject var googleDeleage: GoogleDelagate
    
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
                        
                        NavigationLink(
                            destination: ConversationsView().environmentObject(ConversationModel(userModel: userModel)),
                            isActive: $navModel.conversationLinkActive,
                            label: { EmptyView() })
                    }
                }
            }
        }
        .onAppear() {
            print("I appeared, restoring sign in")
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            print("I appeared, restored sign in")
            
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
