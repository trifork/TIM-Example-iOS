import SwiftUI
import TIM

struct CreateNewPinCodeView: View {
    @EnvironmentObject var navigationViewRoot: NavigationViewRoot
    @ObservedObject var viewModel = CreateNewPinCodeView.ViewModel()

    var body: some View {
            Form {
                Section(header: Text("Name")) {
                    Text("Type in name for user")
                    TextField("Name", text: $viewModel.name)
                        .padding([.top, .bottom])
                }
                Section(header: Text("Create PIN")) {
                    Text("Type in a new PIN (at least 4 numbers)")
                    SecureField("New PIN", text: $viewModel.pinCode)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding([.top, .bottom])
                }
                Section {
                    Button("Save") {
                        guard let rt = TIM.auth.refreshToken, let userId = rt.userId else {
                            return
                        }
                        self.viewModel.userId = userId
                        viewModel.storeRefreshToken(refreshToken: rt)
                    }
                    .disabled(viewModel.userId != nil && (viewModel.pinCode.count < 4 || viewModel.name.isEmpty))
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
            .sheet(isPresented: $viewModel.presentLogin, content: {
                BiometricLoginSettingView(
                    userId: Binding(
                        get: { $viewModel.userId.wrappedValue ?? "<missing userId>" },
                        set: { v in $viewModel.userId.wrappedValue = v}
                    ),
                    password: viewModel.pinCode,
                    didFinishBiometricHandling: { _ in
                        self.viewModel.presentLogin = false
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
