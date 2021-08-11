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
            switch tokenType {
            case .accessToken:
                loadAccessToken()
            case .refreshToken:
                loadRefreshToken()
            }
        }

        private func loadAccessToken() {
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
                    self.setAndFormatExpireDate(date: token.expireDate)
                }
                .store(in: &futureStore)
        }

        private func loadRefreshToken() {
            self.token = TIM.auth.refreshToken
            setAndFormatExpireDate(date: TIM.auth.refreshToken?.expireDate)
        }

        private func setAndFormatExpireDate(date: Date?) {
            if let expireDate = date, (date?.timeIntervalSince1970 ?? 0) > 0 {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .medium
                self.tokenExpireText = df.string(from: expireDate)
            } else {
                self.tokenExpireText = "Unknown (handled server-side)"
            }
        }
    }

}
