import SwiftUI
import AVFoundation
import MediaPlayer

class AppAudioController: UIResponder, UIApplicationDelegate {
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }

        switch event.subtype {
        case .remoteControlPlay:
            // Handle play event
            print("Play button pressed")
            // Call your app's play functionality here

        case .remoteControlPause:
            // Handle pause event
            print("Pause button pressed")
            // Call your app's pause functionality here

        case .remoteControlNextTrack:
            // Handle next track event
            print("Next track button pressed")
            // Call your app's next track functionality here

        case .remoteControlPreviousTrack:
            // Handle previous track event
            print("Previous track button pressed")
            // Call your app's previous track functionality here

        case .remoteControlTogglePlayPause:
            // Handle toggle play/pause event
            print("Toggle play/pause button pressed")
            // Call your app's play/pause toggle functionality here

        case .remoteControlStop:
            // Handle stop event
            print("Stop button pressed")
            // Call your app's stop functionality here

        case .remoteControlBeginSeekingBackward:
            // Handle begin seeking backward event
            print("Begin seeking backward")
            // Call your app's begin seeking backward functionality here

        case .remoteControlEndSeekingBackward:
            // Handle end seeking backward event
            print("End seeking backward")
            // Call your app's end seeking backward functionality here

        case .remoteControlBeginSeekingForward:
            // Handle begin seeking forward event
            print("Begin seeking forward")
            // Call your app's begin seeking forward functionality here

        case .remoteControlEndSeekingForward:
            // Handle end seeking forward event
            print("End seeking forward")
            // Call your app's end seeking forward functionality here

        default:
            break
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Start receiving remote control events
        application.beginReceivingRemoteControlEvents()
        return true
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        // Handle remote control events
//    }
}

struct RemoteControlReceiver: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        CustomUIHostingController(rootView: AnyView(EmptyView()))
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class CustomUIHostingController: UIHostingController<AnyView> {
        override func viewDidLoad() {
            super.viewDidLoad()
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
        }

        override var canBecomeFirstResponder: Bool {
            return true
        }
    }
}
