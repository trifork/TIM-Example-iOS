import Foundation
import TIM
import Combine

extension TokenView {
    final class ViewModel : ObservableObject {

        private var futureStore: Set<AnyCancellable> = []

        let tokenType: TokenType
        @Published var token: JWT?
        @Published var error: Error?
        @Published var isLoading: Bool = false

        init(tokenType: TokenType) {
            self.tokenType = tokenType
        }

        func loadToken() {
            isLoading = true
            TIM.auth.accessToken()
                .sink { (result) in
                    switch result {
                    case .failure(let error):
                        self.token = nil
                        self.error = error
                        self.isLoading = false
                    case .finished:
                        self.isLoading = false
                    }
                } receiveValue: { (token) in
                    self.token = token
                }
                .store(in: &futureStore)
        }
    }
}
