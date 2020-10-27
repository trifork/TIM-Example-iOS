import SwiftUI
import TIM

struct AuthenticatedView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot

    let userId: String
    var body: some View {
        Form {
            Section {
                Text("You have successfully logged in with either PIN code or Biometric ID! 🥳")
            }
            Section(header: Text("Active tokens")) {
                NavigationLink("Access Token", destination: TokenView(tokenType: .accessToken))
                NavigationLink("Refresh Token", destination: TokenView(tokenType: .refreshToken))
            }
            Section(header: Text("Stored values")) {
                Text("Bio ID is enabeld/disabled")
            }
            Section(header: Text("User data")) {
                Text("UserId:")
                Text(userId)
            }
            Section {
                Button("🚪 Log out") {
                    TIM.auth.logout()
                    navigationViewRoot.popToRoot = true
                }
            }
            .navigationTitle("Hello \(UserSettings.name(userId: userId) ?? "Unknown")!")
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(userId: UUID().uuidString)
    }
}
