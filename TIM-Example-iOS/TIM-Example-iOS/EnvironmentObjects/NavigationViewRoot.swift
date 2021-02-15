import Foundation

final class NavigationViewRoot: ObservableObject {
    @Published var popToRoot: Bool = false

    static let shared = NavigationViewRoot()

    private init() { }
}
