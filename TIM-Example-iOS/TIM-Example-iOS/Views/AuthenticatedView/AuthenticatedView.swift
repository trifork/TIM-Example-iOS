import SwiftUI
import Combine
import LocalAuthentication

struct AuthenticatedView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    @Binding var resetNavigation: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("You have successfully logged in with either PIN code or Biometric ID! 🥳")
                }
                Section(header: Text("Active tokens")) {
                    NavigationLink("Access Token", destination: TokenView(viewModel: TokenView.ViewModel(tokenType: .accessToken)))
                    NavigationLink("Refresh Token", destination: TokenView(viewModel: TokenView.ViewModel(tokenType: .refreshToken)))
                }
                Section(header: Text("Biometric settings")) {
                    if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        if viewModel.hasBiometricAccess {
                            Button("Disable \(LAContext().biometryType.biometricIdName) for this user") {
                                viewModel.disableBiometricsForUser()
                            }
                        } else {
                            Button("Enable \(LAContext().biometryType.biometricIdName) for this user") {
                                viewModel.presentBiometricSetting = true
                            }.sheet(isPresented: $viewModel.presentBiometricSetting, content: {
                                BiometricLoginSettingView(
                                    viewModel: BiometricLoginSettingView.ViewModel(
                                        userId: viewModel.userId,
                                        password: nil,
                                        didFinishBiometricSetting: $viewModel.presentBiometricSetting
                                    )
                                )
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
                        Text(viewModel.userId)
                    }
                }
                Section(header: Text("Exit")) {
                    Button("🚪 Log out") {
                        viewModel.logout()
                        resetNavigation = true
                    }
                    Button("❗ Delete user from this device") {
                        viewModel.deleteUser()
                        resetNavigation = true
                    }
                }
            }
            .alert(isPresented: $viewModel.showTokenExpiredAlert, content: {
                Alert(
                    title: Text("Your access token has expired!"),
                    message: Text("You will be logged out."),
                    dismissButton: .default(Text("OK")) {
                        resetNavigation = true
                    }
                )
            })
            .navigationTitle("Hello \(UserSettings.name(userId: viewModel.userId) ?? "Unknown")!")
            .onAppear(perform: {
                viewModel.updateBioMetricAccessState()
                viewModel.beginExpirationTimer()
            })
            .onReceive(viewModel.$presentBiometricSetting, perform: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    viewModel.updateBioMetricAccessState()
                }
            })
        }
        .onReceive(Just(resetNavigation), perform: { reset in
            if reset {
                presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(viewModel: AuthenticatedView.ViewModel(userId: UUID().uuidString), resetNavigation: .constant(false))
    }
}
