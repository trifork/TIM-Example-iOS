import SwiftUI
import TIM
import TIMEncryptedStorage
import LocalAuthentication

struct BiometricLoginSettingView: View {
    @Binding var userId: String
    @State var password: String?
    let didFinishBiometricHandling: (Bool) -> Void

    var body: some View {
        NavigationView {
            Form {
                if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    Section {
                        Text("Would you like to enable \(LAContext().biometryType.biometricIdName) login for your user?")
                            .padding([.top, .bottom])
                        if let password = password {
                            Button(enableButtonTitle) {
                                TIM.storage.enableBiometricAccessForRefreshToken(
                                    password: password,
                                    userId: userId,
                                    completion: { handleEnableBiometricResult($0) }
                                )
                            }
                            .padding([.top, .bottom])
                        } else {
                            LoginWithPinCodeView(buttonTitle: enableButtonTitle) { (pinCode: String) in
                                TIM.storage.enableBiometricAccessForRefreshToken(
                                    password: pinCode,
                                    userId: userId,
                                    completion:  { handleEnableBiometricResult($0) }
                                )
                            }
                        }
                    }
                    Section {
                        Button("I don't want to enable biometric login") {
                            didFinishBiometricHandling(false)
                        }
                        .padding([.top, .bottom])
                    }
                } else {
                    Section {
                        Text("Your device does not support FaceID or TouchID.")
                            .padding([.top, .bottom])
                        Button("Alright, let's close this.") {
                            didFinishBiometricHandling(true)
                        }
                        .padding([.top, .bottom])
                    }
                }
            }
            .navigationTitle("Biometric login")
        }
    }

    func handleEnableBiometricResult(_ result: Result<Void, TIMEncryptedStorageError>) {
        switch result {
        case .success:
            print("Successfully enabled biometric login for user.")
            DispatchQueue.main.async {
                didFinishBiometricHandling(true)
            }
        case .failure(let error):
            print("Whoops, something went wrong: \(error.localizedDescription)")
        }
    }

    var enableButtonTitle: String {
        "Enable \(LAContext().biometryType.biometricIdName)"
    }
}

struct BiometricLoginSetting_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLoginSettingView(userId: .constant("UserId"), password: "Password", didFinishBiometricHandling: { _ in })
    }
}
