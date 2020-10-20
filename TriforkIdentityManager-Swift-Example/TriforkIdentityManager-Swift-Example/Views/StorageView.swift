import SwiftUI
import TriforkIdentityManager_Swift
import os.log

struct StorageView: View {
    @State private var password: String = ""
    @State private var statusText: String = "-"
    @State private var shouldSaveWithBiometric: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Password:")
                TextField("Enter password here", text: $password)
            }
            Toggle("Store with TouchID/FaceID", isOn: $shouldSaveWithBiometric)
            Button("Save data") {
                statusText = "..."
                storeRefreshTokenWithPassword(password)

                if shouldSaveWithBiometric {
                    storePasswordWithBiometricId(password)
                } else {
                    TIMStorage.shared.removePasswordStoredViaBiometric()
                }
            }
            .disabled(password.isEmpty)
            Text("Status:").bold()
            Text(statusText)
            Spacer()
        }
        .padding()
        .navigationTitle("Storage")
    }

    func storeRefreshTokenWithPassword(_ password: String) {
        guard let refreshToken = AppAuthController.shared.refreshToken(),
              let expireDate = JWTDecoder.decode(jwtToken: refreshToken)["exp"] as? TimeInterval
        else {
            self.statusText += "No valid refresh token is available!"
            os_log("No refresh token was available. Do another fresh login.")
            return
        }

        TIMKeyServer.shared.createKey(password: password) { (model: CreateKeyModel) in
            if TIMStorage.shared.storeRefreshTokenAndKeyId(
                refreshToken: refreshToken,
                expireTime: expireDate,
                keyModel: model
            ) {
                statusText += "Refresh token was saved."
                os_log("Sucessfully stored refresh token.")
            } else {
                statusText += "Failed to store token."
                os_log("Failed to store refresh token.")
            }
        } onError: { (error: KeyServerError) in
            statusText += "ERROR: \(error.localizedDescription)"
        }
    }

    func storePasswordWithBiometricId(_ password: String) {
        if TIMStorage.shared.storePasswordViaBiometric(password: password) {
            statusText += "\nSuccessfully stored password with bio ID."
            os_log("Successfully stored password via Biometric ID.")
        } else {
            statusText += "\nFaild to store password with bio ID."
            os_log("Failed to store password via Biometric ID.")
        }
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
    }
}
