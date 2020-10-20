import SwiftUI
import TriforkIdentityManager_Swift

struct LoginView: View {
    @State private var hasStoredPasswordWithBioID: Bool = false
    @State private var password: String = ""
    @State private var statusText: String = "-"
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Password:")
                TextField("Enter password here", text: $password)
            }
            Button("Login with password") {
                statusText = "..."
                loginWithPassword(password)
            }
            .disabled(password.isEmpty)
            Text("... or ...").bold()
            Button("Login with TouchID/FaceID") {
                statusText = "..."
                loginWithBiometricId()
            }
            .disabled(!hasStoredPasswordWithBioID)
            ScrollView {
                Text("Status:").bold()
                Text(statusText)
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: {
            hasStoredPasswordWithBioID = TIMStorage.shared.havePasswordStored()
        })
        .navigationBarTitle("Login")
    }

    func loginWithPassword(_ password: String) {
        guard let keyIdData = TIMStorage.shared.retrieveKeyId() else {
            statusText = "Failed to get key ID from storage."
            return
        }
        let keyId = String(decoding: keyIdData, as: UTF8.self)
        TIMKeyServer.shared.getKey(password: password, keyId: keyId) { (keyModel: KeyModel) in
            guard let refreshTokenData = TIMStorage.shared.retrieveRefreshToken(keyModel: keyModel) else {
                statusText = "Failed to load refresh token."
                return
            }
            let refreshToken = String(decoding: refreshTokenData, as: UTF8.self)
            AppAuthController.shared.silentLogin(refreshToken: refreshToken) { (accessToken: String?, error: Error?) in
                if let accessToken = accessToken,
                   let newRefreshToken = AppAuthController.shared.refreshToken(),
                   let expireDate = (JWTDecoder.decode(jwtToken: newRefreshToken)["exp"] as? TimeInterval)
                {
                    statusText = "Received access token!\n\n\(accessToken)"
                    let didStore = TIMStorage.shared.storeRefreshTokenAndKeyId(
                        refreshToken: newRefreshToken,
                        expireTime: expireDate,
                        keyModel: keyModel
                    )
                    if didStore {
                        statusText += "\nDid store new refresh token."
                    } else {
                        statusText += "\nFailed to store new refresh token."
                    }
                } else {
                    statusText = "Failed to get access token: \(error?.localizedDescription ?? "No error")"
                }
            }
        } onError: { (error: KeyServerError) in
            statusText = "Failed to get key from key server: \(error.localizedDescription)"
        }
    }

    func loginWithBiometricId() {
        guard let passwordData = TIMStorage.shared.retrievePasswordViaBiometric() else {
            statusText = "Failed to get password from storage."
            return
        }
        let password = String(decoding: passwordData, as: UTF8.self)
        loginWithPassword(password)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
