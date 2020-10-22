import Foundation

struct OpenIDCredentials {
    let issuer: URL
    let clientId: String
    let redirectUri: URL
    let scopes: [String]
}
