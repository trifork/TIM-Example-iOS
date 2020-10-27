import SwiftUI
import TIM
import LocalAuthentication

struct LoginView: View {
    let userId: String
    @State private var hasStoredPasswordWithBioID: Bool = false
    @State private var password: String = ""
    @State private var showAuthenticatedView: Bool = false

    @State private var error: Error?
    
    var body: some View {
        Form {
            Section {
                Text("Welcome \(UserSettings.name(userId: userId) ?? "Unknown")!")
                    .bold()
                    .multilineTextAlignment(.center)
            }
            Section(header: Text("Login with password")) {
                SecureField("PIN", text: $password)
                    .padding()
                    .multilineTextAlignment(.center)
                Button("Login") {
                    TIM.auth.loginWithPassword(userId: userId, password: password, storeNewRefreshToken: true) { (result) in
                        handleLoginResult(result)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .padding()
                .disabled(password.count < 4)
            }
            if hasBioLoginActivated {
                Section(header: Text(biometricIdName)) {
                    Button("Login with \(biometricIdName)") {
                        TIM.auth.loginWithBiometricId(userId: userId, storeNewRefreshToken: true) { (result) in
                            handleLoginResult(result)
                        }
                    }
                }
            }
            if let error = error {
                Section(header: Text("Error status")) {
                    Text(error.localizedDescription)
                        .bold()
                }
                .foregroundColor(.red)
            }
        }
        .navigationBarTitle("Login")
        NavigationLink(
            destination: AuthenticatedView(userId: userId),
            isActive: $showAuthenticatedView,
            label: {
                EmptyView()
            }).hidden()
    }

    private func handleLoginResult(_ result: Result<JWT, Error>) {
        switch result {
        case .success:
            error = nil
            showAuthenticatedView = true
        case .failure(let error):
            print("Failed to login: \(error.localizedDescription)")
            self.error = error
        }
    }

    private var hasBioLoginActivated: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && TIM.storage.hasBiometricAccessForRefreshToken(userId: userId)
    }

    private var biometricIdName: String {
        LAContext().biometryType.biometricIdName
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userId: "userId")
    }
}
