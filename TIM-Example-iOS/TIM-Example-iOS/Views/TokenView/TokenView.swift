import SwiftUI
import TIM

enum TokenType {
    case accessToken
    case refreshToken

    var title: String {
        switch self {
        case .accessToken:
            return "Access Token"
        case .refreshToken:
            return "RefreshToken"
        }
    }
}

struct TokenView: View {
    let tokenType: TokenType
    @State var token: JWT? = nil

    var body: some View {
        Form {
            if let token = token {
                Section {
                    Button("Print to console") {
                        print("------BEGIN \(tokenType.title) BEGIN------")
                        print(token)
                        print("------END \(tokenType.title) END------")
                    }
                    Button("Copy to clipboard") {
                        UIPasteboard.general.string = token
                    }
                }
                Section {
                    Text(token)
                }
            } else {
                Section {
                    Text("Retrieving token ...")
                }
            }
        }
        .onAppear(perform: {
            loadToken()
        })
        .navigationTitle(tokenType.title)
    }

    private func loadToken() {
        switch tokenType {
        case .accessToken:
            TIM.auth.accessToken { (result) in
                switch result {
                case .success(let at):
                    token = at
                case .failure(let error):
                    token = "Failed to load token:\n\(error.localizedDescription)"
                }
            }
        case .refreshToken:
            token = TIM.auth.refreshToken
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView(tokenType: .accessToken)
    }
}
