import SwiftUI
import Combine
import LocalAuthentication
import TIM

struct AuthenticatedView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot
    @ObservedObject var biometricAccessOberserver = BiometricAccessObserver()

    @State private var presentBiometricSetting: Bool = false

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
            Section(header: Text("Biometric settings")) {
                if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    if biometricAccessOberserver.hasBiometricAccess {
                        Button("Disable \(LAContext().biometryType.biometricIdName) for this user") {
                            TIM.storage.disableBiometricAccessForRefreshToken(userId: userId)
                            biometricAccessOberserver.update(userId: userId)
                        }
                    } else {
                        Button("Enable \(LAContext().biometryType.biometricIdName) for this user") {
                            presentBiometricSetting = true
                        }.sheet(isPresented: $presentBiometricSetting, content: {
                            BiometricLoginSettingView(
                                userId: .constant(userId),
                                password: nil,
                                didFinishBiometricHandling: { _ in
                                    presentBiometricSetting = false
                                    biometricAccessOberserver.update(userId: userId)
                                })
                        })
                    }
                } else {
                    Text("Biometric login is not avilable on this device.")
                }
            }
            Section(header: Text("User data")) {
                HStack {
                    Text("UserId")
                        .bold()
                    Spacer()
                    Text(userId)
                }
            }
            Section(header: Text("Exit")) {
                Button("🚪 Log out") {
                    TIM.auth.logout()
                    navigationViewRoot.popToRoot = true
                }
                Button("❗ Delete user from this device") {
                    TIM.auth.logout()
                    TIM.storage.clear(userId: userId)
                    UserSettings.clear(userId: userId)
                    navigationViewRoot.popToRoot = true
                }
            }
            .navigationTitle("Hello \(UserSettings.name(userId: userId) ?? "Unknown")!")
            .navigationBarBackButtonHidden(true)
        }
        .onAppear(perform: {
            biometricAccessOberserver.update(userId: userId)
        })
    }
}

class BiometricAccessObserver: ObservableObject {

    let objectWillChange = PassthroughSubject<BiometricAccessObserver,Never>()

    var hasBiometricAccess: Bool = false {
        didSet {
            objectWillChange.send(self)
        }
    }

    func update(userId: String) {
        hasBiometricAccess = TIM.storage.hasBiometricAccessForRefreshToken(userId: userId)
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(biometricAccessOberserver: BiometricAccessObserver(), userId: UUID().uuidString)
    }
}
