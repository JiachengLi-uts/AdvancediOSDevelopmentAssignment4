import SwiftUI

/// The app's top-level areas: the bike and its pre-ride check, rides, and appearance.
struct RootTabView: View {
    let store: RideReadyStoring
    let scheduler: NotificationScheduling
    @ObservedObject var router: AppRouter
    @ObservedObject var appearance: AppearanceSettings

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("Bike", systemImage: "motorcycle", value: AppTab.bike) {
                BikeView(store: store)
            }
            Tab("Ride", systemImage: "road.lanes", value: AppTab.ride) {
                RideView(store: store, scheduler: scheduler, router: router)
            }
            Tab("Appearance", systemImage: "circle.lefthalf.filled", value: AppTab.appearance) {
                AppearanceView(settings: appearance)
            }
        }
        .preferredColorScheme(appearance.mode.colorScheme)
    }
}
