import Foundation

final class UserSettings {
    static func save(name: String, for userId: String) {
        UserDefaults.standard.set(name, forKey: userId)
    }

    static func name(userId: String) -> String? {
        UserDefaults.standard.string(forKey: userId)
    }

    static func clear(userId: String) {
        UserDefaults.standard.removeObject(forKey: userId)
    }
}
