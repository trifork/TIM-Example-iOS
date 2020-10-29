import SwiftUI
import TIM
import LocalAuthentication

struct LoginView: View {
    @ObservedObject var viewModel: LoginView.ViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Login with password")) {
                LoginWithPinCodeView(buttonTitle: "Login", handleLogin: { (pinCode) in
                    viewModel.login(password: pinCode)
                })
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
        .navigationBarTitle(UserSettings.name(userId: viewModel.userId) ?? "Unknown")
        NavigationLink(
            destination: AuthenticatedView(userId: viewModel.userId),
            isActive: $viewModel.showAuthenticatedView,
            label: {
                EmptyView()
            }).hidden()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginView.ViewModel(userId: "userId"))
    }
}
