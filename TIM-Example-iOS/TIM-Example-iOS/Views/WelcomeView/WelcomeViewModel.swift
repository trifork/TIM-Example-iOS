import UIKit
import TIM
import Combine

extension WelcomeView {

    final class ViewModel: ObservableObject {
        private var futureStorage: Set<AnyCancellable> = []

        @Published var hasRefreshToken: Bool = false
        @Published var hasStoredRefreshToken: Bool = false
        @Published var availableUserIds: [String] = []
        @Published var showLoginAlert: Bool = false
        @Published var pushCreateNewPin: Bool = false

        init() {
            update()
        }

        func update() {
            availableUserIds = Array(TIM.storage.availableUserIds)
        }

        func clear() {
            availableUserIds.forEach { (id) in
                UserSettings.clear(userId: id)
                TIM.storage.clear(userId: id)
            }
            TIM.auth.logout()
            update()
        }

        func performOIDCLogin(topViewController: UIViewController) {
            TIM.auth.performOpenIDConnectLogin(presentingViewController: topViewController)
                .sink { (completion) in
                    switch completion {
                    case .failure(let error):
                        self.showLoginAlert = true
                        print("Failed.\n\(error.localizedDescription)")
                    case .finished:
                        break
                    }
                } receiveValue: { (accessToken) in
                    print("Received access token and refresh token.\nAT:\n\(accessToken)")
                    self.pushCreateNewPin = true
                }
                .store(in: &futureStorage)
        }
    }
}
