//
//  SignUpFlow.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI

struct SignUpFlow: View {
    
    @EnvironmentObject var authModel: AuthModel
    @State var email = ""
    @State var passowrd = ""
    @State var name = ""
    
    var body: some View {
        
        VStack {
            TextField("email", text: $email)
            
            TextField("passowrd", text: $passowrd)
            
            TextField("name", text: $name)
            
            Button {
                authModel.createUser(email: email, password: passowrd, name: name)
            } label: {
                Text("create user")
            }
            
        }
        
    }
    
}
