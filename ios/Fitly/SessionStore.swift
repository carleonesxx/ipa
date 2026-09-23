import SwiftUI

@MainActor final class SessionStore: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var loading = false
    @Published var error: String?
    @Published var pendingRoute: String?
    @Published var appearance: Appearance = Appearance(rawValue: UserDefaults.standard.string(forKey: "fitly.appearance") ?? "system") ?? .system
    let api = FITLYAPIClient.shared

    func restore() async { guard await api.currentToken() != nil else { return }; do { let response: UserResponse = try await api.request("/me"); user = response.user; isAuthenticated = true } catch { await signOut() } }
    func signIn(email: String, password: String) async { loading = true; defer { loading = false }; do { let r = try await api.login(email: email, password: password); user = r.user; isAuthenticated = true; error = nil } catch { self.error = error.localizedDescription } }
    func signUp(name: String, email: String, password: String) async { loading = true; defer { loading = false }; do { let r = try await api.register(name: name, email: email, password: password); user = r.user; isAuthenticated = true; error = nil } catch { self.error = error.localizedDescription } }
    func signOut() async { await api.logout(); user = nil; isAuthenticated = false }
    func setAppearance(_ value: Appearance) { appearance = value; UserDefaults.standard.set(value.rawValue, forKey: "fitly.appearance") }
    func handleDeepLink(_ url: URL) { guard url.scheme == "fitly" else { return }; pendingRoute = ([url.host].compactMap { $0 } + Array(url.pathComponents.dropFirst())).joined(separator: "/") }
}
