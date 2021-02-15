import SwiftUI
import TIM
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot
    @ObservedObject var viewModel: LoginView.ViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Login with password")) {
                LoginWithPinCodeView(buttonTitle: "Login", handleLogin: { (pinCode) in
                    viewModel.login(password: pinCode)
                })
                if viewModel.wrongPin {
                    Text("Wrong PIN!")
                        .foregroundColor(.red)
                        .italic()
                }
            }
            .disabled(viewModel.isLoading)
            if viewModel.hasBioLoginActivated {
                Section(header: Text(viewModel.biometricIdName)) {
                    Button("Login with \(viewModel.biometricIdName)") {
                        viewModel.loginWithBio()
                    }
                }
                .disabled(viewModel.isLoading)
            }
            if let error = viewModel.error {
                Section(header: Text("Error status")) {
                    Text(error.localizedDescription)
                        .bold()
                        .foregroundColor(.red)
                }
            } else if viewModel.isLoading {
                Text("Logging in...")
                    .multilineTextAlignment(.center)
            }
        }
        .alert(isPresented: $viewModel.keyInvalidated, content: {
            Alert(
                title: Text("Key invalid"),
                message: Text("You have too many failed tries. The PIN has been invalidated. You have to register again."),
                dismissButton: .default(Text("OK"), action: {
                    navigationViewRoot.popToRoot = true
                })
            )
        })
        .alert(isPresented: $viewModel.sessionExpired, content: {
            Alert(
                title: Text("Session expired"),
                message: Text("Your refresh token has expired. You have to register again."),
                dismissButton: .default(Text("OK"), action: {
                    navigationViewRoot.popToRoot = true
                })
            )
        })
        .navigationBarTitle(UserSettings.name(userId: viewModel.userId) ?? "Unknown")
        .sheet(
            isPresented: $viewModel.showAuthenticatedView, content: {
                AuthenticatedView(
                    viewModel: AuthenticatedView.ViewModel(
                        userId: viewModel.userId
                    )
                )
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginView.ViewModel(userId: "userId"))
    }
}
