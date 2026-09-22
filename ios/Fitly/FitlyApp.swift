import SwiftUI

@main
struct FitlyApp: App {
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(session.appearance.colorScheme)
                .onOpenURL { session.handleDeepLink($0) }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isAuthenticated, session.user?.age != nil {
                MainTabView()
            } else if session.isAuthenticated {
                OnboardingView()
            } else {
                AuthView()
            }
        }
        .task { await session.restore() }
    }
}
