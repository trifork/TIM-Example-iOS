import Foundation
import LocalAuthentication
import TIM
import Combine

extension LoginView {

    final class ViewModel: ObservableObject {
        private var futureStore: Set<AnyCancellable> = []

        let userId: String

        @Published var hasStoredPasswordWithBioID: Bool = false
        @Published var showAuthenticatedView: Bool = false
        @Published var error: Error?
        @Published var isLoading: Bool = false

        init(userId: String) {
            self.userId = userId
        }

        func login(password: String) {
            isLoading = true
            TIM.auth.loginWithPassword(userId: userId, password: password, storeNewRefreshToken: true)
                .sink(
                    receiveCompletion: handleResultCompletion,
                    receiveValue: { _ in
                        self.showAuthenticatedView = true
                    })
                .store(in: &futureStore)

        }

        func loginWithBio() {
            isLoading = true
            TIM.auth.loginWithBiometricId(userId: userId, storeNewRefreshToken: true)
                .sink(
                    receiveCompletion: handleResultCompletion,
                    receiveValue: { _ in
                        self.showAuthenticatedView = true
                    })
                .store(in: &futureStore)
        }

        private func handleResultCompletion(_ completion: Subscribers.Completion<Error>) {
            switch completion {
            case .failure(let error):
                self.error = error
                isLoading = false
                print("Failed to login: \(error.localizedDescription)")
            case .finished:
                self.error = nil
                isLoading = false
            }
        }

        var hasBioLoginActivated: Bool {
            LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && TIM.storage.hasBiometricAccessForRefreshToken(userId: userId)
        }

        var biometricIdName: String {
            LAContext().biometryType.biometricIdName
        }

    }
}
