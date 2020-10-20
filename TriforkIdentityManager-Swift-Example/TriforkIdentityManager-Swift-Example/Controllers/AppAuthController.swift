import UIKit
import AppAuth
import SafariServices
import os.log

enum AuthControlleError: Error {
    case authStateNil
}

final class AppAuthController {
    static let shared = AppAuthController()

    private var currentAuthorizationFlow: OIDExternalUserAgentSession? = nil

    private var authState: OIDAuthState?

    private var _credentials: OpenIDCredentials?
    private (set) var credentials: OpenIDCredentials {
        get {
            guard let cred = _credentials else {
                fatalError("No credentials were configured for AuthController.")
            }
            return cred
        }
        set {
            _credentials = newValue
        }
    }

    var isLoggedIn: Bool {
        authState != nil
    }

    private init() {

    }

    func configure(_ credentials: OpenIDCredentials) {
        self.credentials = credentials
        verifyUrlScheme()
    }

    private func verifyUrlScheme() {
        guard let urlTypes: [AnyObject] = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject], urlTypes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let items = urlTypes[0] as? [String: AnyObject],
            let urlSchemes = items["CFBundleURLSchemes"] as? [AnyObject], urlSchemes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let urlScheme = urlSchemes[0] as? String else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        assert(urlScheme == credentials.redirectUri.scheme,
                "Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) " +
                "with the scheme of your redirect URI. Full instructions: " +
                "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")
    }

    private func discoverConfiguration(completion: @escaping (OIDServiceConfiguration, Error?) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: credentials.issuer) { [weak self] (config: OIDServiceConfiguration?, error: Error?) in
            guard let configuration = config else {
                os_log("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self?.authState = nil
                return
            }
            completion(configuration, error)
        }
    }

    private func doAuthState(
        request: OIDAuthorizationRequest,
        presentingViewController: UIViewController,
        willPresentSafariViewController: @escaping (SFSafariViewController) -> Void,
        shouldAnimate: @escaping () -> Bool,
        didCancel: @escaping () -> Void,
        callback: @escaping OIDAuthStateAuthorizationCallback) {
        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            externalUserAgent: AuthSFController(
                presentingViewController: presentingViewController,
                willPresentSafariViewControllerCallback: willPresentSafariViewController,
                shouldAnimateCallback: shouldAnimate,
                didCancelCallback: didCancel
            )!,
            callback: callback
        )
    }

    private func createRestoreFakeLastAuthorizationResponse(configuration: OIDServiceConfiguration) -> OIDAuthorizationResponse {
        return OIDAuthorizationResponse(
            request: OIDAuthorizationRequest(
                configuration: configuration,
                clientId: credentials.clientId,
                scopes: credentials.scopes,
                redirectURL: credentials.redirectUri,
                responseType: OIDResponseTypeCode,
                additionalParameters: [:]
            ),
            parameters: [:])
    }

    func login(presentingViewController: UIViewController,
                completion: @escaping (String?, Error?) -> Void,
                didCancel: (() -> Void)? = nil,
                willPresentSafariViewController: ((SFSafariViewController) -> Void)? = nil,
                shouldAnimate: (() -> Bool)? = nil) {
        discoverConfiguration { [weak self] (configuration: OIDServiceConfiguration, error: Error?) in
            guard let `self` = self else {
                return
            }
            let request = OIDAuthorizationRequest(
                configuration: configuration,
                clientId: self.credentials.clientId,
                scopes: self.credentials.scopes,
                redirectURL: self.credentials.redirectUri,
                responseType: OIDResponseTypeCode,
                additionalParameters: [:]
            )
            self.doAuthState(
                request: request,
                presentingViewController: presentingViewController,
                willPresentSafariViewController: willPresentSafariViewController ?? { _ in },
                shouldAnimate: shouldAnimate ?? { true },
                didCancel: didCancel ?? { }) { [weak self] (authState: OIDAuthState?, error: Error?) in
                guard let `self` = self else {
                    return
                }
                self.authState = authState
                self.accessToken(completion)
            }
        }
    }

    func silentLogin(refreshToken: String, completion: @escaping (String?, Error?) -> Void) {
        discoverConfiguration { [weak self] (configuration: OIDServiceConfiguration, error: Error?) in
            guard let `self` = self else {
                return
            }
            let request = OIDTokenRequest(
                configuration: configuration,
                grantType: OIDGrantTypeRefreshToken,
                authorizationCode: nil,
                redirectURL: nil,
                clientID: self.credentials.clientId,
                clientSecret: nil,
                scopes: self.credentials.scopes,
                refreshToken: refreshToken,
                codeVerifier: nil,
                additionalParameters: nil
            )
            OIDAuthorizationService.perform(request) { [weak self] (token: OIDTokenResponse?, error: Error?) in
                guard let `self` = self else {
                    return
                }
                if let token = token, error == nil {
                    let authResponse = self.createRestoreFakeLastAuthorizationResponse(configuration: configuration)
                    self.authState = OIDAuthState(authorizationResponse: authResponse, tokenResponse: token, registrationResponse: nil)
                    completion(token.accessToken, error)
                } else  {
                    completion(nil, error)
                }
            }
        }
    }

    func accessToken(forceRefresh: Bool = false, _ completion: @escaping (String?, Error?) -> Void) {
        guard let authState = self.authState else {
            completion(nil, AuthControlleError.authStateNil)
            return
        }
        if forceRefresh {
            authState.setNeedsTokenRefresh()
        }
        authState.performAction { (accessToken: String?, _, error: Error?) in
            completion(accessToken, error)
        }
    }

    func refreshToken() -> String? {
        authState?.refreshToken
    }

    func logout() {
        authState = nil
    }

    @discardableResult
    func handleRedirect(url: URL) -> Bool {
        let result: Bool
        if currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) == true {
            currentAuthorizationFlow = nil
            result = true
        } else {
            result = false
        }
        return result
    }

}
