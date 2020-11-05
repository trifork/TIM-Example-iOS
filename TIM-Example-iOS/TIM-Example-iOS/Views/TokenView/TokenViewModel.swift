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
        @Published var tokenExpireText: String?

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
                    if let expireTimestamp = token.expireTimestamp {
                        let date = Date(timeIntervalSince1970: expireTimestamp)
                        let df = DateFormatter()
                        df.dateStyle = .medium
                        df.timeStyle = .medium
                        self.tokenExpireText = df.string(from: date)
                    }
                }
                .store(in: &futureStore)
        }
    }
}
