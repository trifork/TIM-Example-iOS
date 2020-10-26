import SwiftUI
import TIM
import os.log
import LocalAuthentication

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
                .disabled(!deviceSupportsBiometricID())
            Button("Save data") {
                statusText = ""
//                TIM.storage.storeRefreshTokenWithPassword(password) { (res: Result<Void, Error>) in
//                    switch res {
//                    case .success:
//                        statusText += "\nStored refresh token."
//                    case .failure(let error):
//                        statusText += "\nFailed to store refresh token: \(error.localizedDescription)"
//                    }
//                }

                if shouldSaveWithBiometric {
//                    TIM.storage.storePasswordWithBiometricId(password) { (res: Result<Void, Error>) in
//                        switch res {
//                        case .success:
//                            statusText += "\nStored refresh token."
//                        case .failure(let error):
//                            statusText += "\nFailed to store refresh token: \(error.localizedDescription)"
//                        }
//                    }
                } else {
//                    TIM.storage.removePasswordStoredViaBiometric()
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

    func deviceSupportsBiometricID() -> Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
    }
}
