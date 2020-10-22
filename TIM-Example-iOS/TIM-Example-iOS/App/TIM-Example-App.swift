import SwiftUI
import AppAuth
import TriforkIdentityManager_Swift

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
                    AppAuthController.shared.configure(creds)

                    let keyServerAddress = "https://oidc-test.hosted.trifork.com/auth/realms/dev/keyservice/v1/"
                    TIMKeyServer.shared.configure(serverAddress: keyServerAddress)
                })
                .onOpenURL(perform: { url in
                    AppAuthController.shared.handleRedirect(url: url)
                })
        }
    }
}
