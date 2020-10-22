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

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                NavigationLink("🆕 Fresh OIDC login", destination: FreshLoginView())
                NavigationLink("📦 Store tokens", destination: StorageView())
                    .disabled(!hasRefreshToken)
                NavigationLink("🔑 Login", destination: LoginView())
                    .disabled(!hasStoredRefreshToken)
                Button("🗑 Reset everything") {
                    TIM.storage.clear()
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
        hasRefreshToken = TIM.auth.refreshToken != nil
        hasStoredRefreshToken = TIM.storage.hasStoredRefreshToken
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
