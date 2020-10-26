//
//  ContentView.swift
//  TriforkIdentityManager-Swift-Example
//
//  Created by Thomas Kalhøj Clemensen on 20/10/2020.
//

import SwiftUI
import TIM

struct ContentView: View {
    @State private var hasRefreshToken: Bool = false
    @State private var hasStoredRefreshToken: Bool = false
    @State private var availableUserIds: [String] = Array(TIM.storage.availableUserIds)
    @State private var showLoginAlert: Bool = false
    @State private var pushCreateNewPin: Bool = false

    private var topViewController: UIViewController {
        UIApplication.shared.windows.first!.rootViewController!
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("Welcome to TIM!")
                    .bold()
                if availableUserIds.isEmpty {
                    Text("You are the first user on this device. Tap the button below to get started.")
                } else {
                    Text("Tap the user you want to login for:")
                    ScrollView {
                        ForEach(Array(availableUserIds), id: \.self) { (id) in
                            NavigationLink(id, destination: FreshLoginView())
                        }
                    }
                }
                //Spacer()
                NavigationLink(
                    destination: CreateNewPinCodeView(),
                    isActive: $pushCreateNewPin,
                    label: {
                        Button("I am a new user on this device") {
                            performOIDCLogin()
                        }.alert(isPresented: $showLoginAlert, content: {
                            Alert(
                                title: Text("Oops!"),
                                message: Text("Login failed. Please try again."),
                                dismissButton: .default(Text("OK"))
                            )

                        })
                    })

//                NavigationLink("🆕 Fresh OIDC login", destination: FreshLoginView())
//                NavigationLink("📦 Store tokens", destination: StorageView())
//                    .disabled(!hasRefreshToken)
//                NavigationLink("🔑 Login", destination: LoginView())
//                    .disabled(!hasStoredRefreshToken)
                Button("🗑 Reset everything") {
                    availableUserIds.forEach(TIM.storage.clear)
                    TIM.auth.logout()
                    updateDataState()
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            .navigationBarTitle("Trifork Identity Manager", displayMode: .inline)
            .onAppear(perform: {
                updateDataState()
            })
        }
    }

    func updateDataState() {
        availableUserIds = Array(TIM.storage.availableUserIds)
//        hasRefreshToken = TIM.auth.refreshToken != nil
//        hasStoredRefreshToken = TIM.storage.hasStoredRefreshToken
    }

    private func performOIDCLogin() {
        TIM.auth.performOpenIDConnectLogin(presentingViewController: topViewController) { (res: Result<JWT, Error>) in
            switch res {
            case .success(let accessToken):
                print("Received access token and refresh token.\nAT:\n\(accessToken)")
                pushCreateNewPin = true
            case .failure(let error):
                showLoginAlert = true
                print("Failed.\n\(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
