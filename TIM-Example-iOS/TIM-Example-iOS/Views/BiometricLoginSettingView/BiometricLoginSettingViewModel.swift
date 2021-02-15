import Foundation
import Combine
import TIM
import TIMEncryptedStorage
import SwiftUI

extension BiometricLoginSettingView {
    final class ViewModel: ObservableObject {
        private var futureStore: Set<AnyCancellable> = []

        let userId: String
        @Published var password: String?
        @Binding var didFinishBiometricSetting: Bool
        @Published var shouldDismiss: Bool = false

        init(userId: String, password: String?, didFinishBiometricSetting: Binding<Bool>) {
            self.userId = userId
            self.password = password
            self._didFinishBiometricSetting = didFinishBiometricSetting
        }

        func enableBioForRefreshToken(password: String) {
            TIM.storage.enableBiometricAccessForRefreshToken(password: password, userId: userId)
                .receive(on: DispatchQueue.main)
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

        func dismissView() {
            didFinishBiometricSetting = true
            shouldDismiss = true
        }

        private func handleEnableBiometricResult(_ result: Subscribers.Completion<TIMError>) {
            switch result {
            case .finished:
                print("Successfully enabled biometric login for user.")
                dismissView()
            case .failure(let error):
                print("Whoops, something went wrong: \(error.localizedDescription)")
            }
        }
    }
}
