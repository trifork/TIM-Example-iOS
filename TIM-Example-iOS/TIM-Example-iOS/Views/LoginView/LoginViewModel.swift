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
        @Published var keyServiceFailed: Bool = false
        @Published var invalidUserState: Bool = false
        @Published var clientTimeIsOff: Bool = false
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
            TIM.auth.loginWithBiometricId(
                userId: userId,
                storeNewRefreshToken: true,
                willBeginNetworkRequests: { [weak self] in
                    self?.isLoading = true
                })
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

                    switch storageError {
                    case TIMStorageError.incompleteUserDataSet:
                        invalidUserState = true
                    case TIMStorageError.encryptedStorageFailed:
                        wrongPin = storageError.isWrongPassword() || storageError.isBiometricFailedError()
                        keyInvalidated = storageError.isKeyLocked()
                        if !wrongPin && !keyInvalidated {
                            keyServiceFailed = storageError.isKeyServiceError()
                        }
                    }
                case .auth(let authError):
                    switch authError {
                    case .refreshTokenExpired:
                        sessionExpired = true
                    case .failedToValidateIDToken:
                        clientTimeIsOff = true
                    default: break // do default error handling.
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
