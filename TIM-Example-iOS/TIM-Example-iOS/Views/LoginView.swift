import SwiftUI
import TIM
import os.log

struct LoginView: View {
    let userId: String

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
//                TIM.auth.loginWithPassword(password, storeNewRefreshToken: true) { (res: Result<JWT, Error>) in
//                    switch res {
//                    case .success(let accessToken):
//                        statusText = "Received AT:\n\(accessToken)"
//                    case .failure(let error):
//                        statusText = "Failed to retrieve AT.\n\(error.localizedDescription)"
//                    }
//                }
            }
            .disabled(password.isEmpty)
            Text("... or ...").bold()
            Button("Login with TouchID/FaceID") {
                statusText = "..."
//                TIM.auth.loginWithBiometricId { (res: Result<JWT, Error>) in
//                    switch res {
//                    case .success(let accessToken):
//                        statusText = "Received AT:\n\(accessToken)"
//                    case .failure(let error):
//                        statusText = "Failed to retrieve AT.\n\(error.localizedDescription)"
//                    }
//                }
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
//            hasStoredPasswordWithBioID = TIM.storage.hasStoredPassword
        })
        .navigationBarTitle("Login")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userId: "userId")
    }
}
