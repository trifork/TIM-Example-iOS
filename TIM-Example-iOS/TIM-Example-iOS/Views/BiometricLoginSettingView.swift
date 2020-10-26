import SwiftUI
import TIM
import LocalAuthentication

struct BiometricLoginSettingView: View {
    let userId: String
    let password: String

    @State private var presentLoginView = false

    private var biometricIdName: String {
        switch LAContext().biometryType {
        case .faceID:
            return "FaceID"
        case .touchID:
            return "TouchID"
        default:
            return "N/A"
        }
    }

    var body: some View {
        VStack {
            if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                Text("Would you like to enable \(biometricIdName) login for your user?")
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
                                    DispatchQueue.main.async {
                                        presentLoginView = true
                                    }
                                case .failure(let error):
                                    print("Whoops, something went wrong: \(error.localizedDescription)")
                                }
                            }
                        }
                    })
                    .padding()
                NavigationLink("No, continue to login", destination: LoginView(userId: userId))
                    .padding()
            } else {
                Text("Your device does not support FaceID or TouchID. Please continue to login with your pin code.")
                NavigationLink("Continue to login", destination: LoginView(userId: userId))
                    .padding()
            }

        }

    }
}

struct BiometricLoginSetting_Previews: PreviewProvider {
    static var previews: some View {
        BiometricLoginSettingView(userId: "UserId", password: "Password")
    }
}
