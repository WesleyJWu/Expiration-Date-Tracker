import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase

struct HomeView: View {
    
    @ObservedObject var userInformation: UserInfo
    @ObservedObject var itemClassFridge = ItemClass()
    @ObservedObject var itemClassFreezer = ItemClass()
    @ObservedObject var itemClassPantry = ItemClass()
    
    var body: some View {
        VStack {
            FullListView(userInformation: userInformation, itemClassFridge: itemClassFridge, itemClassFreezer: itemClassFreezer, itemClassPantry: itemClassPantry,  arrayOfExpiredItems: createAlreadyExpiredItemArray(items: combineArrayOfItems(itemsFridgeArray: itemClassFridge.itemArray, itemsFreezerArray: itemClassFreezer.itemArray, itemsPantryArray: itemClassPantry.itemArray)), arrayOf1WeekExpItems: createExpIn1WeekItemArray(items: combineArrayOfItems(itemsFridgeArray: itemClassFridge.itemArray, itemsFreezerArray: itemClassFreezer.itemArray, itemsPantryArray: itemClassPantry.itemArray)), arrayOfTotalItems: combineArrayOfItems(itemsFridgeArray: itemClassFridge.itemArray, itemsFreezerArray: itemClassFreezer.itemArray, itemsPantryArray: itemClassPantry.itemArray))
        }
        .onAppear() {
            itemClassFridge.createItemListener(location: "Fridge")
            itemClassFreezer.createItemListener(location: "Freezer")
            itemClassPantry.createItemListener(location: "Pantry")
        }
        .onDisappear() {
            itemClassFridge.stopItemListener(location: "Fridge")
            itemClassFreezer.stopItemListener(location: "Freezer")
            itemClassPantry.stopItemListener(location: "Pantry")
        }
    }
}

struct FullListView: View{
    
    @ObservedObject var userInformation: UserInfo
    
    @ObservedObject var itemClassFridge: ItemClass
    @ObservedObject var itemClassFreezer: ItemClass
    @ObservedObject var itemClassPantry: ItemClass
    
    @State private var editMode = EditMode.inactive
    @State private var showingAddPopover = false
    @State var sortTitle = "Sort"
    
    let arrayOfExpiredItems: [ItemStruc]
    let arrayOf1WeekExpItems: [ItemStruc]
    let arrayOfTotalItems: [ItemStruc]
   
    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Items Already Expired"), footer: Text(String(arrayOfExpiredItems.count) + " Items"))
                    {
                        ShowingtheSortedView(userInformation: userInformation, sortedArrayOfItems: sortArrayOfItems(items: arrayOfExpiredItems, sortMethod: sortTitle))
                    }
                    Section(header: Text("Items Expiring in 1 week"), footer: Text(String(arrayOf1WeekExpItems.count) + " Items"))
                    {
                        ShowingtheSortedView(userInformation: userInformation, sortedArrayOfItems: sortArrayOfItems(items: arrayOf1WeekExpItems, sortMethod: sortTitle))
                    }
                    Section(header: Text("All Items"), footer: Text(String(arrayOfTotalItems.count) + " Items"))
                    {
                        ShowingtheSortedView(userInformation: userInformation, sortedArrayOfItems: sortArrayOfItems(items: arrayOfTotalItems, sortMethod: sortTitle))
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Home")
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
                        Button("Logout") {
                            itemClassFridge.stopItemListener(location: "Fridge")
                            itemClassFreezer.stopItemListener(location: "Freezer")
                            itemClassPantry.stopItemListener(location: "Pantry")
                            userInformation.signOut()
                        }
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
                            AddItemView(showingAddPopover: $showingAddPopover, userInformation: userInformation, location: "Fridge")
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

func combineArrayOfItems(itemsFridgeArray: [ItemStruc], itemsFreezerArray: [ItemStruc], itemsPantryArray: [ItemStruc]) -> [ItemStruc] {
    var itemsTotal: [ItemStruc] = []
    itemsTotal.append(contentsOf: itemsFridgeArray)
    itemsTotal.append(contentsOf: itemsFreezerArray)
    itemsTotal.append(contentsOf: itemsPantryArray)
    return(itemsTotal)
}

func createAlreadyExpiredItemArray(items: [ItemStruc]) -> [ItemStruc] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YY/MM/dd"
    let currentDay = dateFormatter.string(from: Date())
    let itemsAlreadyExpired: [ItemStruc] = items.filter(){$0.expirationDate<currentDay}
    return(itemsAlreadyExpired)
}

func createExpIn1WeekItemArray(items: [ItemStruc]) -> [ItemStruc] {
    let currentDate = Date()
    var dateComponent = DateComponents()
    dateComponent.day = 7
    let sevenDaysAhead = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? Date.now
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YY/MM/dd"
    let currentDay = dateFormatter.string(from: Date())
    let string7DaysAhead = dateFormatter.string(from: sevenDaysAhead)
    var itemsExpIn1Week: [ItemStruc] = items.filter(){$0.expirationDate<string7DaysAhead}
    itemsExpIn1Week = itemsExpIn1Week.filter(){currentDay <= $0.expirationDate}
    return(itemsExpIn1Week)
}

