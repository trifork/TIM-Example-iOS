//
//  FreshLoginView.swift
//  TriforkIdentityManager-Swift-Example
//
//  Created by Thomas Kalhøj Clemensen on 20/10/2020.
//

import SwiftUI

struct FreshLoginView: View {
    @State private var statusText: String?

    var body: some View {
        VStack(spacing: 30) {
            Button("Tap to begin login") {
                AppAuthController.shared.login(
                    presentingViewController: UIApplication.shared.windows.first!.rootViewController!) { (accessToken: String?, error: Error?) in

                    if let at = accessToken, let rt = AppAuthController.shared.refreshToken() {
                        statusText = "Received access token and refresh token.\nAT:\n\(at)\n\nRT:\n\(rt)"
                    } else {
                        statusText = "Failed.\n\(error?.localizedDescription ?? "No error")"
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
