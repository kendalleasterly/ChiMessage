//
//  Searcher.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/30/20.
//

import Foundation
import FirebaseFirestore

class Searcher {
    
    @Published var searchResults = [SearchResult]()
    var db: Firestore!
    
    init(db: Firestore) {
        self.db = db
    }
    
    func searchForUser(user: String) {

        if user != "" {
            //add something here that asks for the list of user ids that we already have, and add that to the search querey as a IS NOT Any
            db.collection("users").whereField("username", isGreaterThanOrEqualTo: user).getDocuments { (snapshot, error) in

                if let documents = snapshot {

                    var results = [SearchResult]()

                    for document in documents.documents {

                        let data = document.data()
                        let name = data["name"] as! String
                        let username = data["username"] as! String

                        if user >= username[0] {
                            results.append(SearchResult(id: document.documentID, name: name, userName: username))
                        }
                    }

                    self.searchResults = results

                } else {
                    print("there was in error in search for user ")
                }
            }
        }
    }

    
}

struct SearchResult: Identifiable, Hashable {
    var id: String
    var name: String
    var userName: String
}
