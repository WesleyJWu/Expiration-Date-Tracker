import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

struct LocationView: View {
    
    @ObservedObject var userInformation: UserInfo
    @ObservedObject var itemClass = ItemClass()
    var viewName: String
    
    var body: some View {
        VStack {
            ExpListView(userInformation: userInformation, itemClass: itemClass, arrayOfItems: itemClass.itemArray, location: viewName)
        }
        .onAppear() {
            if (userInformation.userIsLoggedIn == true)
            {
                itemClass.createItemListener(location: viewName)
            }
        }
        .onDisappear() {
            itemClass.stopItemListener(location: viewName)
        }
        
    }
}

struct ExpListView: View{
    
    @ObservedObject var userInformation: UserInfo
    @ObservedObject var itemClass: ItemClass
    @State private var editMode = EditMode.inactive
    @State private var showingAddPopover = false
    @State var sortTitle = "Sort"
    let arrayOfItems: [ItemStruc]
    var location: String
   
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ShowingtheSortedView(userInformation: userInformation, sortedArrayOfItems: sortArrayOfItems(items: arrayOfItems, sortMethod: sortTitle))
                }
                .navigationTitle(location)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .font(.headline)
                    }
                    ToolbarItemGroup (placement: .navigationBarTrailing) {
                        Menu(sortTitle) {
                            Button("Expiration Date") {
                                self.sortTitle = "Expiration Date"
                            }
                            Button("Alphabetical Order") {
                                self.sortTitle = "Alphabetical Order"
                            }
                            Button("Date Added") {
                                self.sortTitle = "Date Added"
                            }
                        }
                        .font(.headline)
                        Spacer()
                        Button() {
                            showingAddPopover = true
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .padding(6)
                                .frame(width: 24, height: 24)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .fullScreenCover(isPresented: $showingAddPopover) {
                            AddItemView(showingAddPopover: $showingAddPopover, userInformation: userInformation, location: location)
                                .background(ClearFullCoverBackground())
                                .frame(width: 300, height: 350)
                        }
                    }
                }
                .environment(\.editMode, $editMode)
            }
        }
    }
}

struct ShowingtheSortedView: View {

    @ObservedObject var userInformation: UserInfo
    var ref: DatabaseReference! = Database.database().reference()
    var sortedArrayOfItems: [ItemStruc]

    var body: some View {
            ForEach(sortedArrayOfItems.indices, id: \.self) { index in
                ExpItemView(userInformation: userInformation, ref: ref, arrayOfItems: sortedArrayOfItems, index: index + 1, itemName: sortedArrayOfItems[index].itemName, expirationDateInYearMd: sortedArrayOfItems[index].expirationDate, quantity: sortedArrayOfItems[index].quantity, itemReferenceKey: sortedArrayOfItems[index].itemReferenceKey, location: sortedArrayOfItems[index].location)
                    .listRowBackground((index  % 2 == 0) ? Color(red: 37 / 255, green: 37 / 255, blue: 37 / 255) : Color(red: 31 / 255, green: 31 / 255, blue: 31 / 255))
                    .listRowSeparatorTint(.gray)
            }
            .onDelete(perform: deleteItem)
    }
    func deleteItem(at offsets: IndexSet) {
        for n in offsets {
            let itemAutoID = sortedArrayOfItems[n].itemReferenceKey
            ref.child("users").child("/" + (Auth.auth().currentUser?.uid)! + "/").child(sortedArrayOfItems[n].location).child(itemAutoID).removeValue()
        }
    }
}

struct ExpItemView: View {
    
    @ObservedObject var userInformation: UserInfo
    @State private var showingEditPopover = false
    var ref: DatabaseReference!
    var arrayOfItems: [ItemStruc]
    var index: Int
    var itemName : String
    var expirationDateInYearMd : String // YY/MM/dd
    var quantity: String
    var itemReferenceKey : String
    var location: String
        
    var body: some View {
        HStack {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
            Text(itemName)
            Text("-  " + quantity)
                .font(.system(size: 15))
                .opacity(0.5)
            Spacer()
            Text(YearMdtoMonthdY(expirationDateInYearMd: expirationDateInYearMd))
        }
        .onTapGesture {
            showingEditPopover = true
        }
        .fullScreenCover(isPresented: $showingEditPopover) {
            let oldDate = dateConverterFromYYMMddToDate(dateAsString: expirationDateInYearMd)!
            EditItemView(showingEditPopover: $showingEditPopover, userInformation: userInformation, index: index, itemName: itemName, quantity: quantity, expirationDate: oldDate, location: location, potentiallynewlocation: location, itemReferenceKey: itemReferenceKey, ref: ref)
                .background(ClearFullCoverBackground())
                .frame(width: 300, height: 350)
        }
    }
}

func sortArrayOfItems(items: [ItemStruc], sortMethod: String) -> [ItemStruc] {
    if (sortMethod == "Sort" || sortMethod == "Date Added") {
        return items
    }
    else if (sortMethod == "Expiration Date") {
        return items.sorted{$0.expirationDate<$1.expirationDate}
    }
    else if (sortMethod == "Alphabetical Order") {
        return items.sorted {$0.itemName<$1.itemName}
    }
    return items
}

func dateConverterFromYYMMddToDate(dateAsString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "YY/MM/dd"
    return formatter.date(from: dateAsString)
}

func YearMdtoMonthdY(expirationDateInYearMd: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "YY/MM/dd"
    let date = dateFormatter.date(from: expirationDateInYearMd)
    dateFormatter.dateFormat = "MM/dd/YY"
    let resultString = dateFormatter.string(from: date!)
    return(resultString)
}


struct ClearFullCoverBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async{
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(viewName: "Fridge")
    }
}
