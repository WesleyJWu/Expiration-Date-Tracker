import SwiftUI

struct TabViews: View {
    
    @ObservedObject var userInformation: UserInfo
    @State var selectedTab = "0"
    
    var body: some View {
        TabView (selection: $selectedTab) {
            HomeView(userInformation: userInformation)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag("0")
            
            LocationView(userInformation: userInformation, viewName: "Fridge")
                .tabItem {
                    Label("Fridge", systemImage: "refrigerator")
                }
                .tag("1")
            
            LocationView(userInformation: userInformation, viewName: "Freezer")
                .tabItem {
                    Label("Freezer", systemImage: "snowflake")
                }
                .tag("2")
            
            LocationView(userInformation: userInformation, viewName: "Pantry")
                .tabItem {
                    Label("Pantry", systemImage: "cabinet")
                }
                .tag("3")
        }.background(.black)
    }
}

struct TabViews_Previews: PreviewProvider {
    static var previews: some View {
        TabViews()
            .preferredColorScheme(.dark)
    }
}
