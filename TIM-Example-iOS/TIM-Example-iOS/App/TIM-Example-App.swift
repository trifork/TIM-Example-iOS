import SwiftUI
import TIM
import TIMEncryptedStorage
import AppAuth

@main
struct TIMExampleiOSApp: App {

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(NavigationViewRoot())
                .onAppear(perform: {
                    let creds = OpenIDCredentials(
                        issuer: URL(string: "https://oidc-test.hosted.trifork.com/auth/realms/dev")!,
                        clientId: "test",
                        redirectUri: URL(string: "test:/")!,
                        scopes: [OIDScopeOpenID, OIDScopeProfile]
                    )
                    let keyServiceUrl = "https://oidc-test.hosted.trifork.com/auth/realms/dev"
                    let keyServiceConfig = TIMKeyServiceConfiguration(
                        realmBaseUrl: keyServiceUrl,
                        version: .v1
                    )
                    TIM.configure(openIDCredentials: creds, keyServiceConfiguration: keyServiceConfig)
                })
                .onOpenURL(perform: { url in
                    TIM.auth.handleRedirect(url: url)
                })
        }

    }
}
