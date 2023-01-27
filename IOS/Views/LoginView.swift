import SwiftUI
import Firebase

struct LoginView: View {
    @ObservedObject var userInformation = UserInfo()
    @State var email = ""
    @State var password = ""
    
    init() {
        // Initializers are called when the view is constructed (including when state changes force the view to be rebuilt)
        userInformation.listen()
    }
    
    var body: some View {
        if userInformation.userIsLoggedIn {
            TabViews(userInformation: userInformation)
        } else {
            login
        }
    }
    
    var login: some View {
        VStack {
            Text("Expiration List Tracker")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .offset(y: -40)
            TextField("Email", text: $email)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                .padding()
                .offset(y: -60)
            
            SecureField("Password", text: $password)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                .padding()
                .offset(y:-90)
            Button {
                userInformation.logIn(email: email, password: password)
            } label: {
                Text("Log In")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
            }
            .offset(y:-80)
            Button {
                userInformation.signUp(email: email, password: password)
            } label: {
                Text("Sign up")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
            }
            .offset(y:-65)
        }
        .frame(width: 350)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}

