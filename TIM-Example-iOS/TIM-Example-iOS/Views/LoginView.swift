import SwiftUI
import TriforkIdentityManager_Swift
import os.log

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
                TIMHelper.loginWithPassword(password) { (res: Result<JWT, Error>) in
                    switch res {
                    case .success(let accessToken):
                        statusText = "Received AT:\n\(accessToken)"
                    case .failure(let error):
                        statusText = "Failed to retrieve AT.\n\(error.localizedDescription)"
                    }
                }
            }
            .disabled(password.isEmpty)
            Text("... or ...").bold()
            Button("Login with TouchID/FaceID") {
                statusText = "..."
                TIMHelper.loginWithBiometricId { (res: Result<JWT, Error>) in
                    switch res {
                    case .success(let accessToken):
                        statusText = "Received AT:\n\(accessToken)"
                    case .failure(let error):
                        statusText = "Failed to retrieve AT.\n\(error.localizedDescription)"
                    }
                }
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
