import SwiftUI
import TIM
import LocalAuthentication

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                    presentationMode.wrappedValue.dismiss()
                })
            )
        })
        .alert(isPresented: $viewModel.sessionExpired, content: {
            Alert(
                title: Text("Session expired"),
                message: Text("Your refresh token has expired. You have to register again."),
                dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                })
            )
        })
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
