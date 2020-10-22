//
//  FreshLoginView.swift
//  TriforkIdentityManager-Swift-Example
//
//  Created by Thomas Kalhøj Clemensen on 20/10/2020.
//

import SwiftUI

struct FreshLoginView: View {
    @State private var statusText: String?

    private var topViewController: UIViewController {
        UIApplication.shared.windows.first!.rootViewController!
    }

    var body: some View {
        VStack(spacing: 30) {
            Button("Tap to begin login") {
                statusText = "..."
                TIMHelper.performOpenIDConnectLogin(presentingViewController: topViewController) { (res: Result<JWT, Error>) in
                    switch res {
                    case .success(let accessToken):
                        statusText = "Received access token and refresh token.\nAT:\n\(accessToken)"
                    case .failure(let error):
                        statusText = "Failed.\n\(error.localizedDescription)"
                    }
                }
            }
            ScrollView {
                Text("Status:").bold()
                Text(statusText ?? "-")
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .navigationBarTitle("Fresh login")
    }
}

struct FreshLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FreshLoginView()
    }
}
