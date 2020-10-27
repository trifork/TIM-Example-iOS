import SwiftUI

struct LoginWithPinCodeView: View {
    let buttonTitle: String
    let handleLogin: (String) -> Void
    @State private var pinCode: String = ""

    var body: some View {
        SecureField("PIN", text: $pinCode)
            .padding()
            .multilineTextAlignment(.center)
        Button(buttonTitle) {
            handleLogin(pinCode)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .padding()
        .disabled(pinCode.count < 4)
    }
}

struct LoginWithPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithPinCodeView(buttonTitle: "<Button title>", handleLogin: { print($0) })
    }
}
