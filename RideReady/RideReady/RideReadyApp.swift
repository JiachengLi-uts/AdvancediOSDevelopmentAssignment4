import SwiftUI

@main
struct RideReadyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootTabView(
                store: appDelegate.store,
                journal: appDelegate.journal,
                scheduler: appDelegate.scheduler,
                router: appDelegate.router,
                appearance: appDelegate.appearance
            )
        }
    }
}
