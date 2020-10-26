//
//  CreateNewPinCodeView.swift
//  TIM-Example-iOS
//
//  Created by Thomas Kalhøj Clemensen on 26/10/2020.
//

import SwiftUI
import TIM

struct CreateNewPinCodeView: View {
    @State var presentLogin: Bool = false
    @State var pinCode: String = ""
    @State var userId: String?

    var body: some View {
        VStack {
            Text("Type in a new PIN for your refresh token.")
            SecureField("New PIN", text: $pinCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding()
            NavigationLink(
                destination: BiometricLoginSettingView(userId: userId ?? "", password: pinCode),
                isActive: $presentLogin,
                label: {
                    Button("Save") {
                        guard let rt = TIM.auth.refreshToken else {
                            return
                        }
                        userId = rt.userId
                        TIM.storage.storeRefreshToken(rt, withNewPassword: pinCode) { (result) in
                            switch result {
                            case .success(let keyId):
                                print("Saved refresh token for keyId: \(keyId)")
                                DispatchQueue.main.async {
                                    presentLogin = userId?.isEmpty == false
                                }
                            case .failure(let error):
                                print("Failed to store refresh token: \(error.localizedDescription)")
                            }
                        }
                    }
                })
                .opacity(pinCode.isEmpty ? 0 : 1)
                .padding()
        }
        .padding()
        .navigationTitle(TIM.auth.refreshToken?.userId ?? "N/A")
    }
}

struct CreateNewPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPinCodeView()
    }
}
