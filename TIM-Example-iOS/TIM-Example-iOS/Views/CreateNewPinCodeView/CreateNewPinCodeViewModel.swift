import Foundation
import Combine
import TIM

extension CreateNewPinCodeView {
    final class ViewModel: ObservableObject {

        private var futureStore: Set<AnyCancellable> = []

        @Published var presentLogin: Bool = false
        @Published var pinCode: String = ""
        @Published var name: String = ""
        @Published var userId: String?
        @Published var isDone: Bool = false

        func update() {
            self.userId = TIM.auth.refreshToken?.userId

            // Pre-fill user name field, if the user already has logged in before.
            if let userId = self.userId {
                self.name = UserSettings.name(userId: userId)  ?? ""
            }
        }

        func storeRefreshToken(refreshToken: JWT) {
            guard let userId = userId, !name.isEmpty else {
                return
            }
            UserSettings.save(name: name, for: userId)
            
            TIM.storage.storeRefreshToken(refreshToken, withNewPassword: pinCode)
                .sink { (completion) in
                    switch completion {
                    case .failure(let error):
                        print("Failed to store refresh token: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                } receiveValue: { (creationResult) in
                    print("Saved refresh token for keyId: \(creationResult.keyId)")
                    self.presentLogin = self.userId?.isEmpty == false
                }
                .store(in: &futureStore)
        }
    }

}
