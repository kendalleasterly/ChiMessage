//
//  SignUpFlow.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/24/20.
//

import SwiftUI
//TODO: if this is the users first time in the app, they won't have any conversations. this means that they will get an eternal placeholder. Fix this.
struct NameStepView: View {
    
    @State var firstName = ""
    @State var lastName = ""
    @State var linkIsActive = false
    
    var model: UserModel
    var navModel: NavigationModel
    var body: some View {
        
        VStack{
            TextField("Steve", text: $firstName)
            
            TextField("Jobs", text: $lastName)
            
            Button {
                
                model.sendName(firstName: firstName, lastName: lastName)
                self.linkIsActive = true
            } label: {
                
                HStack{
                    Text("Continue")
                    Image(systemName: "chevron.right.circle")
                }
                
            }
            
            NavigationLink(destination: UserNameStep(userName: suggestUsernameFromName(), model: model, navModel: navModel), isActive: $linkIsActive) {EmptyView()}
            
        }
    }
    
    func suggestUsernameFromName() -> String {
        
        let funcFirstName = self.firstName.lowercased()
        let funcLastName = self.lastName.lowercased()
        
        let suggestedUserName = funcFirstName + "_" + funcLastName
        return suggestedUserName.replacingOccurrences(of: " ", with: "")
        
    }
}

struct UserNameStep: View {
    
    @State var userName: String
    var model: UserModel
    var navModel: NavigationModel
    @State var linkIsActive = false
    
    var body: some View {
        VStack{
            HStack{
                Text("@")
                TextField("stevejobs", text: $userName)
            }
            Button {
                self.linkIsActive = true
                
                model.sendUserName(userName: userName)
            } label: {
                
                HStack{
                    Text("Continue")
                    Image(systemName: "chevron.right.circle")
                }
            }
            
            NavigationLink(destination: ConversationsView(model: ConversationModel(userModel: model), navModel: navModel), isActive: $linkIsActive, label: {EmptyView()})
            
        }
    }
    
}
