import SwiftUI
import TIM

struct WelcomeView: View {
    @State private var hasRefreshToken: Bool = false
    @State private var hasStoredRefreshToken: Bool = false
    @State private var availableUserIds: [String] = Array(TIM.storage.availableUserIds)
    @State private var showLoginAlert: Bool = false
    @State private var pushCreateNewPin: Bool = false

    @EnvironmentObject var navigationViewRoot: NavigationViewRoot

    private var topViewController: UIViewController {
        UIApplication.shared.windows.first!.rootViewController!
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Login")) {
                        if availableUserIds.isEmpty {
                            Text("You are the first user on this device. Login as new user to get started.")
                                .padding([.top, .bottom])
                        } else {
                            ForEach(Array(availableUserIds), id: \.self) { (id) in
                                NavigationLink(UserSettings.name(userId: id) ?? id, destination: LoginView(userId: id))
                                    .padding([.top, .bottom])
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    Section(header: Text("New user")) {
                        Button("🆕 New user on this device") {
                            performOIDCLogin()
                        }.alert(isPresented: $showLoginAlert, content: {
                            Alert(
                                title: Text("Oops!"),
                                message: Text("Login failed. Please try again."),
                                dismissButton: .default(Text("OK"))
                            )
                        })
                    }
                    Section(header: Text("Reset")) {
                        Button("🗑 Reset everything") {
                            availableUserIds.forEach { (id) in
                                UserSettings.clear(userId: id)
                                TIM.storage.clear(userId: id)
                            }
                            TIM.auth.logout()
                            updateDataState()
                        }
                    }
                }
                NavigationLink(
                    destination: CreateNewPinCodeView(),
                    isActive: Binding(
                        get: { self.pushCreateNewPin && !self.navigationViewRoot.popToRoot },
                        set: { v in
                            self.pushCreateNewPin = v
                            self.navigationViewRoot.popToRoot = false
                        }
                    )) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarTitle("TIM Example")
            .onAppear(perform: {
                updateDataState()
            })
            .multilineTextAlignment(.center)
        }
    }

    func updateDataState() {
        availableUserIds = Array(TIM.storage.availableUserIds)
    }

    private func performOIDCLogin() {
        TIM.auth.performOpenIDConnectLogin(presentingViewController: topViewController) { (res: Result<JWT, Error>) in
            switch res {
            case .success(let accessToken):
                print("Received access token and refresh token.\nAT:\n\(accessToken)")
                DispatchQueue.main.async {
                    self.pushCreateNewPin = true
                }
            case .failure(let error):
                showLoginAlert = true
                print("Failed.\n\(error.localizedDescription)")
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
