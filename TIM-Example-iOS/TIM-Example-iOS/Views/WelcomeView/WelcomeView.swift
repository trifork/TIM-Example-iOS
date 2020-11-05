import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel = WelcomeView.ViewModel()
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot

    private var topViewController: UIViewController {
        UIApplication.shared.windows.first!.rootViewController!
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Login")) {
                        if viewModel.availableUserIds.isEmpty {
                            Text("You are the first user on this device. Login as new user to get started.")
                                .padding([.top, .bottom])
                        } else {
                            ForEach(Array(viewModel.availableUserIds), id: \.self) { (id) in
                                NavigationLink(
                                    UserSettings.name(userId: id) ?? id,
                                    destination: LoginView(
                                        viewModel: LoginView.ViewModel(
                                            userId: id
                                        )
                                    ),
                                    isActive: Binding(
                                        get: { self.viewModel.pushLogin && !self.navigationViewRoot.popToRoot },
                                        set: { v in
                                            self.viewModel.pushLogin = v
                                            self.navigationViewRoot.popToRoot = false
                                        }
                                    )
                                )
                                .padding([.top, .bottom])
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    Section(header: Text("New user")) {
                        Button("🆕 New user on this device") {
                            viewModel.performOIDCLogin(topViewController: topViewController)
                        }.alert(isPresented: $viewModel.showLoginAlert, content: {
                            Alert(
                                title: Text("Oops!"),
                                message: Text("Login failed. Please try again."),
                                dismissButton: .default(Text("OK"))
                            )
                        })
                    }
                    Section(header: Text("Reset")) {
                        Button("🗑 Reset everything") {
                            viewModel.clear()
                        }
                    }
                }
                NavigationLink(
                    destination: CreateNewPinCodeView(),
                    isActive: Binding(
                        get: { self.viewModel.pushCreateNewPin && !self.navigationViewRoot.popToRoot },
                        set: { v in
                            self.viewModel.pushCreateNewPin = v
                            self.navigationViewRoot.popToRoot = false
                        }
                    )) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarTitle("TIM Example")
            .onAppear(perform: {
                viewModel.update()
            })
            .multilineTextAlignment(.center)
        }
    }


    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
