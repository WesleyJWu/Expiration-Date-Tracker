import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

struct ItemStruc: Identifiable {
    var id = UUID().uuidString
    var itemName: String
    var expirationDate: String
    var quantity: String
    var itemReferenceKey: String
    var location: String
}

class ItemClass: ObservableObject {
    
    @Published var itemArray = [ItemStruc]()
    var ref: DatabaseReference! = Database.database().reference()
    var userHandle: DatabaseHandle?
    
    func createItemListener(location: String) {
        print("starting item listener" + location)
        userHandle = ref.child("users").child("/" + (Auth.auth().currentUser?.uid)! + "/").child(location).observe(.value) { snapshot in
            self.itemArray = []
            let enumator = snapshot.children
            
            while let rest = enumator.nextObject() as? DataSnapshot {
                let dict  = rest.value as? [String : AnyObject] ?? [:]
                let itemItem = ItemStruc(itemName: dict["ItemName"] as! String, expirationDate: dict["ExpirationDateYearMonthDay"] as! String, quantity: dict["Quantity"] as! String, itemReferenceKey: dict["ItemReferenceKey"] as! String, location: location)
                self.itemArray.append(itemItem)
            }
        }
    }
    
    func stopItemListener(location: String) {
        print("STOPPING item listener" + location)
        if userHandle != nil {
            ref.child("users").child("/" + (Auth.auth().currentUser?.uid)! + "/").child(location).removeObserver(withHandle: userHandle!)
        }
    }
}

