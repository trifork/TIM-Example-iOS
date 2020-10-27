import SwiftUI
import TIM
import LocalAuthentication

struct BiometricLoginSettingView: View {
    let userId: String
    let password: String
    
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot
    @State private var presentLoginView = false

    var body: some View {
        Form {
            if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                Section {
                    Text("Would you like to enable \(LAContext().biometryType.biometricIdName) login for your user?")
                    NavigationLink(
                        destination: LoginView(userId: userId),
                        isActive: $presentLoginView,
                        label: {
                            Button("Enable FaceID") {
                                TIM.storage.enableBiometricAccessForRefreshToken(
                                    password: password,
                                    userId: userId) { (result) in
                                    switch result {
                                    case .success:
                                        print("Successfully enabled biometric login for user.")
                                        DispatchQueue.main.async {
                                            self.navigationViewRoot.popToRoot = true
                                        }
                                    case .failure(let error):
                                        print("Whoops, something went wrong: \(error.localizedDescription)")
                                    }
                                }
                            }
                        })
                        .padding()
                }
                Section {
                    Button("No, continue to login") {
                        self.navigationViewRoot.popToRoot = true
                    }
                    .padding()
                }
            } else {
                Section {
                    Text("Your device does not support FaceID or TouchID. Please continue to login with your pin code.")
                        .padding([.top, .bottom])
                    Button("Continue to login") {
                        self.navigationViewRoot.popToRoot = true
                    }
                    .padding([.top, .bottom])
                }
            }
        }
        .navigationTitle("Biometric login")

    }
}

struct BiometricLoginSetting_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLoginSettingView(userId: "UserId", password: "Password")
    }
}
