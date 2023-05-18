import SwiftUI

@main
struct beRadioApp: App {
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppAudioController.self) var appDelegate
    
    init() {
        configureAudioSession()
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
