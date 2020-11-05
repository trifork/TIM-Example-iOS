import SwiftUI
import Combine
import LocalAuthentication
import TIM

struct AuthenticatedView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot
    @ObservedObject var viewModel: ViewModel

    var body: some View {
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
                                    userId: .constant(viewModel.userId),
                                    password: nil,
                                    didFinishBiometricHandling: { _ in
                                        viewModel.presentBiometricSetting = false
                                        viewModel.updateBioMetricAccessState()
                                    })
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
                    navigationViewRoot.popToRoot = true
                }
                Button("❗ Delete user from this device") {
                    viewModel.deleteUser()
                    navigationViewRoot.popToRoot = true
                }
            }
            .alert(isPresented: $viewModel.showTokenExpiredAlert, content: {
                Alert(
                    title: Text("Your access token has expired!"),
                    message: Text("You will be logged out."),
                    dismissButton: .default(Text("OK")) {
                        navigationViewRoot.popToRoot = true
                    }
                )
            })
            .navigationTitle("Hello \(UserSettings.name(userId: viewModel.userId) ?? "Unknown")!")
            .navigationBarBackButtonHidden(true)
        }
        .onAppear(perform: {
            viewModel.updateBioMetricAccessState()
            viewModel.beginExpirationTimer()
        })
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(viewModel: AuthenticatedView.ViewModel(userId: UUID().uuidString))
    }
}
