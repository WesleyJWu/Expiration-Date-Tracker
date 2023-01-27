import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

struct AddItemView: View {
    
    @Binding var showingAddPopover: Bool
    @ObservedObject var userInformation: UserInfo
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var expirationDate = Date()
    @State var location: String
    @State private var showingAlert = false
    var ref: DatabaseReference! = Database.database().reference()
    var diffLocations = ["Fridge", "Freezer", "Pantry"]
    
    var body: some View {
        var stringExpDate = ""
        ZStack {
            Form {
                Section (header: HStack {
                    Spacer()
                    Text("Add Item")
                    Spacer()
                }) {
                    TextField("Item Name", text: $itemName)
                    TextField("Quantity", text: $quantity)
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                    Picker(selection: $location, label: Text("Location")) {
                        ForEach(diffLocations, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    HStack {
                        Button("Submit") {
                            print(userInformation.uid)
                            print(location)
                            if (itemName == "" || quantity == "") {
                                showingAlert = true
                            }
                            else {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "YY/MM/dd"
                                stringExpDate = dateFormatter.string(from: expirationDate)
                                let itemReference = ref.child("users").child(userInformation.uid).child(location).childByAutoId()
                                guard let keyOfItemRef: String = itemReference.key else {
                                    return
                                }
                                itemReference
                                    .updateChildValues(["ItemName": itemName,
                                                        "Quantity": quantity,
                                                        "ExpirationDateYearMonthDay": stringExpDate,
                                                        "ItemReferenceKey": keyOfItemRef
                                                       ])
                                showingAddPopover = false
                                print("Successfully Added Item to Firebase Realtime Database")
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert("Invalid Changes", isPresented: $showingAlert) {
                            Button("Ok", role: .cancel) {}
                        } message: {
                            Text("Please do not leave empty boxes")
                        }
                        Spacer()
                        Button("Cancel") {
                            print("Cancel")
                            showingAddPopover = false
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .frame(width: 300, height: 350)
        .cornerRadius(15)
    }
}

struct EditItemView: View {
    
    @Binding var showingEditPopover: Bool
    @ObservedObject var userInformation: UserInfo
    @State var index: Int
    @State var itemName: String
    @State var quantity: String
    @State var expirationDate: Date
    @State var location: String
    @State var potentiallynewlocation: String
    @State var itemReferenceKey : String
    @State private var showingAlert1 = false
    var ref: DatabaseReference!
    var diffLocations = ["Fridge", "Freezer", "Pantry"]
    
    var body: some View {
        let dateFormatter = DateFormatter()
        var stringExpDate = ""
        ZStack {
            Form {
                Section (header:
                            HStack {
                    Spacer()
                    Text("Edit Item")
                    Spacer()
                }
                )
                {
                    HStack {
                        Text("Item Name: ").font(.system(size: 18).bold())
                        TextField("Item Name", text: $itemName)
                    }
                    HStack {
                        Text("Quantity: ").font(.system(size: 18).bold())
                        TextField("Quantity", text: $quantity)
                    }
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date).font(.system(size: 18).bold())
                    
                    Picker(selection: $potentiallynewlocation, label: Text("Location")) {
                        ForEach(diffLocations, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    HStack {
                        Button("Submit Changes") {
                            print(expirationDate)
                            print(userInformation.uid)
                            print(potentiallynewlocation)
                            dateFormatter.dateFormat = "YY/MM/dd"
                            stringExpDate = dateFormatter.string(from: expirationDate)
                            if (itemName == "" || quantity == "") {
                                showingAlert1 = true
                            }
                            else {
                                if (potentiallynewlocation != location) {
                                    // Deletes the item at that location before moving it to another location
                                    ref.child("users").child(userInformation.uid).child(location).child(itemReferenceKey).removeValue()
                                    let itemReference = ref.child("users").child(userInformation.uid).child(potentiallynewlocation).childByAutoId()
                                    guard let keyOfItemRef: String = itemReference.key else {
                                        return
                                    }
                                    itemReference
                                        .updateChildValues(["ItemName": itemName,
                                                            "Quantity": quantity,
                                                            "ExpirationDateYearMonthDay": stringExpDate,
                                                            "ItemReferenceKey": keyOfItemRef
                                                           ])
                                    showingEditPopover = false
                                    print("Successfully Moved Item to a diff location")
                                } else { // Edits the item within the same location
                                    ref.child("users").child(userInformation.uid).child(location).child(itemReferenceKey)
                                        .updateChildValues(["ItemName": itemName,
                                                            "Quantity": quantity,
                                                            "ExpirationDateYearMonthDay": stringExpDate,
                                                            "ItemReferenceKey": itemReferenceKey
                                                           ])
                                    showingEditPopover = false
                                    print("Successfully Edited Item")
                                }
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert("Invalid Changes", isPresented: $showingAlert1) {
                            Button("Ok", role: .cancel) {}
                        } message: {
                            Text("Please do not leave empty boxes")
                        }
                        Spacer()
                        Button("Cancel") {
                            print("Cancel")
                            showingEditPopover = false
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .frame(width: 300, height: 325)
    }
}

