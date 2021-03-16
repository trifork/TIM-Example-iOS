import Foundation
import TIM
import Combine

extension AuthenticatedView {
    final class ViewModel: ObservableObject {

        private var futureStorage = Set<AnyCancellable>()

        let userId: String

        @Published var presentBiometricSetting: Bool = false
        @Published var hasBiometricAccess: Bool = false
        @Published var showTokenExpiredAlert: Bool = false

        private var hasStartedTimers: Bool = false
        private var timer: Timer?

        init(userId: String) {
            self.userId = userId
        }

        func beginExpirationTimer() {
            guard !hasStartedTimers else {
                return
            }

            hasStartedTimers = true
            TIM.auth.accessToken()
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] (at) in
                        guard let expireDate = at.expireDate else {
                            return
                        }
                        let timer = Timer(fire: expireDate, interval: 0, repeats: false) { [weak self] (timer) in
                            self?.showTokenExpiredAlert = true
                            self?.logout()
                            self?.hasStartedTimers = false
                        }
                        self?.timer = timer
                        RunLoop.current.add(timer, forMode: .common)
                    })
                .store(in: &futureStorage)
        }

        func disableExpirationTimer() {
            self.timer?.invalidate()
            self.timer = nil
            self.hasStartedTimers = false
        }

        func updateBioMetricAccessState() {
            hasBiometricAccess = TIM.storage.hasBiometricAccessForRefreshToken(userId: userId)
        }

        func disableBiometricsForUser() {
            TIM.storage.disableBiometricAccessForRefreshToken(userId: userId)
            updateBioMetricAccessState()
        }

        func deleteUser() {
            disableExpirationTimer()
            TIM.auth.logout()
            TIM.storage.clear(userId: userId)
            UserSettings.clear(userId: userId)
        }

        func logout() {
            disableExpirationTimer()
            TIM.auth.logout()
        }
    }
}
