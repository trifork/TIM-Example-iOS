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
        @Published var wrongPin: Bool = false
        @Published var keyInvalidated: Bool = false
        @Published var sessionExpired: Bool = false
        @Published var error: TIMError?
        @Published var isLoading: Bool = false

        init(userId: String) {
            self.userId = userId
        }

        func login(password: String) {
            wrongPin = false
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
            wrongPin = false
            isLoading = true
            TIM.auth.loginWithBiometricId(userId: userId, storeNewRefreshToken: true)
                .sink(
                    receiveCompletion: handleResultCompletion,
                    receiveValue: { _ in
                        self.showAuthenticatedView = true
                    })
                .store(in: &futureStore)
        }

        private func handleResultCompletion(_ completion: Subscribers.Completion<TIMError>) {
            switch completion {
            case .failure(let error):
                self.error = error
                isLoading = false
                print("Failed to login: \(error.localizedDescription)")

                switch error {
                case .storage(let storageError):
                    wrongPin = storageError.isWrongPin()
                    keyInvalidated = storageError.isKeyLocked()
                case .auth(let authError):
                    if case TIMAuthError.refreshTokenExpired = authError {
                        sessionExpired = true
                    }
                }
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
