import SwiftUI

@main
struct beRadioApp: App {
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppAudioController.self) var appDelegate
    
    init() {
        configureAudioSession()
//        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: Color.blue]
//        navBarAppearance.titleTextAttributes = [.foregroundColor: Color.blue]
//
//        UINavigationBar.appearance().standardAppearance = navBarAppearance
//        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
//
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .background(RemoteControlReceiver())
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                // Add your commands here, if needed
            }
        }
    }
}
