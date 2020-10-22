import UIKit
import TriforkIdentityManager_Swift
import os.log

enum TIMAuthError: Error {
    case failedToAuthenticate
}

enum TIMStorageError: Error {
    case noValidRefreshTokenAvailable
    case failedToStoreRefreshToken
    case failedToStorePassword
}

enum TIMLoginError: Error {
    case failedToGetKeyId
    case failedToGetAccessToken
    case biometricLoginFailed
}

typealias AccessTokenCallback = (Result<JWT, Error>) -> Void
typealias StatusCallback = (Result<Void, Error>) -> Void

final class TIMHelper {
    static func performOpenIDConnectLogin(presentingViewController: UIViewController, completion: @escaping AccessTokenCallback) {
        AppAuthController.shared.login(
            presentingViewController: presentingViewController,
            completion: { (accessToken: String?, error: Error?) in

                if let at = accessToken {
                    completion(.success(at))
                } else {
                    completion(.failure(TIMAuthError.failedToAuthenticate))
                }
            })
    }

    static func storeRefreshTokenWithPassword(_ password: String, completion: @escaping StatusCallback) {
        guard let refreshToken: JWT = AppAuthController.shared.refreshToken(),
              let expireDate = refreshToken.expireTimestamp
        else {
            completion(.failure(TIMStorageError.noValidRefreshTokenAvailable))
            os_log("No refresh token was available. Do another fresh login.")
            return
        }

        TIMKeyServer.shared.createKey(password: password) { (model: CreateKeyModel) in
            if TIMStorage.shared.storeRefreshTokenAndKeyId(
                refreshToken: refreshToken,
                expireTime: expireDate,
                keyModel: model
            ) {
                os_log("Sucessfully stored refresh token.")
                completion(.success(()))
            } else {
                os_log("Failed to store refresh token.")
                completion(.failure(TIMStorageError.failedToStoreRefreshToken))
            }
        } onError: { (error: KeyServerError) in
            os_log("Key server error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    static func storePasswordWithBiometricId(_ password: String, completion: StatusCallback) {
        if TIMStorage.shared.storePasswordViaBiometric(password: password) {
            os_log("Successfully stored password via Biometric ID.")
            completion(.success(()))
        } else {
            os_log("Failed to store password via Biometric ID.")
            completion(.failure(TIMStorageError.failedToStorePassword))
        }
    }

    static func removePasswordStoredViaBiometric() {
        TIMStorage.shared.removePasswordStoredViaBiometric()
    }

    static func loginWithPassword(_ password: String, completion: @escaping AccessTokenCallback) {
        guard let keyIdData = TIMStorage.shared.retrieveKeyId() else {
            completion(.failure(TIMLoginError.failedToGetKeyId))
            return
        }
        let keyId = String(decoding: keyIdData, as: UTF8.self)
        TIMKeyServer.shared.getKey(password: password, keyId: keyId) { (keyModel: KeyModel) in
            guard let refreshTokenData = TIMStorage.shared.retrieveRefreshToken(keyModel: keyModel) else {
                completion(.failure(TIMStorageError.noValidRefreshTokenAvailable))
                return
            }
            let refreshToken = String(decoding: refreshTokenData, as: UTF8.self)
            AppAuthController.shared.silentLogin(refreshToken: refreshToken) { (accessToken: JWT?, error: Error?) in
                if let accessToken = accessToken,
                   let newRefreshToken = AppAuthController.shared.refreshToken(),
                   let expireDate = accessToken.expireTimestamp
                {
                    os_log("Did get access token: \(accessToken)")
                    let didStore = TIMStorage.shared.storeRefreshTokenAndKeyId(
                        refreshToken: newRefreshToken,
                        expireTime: expireDate,
                        keyModel: keyModel
                    )
                    if didStore {
                        completion(.success(accessToken))
                    } else {
                        os_log("Failed to store refresh token after silent login.")
                        completion(.failure(TIMStorageError.failedToStoreRefreshToken))
                    }
                } else {
                    os_log("Failed to get access token via silent login.")
                    completion(.failure(TIMLoginError.failedToGetAccessToken))
                }
            }
        } onError: { (error: KeyServerError) in
            os_log("Key server error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    static func loginWithBiometricId(completion: @escaping AccessTokenCallback) {
        guard let passwordData = TIMStorage.shared.retrievePasswordViaBiometric() else {
            os_log("Failed to load password via Biometric ID.")
            completion(.failure(TIMLoginError.biometricLoginFailed))
            return
        }
        let password = String(decoding: passwordData, as: UTF8.self)
        loginWithPassword(password, completion: completion)
    }
}
