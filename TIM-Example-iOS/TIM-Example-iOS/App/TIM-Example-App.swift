import SwiftUI
import TIM
import AppAuth

@main
struct TIMExampleiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    let creds = OpenIDCredentials(
                        issuer: URL(string: "https://oidc-test.hosted.trifork.com/auth/realms/dev")!,
                        clientId: "test",
                        redirectUri: URL(string: "test:/")!,
                        scopes: [OIDScopeOpenID, OIDScopeProfile]
                    )
                    let keyServerAddress = "https://oidc-test.hosted.trifork.com/auth/realms/dev/keyservice/v1/"
                    TIM.configure(openIDCredentials: creds, keyServerAddress: keyServerAddress)
                })
                .onOpenURL(perform: { url in
                    TIM.auth.handleRedirect(url: url)
                })
        }
    }
}
