import SwiftUI
import TIM
import TIMEncryptedStorage
import LocalAuthentication

struct BiometricLoginSettingView: View {
    @ObservedObject var viewModel: BiometricLoginSettingView.ViewModel

    var body: some View {
        NavigationView {
            Form {
                if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    Section {
                        Text("Would you like to enable \(LAContext().biometryType.biometricIdName) login for your user?")
                            .padding([.top, .bottom])
                        if viewModel.password?.isEmpty == false {
                            Button(enableButtonTitle) {
                                viewModel.enableBioForRefreshToken()
                            }
                            .padding([.top, .bottom])
                        } else {
                            LoginWithPinCodeView(buttonTitle: enableButtonTitle) { (pinCode: String) in
                                viewModel.enableBioForRefreshToken(password: pinCode)
                            }
                        }
                    }
                    Section {
                        Button("I don't want to enable biometric login") {
                            viewModel.didFinishBiometricHandling(false)
                        }
                        .padding([.top, .bottom])
                    }
                } else {
                    Section {
                        Text("Your device does not support FaceID or TouchID.")
                            .padding([.top, .bottom])
                        Button("Alright, let's close this.") {
                            viewModel.didFinishBiometricHandling(false)
                        }
                        .padding([.top, .bottom])
                    }
                }
            }
            .navigationTitle("Biometric login")
        }
    }

    

    var enableButtonTitle: String {
        "Enable \(LAContext().biometryType.biometricIdName)"
    }
}

struct BiometricLoginSetting_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLoginSettingView(
            viewModel: BiometricLoginSettingView.ViewModel(
                userId: .constant("<userID>"),
                password: nil,
                didFinishBiometricHandling: { _ in }
            )
        )
    }
}
