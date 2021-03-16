import SwiftUI
import TIM
import Combine

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
    @ObservedObject var viewModel: TokenView.ViewModel

    var body: some View {
        Form {
            if let error = viewModel.error {
                Text("An error occurred:\n\(error.localizedDescription)")
                    .bold()
                    .foregroundColor(.red)
            } else if let token = viewModel.token {
                Section(header: Text("Export")) {
                    Button("Print to console") {
                        print("------BEGIN \(viewModel.tokenType.title) BEGIN------")
                        print(token)
                        print("------END \(viewModel.tokenType.title) END------")
                    }
                    Button("Copy to clipboard") {
                        if let token = viewModel.token {
                            UIPasteboard.general.string = token.token
                        }
                    }
                }
                Section(header: Text("Expiration")) {
                    Text("\(viewModel.tokenExpireText ?? "N/A")")
                }
                Section(header: Text("Token")) {
                    Text(viewModel.token?.token ?? "N/A")
                }
            } else {
                Text("Loading ...")
            }
        }
        .onAppear(perform: {
            viewModel.loadToken()
        })
        .navigationTitle(viewModel.tokenType.title)
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView(viewModel: TokenView.ViewModel(tokenType: .accessToken))
    }
}
