//
//  CreateNewPinCodeView.swift
//  TIM-Example-iOS
//
//  Created by Thomas Kalhøj Clemensen on 26/10/2020.
//

import SwiftUI
import TIM

struct CreateNewPinCodeView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot

    @State var presentLogin: Bool = false
    @State var pinCode: String = ""
    @State var name: String = ""
    @State var userId: String?

    var body: some View {
            Form {
                Section(header: Text("Name")) {
                    Text("Type in name for user")
                    TextField("Name", text: $name)
                        .padding([.top, .bottom])
                }
                Section(header: Text("Create PIN")) {
                    Text("Type in a new PIN (at least 4 numbers)")
                    SecureField("New PIN", text: $pinCode)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding([.top, .bottom])
                }
                Section {
                    Button("Save") {
                        guard let rt = TIM.auth.refreshToken, let userId = rt.userId else {
                            return
                        }
                        self.userId = userId
                        UserSettings.save(name: name, for: userId)
                        TIM.storage.storeRefreshToken(rt, withNewPassword: pinCode) { (result) in
                            switch result {
                            case .success(let keyId):
                                print("Saved refresh token for keyId: \(keyId)")
                                DispatchQueue.main.async {
                                    presentLogin = !userId.isEmpty
                                }
                            case .failure(let error):
                                print("Failed to store refresh token: \(error.localizedDescription)")
                            }
                        }
                    }
                    .disabled(pinCode.count < 4 || name.isEmpty)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
            .sheet(isPresented: $presentLogin, content: {
                BiometricLoginSettingView(
                    userId: Binding(
                        get: { $userId.wrappedValue ?? "<missing userId>" },
                        set: { v in $userId.wrappedValue = v}
                    ),
                    password: pinCode,
                    didFinishBiometricHandling: { _ in
                        self.presentLogin = false
                        self.navigationViewRoot.popToRoot = true
                    }
                )
            })
        .navigationTitle("New user")
    }
}

struct CreateNewPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPinCodeView()
    }
}
