import SwiftUI
import TIM
import TIMEncryptedStorage
import AppAuth

@main
struct TIMExampleiOSApp: App {

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(NavigationViewRoot.shared)
                .onAppear(perform: {
                    let config = TIMConfiguration(
                        oidc: TIMOpenIDConfiguration(
                            issuer: URL(string: "https://oidc-test.hosted.trifork.com/auth/realms/dev")!,
                            clientId: "test",
                            redirectUri: URL(string: "test:/")!,
                            scopes: [OIDScopeOpenID, OIDScopeProfile]
                        ),
                        keyService: TIMKeyServiceConfiguration(
                            realmBaseUrl: "https://oidc-test.hosted.trifork.com/auth/realms/dev",
                            version: .v1
                        ),
                        encryptionMethod: .aesGcm
                    )
                    TIM.configure(configuration: config)
                })
                .onOpenURL(perform: { url in
                    TIM.auth.handleRedirect(url: url)
                })
        }

    }
}
