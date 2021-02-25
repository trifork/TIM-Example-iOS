import SwiftUI
import TIM
import LocalAuthentication
import Combine

struct LoginView: View {
    @ObservedObject var viewModel: LoginView.ViewModel
    @State var popToRoot: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
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
        .background(
            EmptyView()
                .alert(isPresented: $viewModel.keyInvalidated, content: {
                    Alert(
                        title: Text("Key invalid"),
                        message: Text("You have too many failed tries. The PIN has been invalidated. You have to register again."),
                        dismissButton: .default(Text("OK"), action: {
                            popToRoot = true
                        })
                    )
                })
        )
        .background(
            EmptyView()
                .alert(isPresented: $viewModel.sessionExpired, content: {
                    Alert(
                        title: Text("Session expired"),
                        message: Text("Your refresh token has expired. You have to register again."),
                        dismissButton: .default(Text("OK"), action: {
                            popToRoot = true
                        })
                    )
                })
        )
        .background(
            EmptyView()
                .alert(isPresented: $viewModel.keyServiceFailed, content: {
                    Alert(
                        title: Text("Failed to communicate with KeyService"),
                        message: Text("Something went wrong while trying to contact key service. Please check your internet connection and try again."),
                        dismissButton: .default(Text("OK"), action: { })
                    )
                })
        )
        .navigationBarTitle(UserSettings.name(userId: viewModel.userId) ?? "Unknown")
        .fullScreenCover(
            isPresented: $viewModel.showAuthenticatedView, content: {
                AuthenticatedView(
                    viewModel: AuthenticatedView.ViewModel(
                        userId: viewModel.userId
                    ),
                    resetNavigation: $popToRoot
                )
        })
        .onReceive(Just(popToRoot), perform: { popToRoot in
            if popToRoot {
                presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginView.ViewModel(userId: "userId"))
    }
}
