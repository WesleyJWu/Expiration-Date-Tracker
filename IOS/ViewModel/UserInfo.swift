import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

class UserInfo: ObservableObject {
    
    @Published var uid = ""
    @Published var user = ""
    @Published var userIsLoggedIn : Bool = false
    @Published var index = ""
    @Published var postData = [String]()
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference! = Database.database().reference()
    
    func listen() { // Listens to see if a user is logged in
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if let user = user {
                print ("User \(user.uid) signed in")
                self.userIsLoggedIn = true
                self.uid = user.uid
            }
            else{
                self.userIsLoggedIn = false
                print("No user found")
            }
        })
    }
    
    func signUp(email: String, password: String) {
        // requires an email that is in the form of X@Y.com
        // requires password that is at least 6 chracters long
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if (email == "" || password == "") {
                print(error!.localizedDescription)
            }
        }
        print("Signed up successfully")
    }
    
    func signOut() {
        self.userIsLoggedIn = false
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
