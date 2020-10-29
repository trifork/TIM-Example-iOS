import Foundation
import Combine
import TIM
import TIMEncryptedStorage
import SwiftUI

extension BiometricLoginSettingView {
    final class ViewModel: ObservableObject {
        private var futureStore: Set<AnyCancellable> = []

        @Binding var userId: String
        @Published var password: String?

        let didFinishBiometricHandling: (Bool) -> Void

        init(userId: Binding<String>, password: String?, didFinishBiometricHandling: @escaping (Bool) -> Void) {
            self._userId = userId
            self.password = password
            self.didFinishBiometricHandling = didFinishBiometricHandling
        }

        func enableBioForRefreshToken(password: String) {
            TIM.storage.enableBiometricAccessForRefreshToken(password: password, userId: userId)
                .sink(
                    receiveCompletion: handleEnableBiometricResult,
                    receiveValue: { _ in }
                )
                .store(in: &futureStore)
        }

        func enableBioForRefreshToken() {
            guard let password = password else {
                return
            }
            enableBioForRefreshToken(password: password)
        }

        private func handleEnableBiometricResult(_ result: Subscribers.Completion<TIMEncryptedStorageError>) {
            switch result {
            case .finished:
                print("Successfully enabled biometric login for user.")
                DispatchQueue.main.async {
                    self.didFinishBiometricHandling(true)
                }
            case .failure(let error):
                print("Whoops, something went wrong: \(error.localizedDescription)")
            }
        }
    }
}
