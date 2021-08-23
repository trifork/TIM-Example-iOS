import SwiftUI
import TIM
import TIMEncryptedStorage
import AppAuth
import Combine

@main
struct TIMExampleiOSApp: App {

    private static var cancelBag = Set<AnyCancellable>()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(NavigationViewRoot.shared)
                .onAppear(perform: {
                    if !TIM.isConfigured {
                        let config = TIMConfiguration(
                            timBaseUrl: URL(string: "https://oidc-test.hosted.trifork.com")!,
                            realm: "dev",
                            clientId: "test_mock",
                            redirectUri: URL(string: "test:/")!,
                            scopes: [OIDScopeOpenID, OIDScopeProfile],
                            encryptionMethod: .aesGcm
                        )
                        TIM.configure(configuration: config)
                        TIM.auth.enableBackgroundTimeout(durationSeconds: 60)
                            .sink { _ in
                                print("User was logged out because of timeout!")
                                let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
                                keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                            .store(in: &TIMExampleiOSApp.cancelBag)
                    }
                })
                .onOpenURL(perform: { url in
                    TIM.auth.handleRedirect(url: url)
                })
        }
    }
}
