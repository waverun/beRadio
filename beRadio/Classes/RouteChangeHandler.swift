import SwiftUI
import AVFoundation
import Combine

class RouteChangeHandler: ObservableObject {
    var routeChangeCancellable: AnyCancellable?

    init() {
        routeChangeCancellable = NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink(receiveValue: { [weak self] notification in
                self?.handleRouteChange(notification: notification)
            })
    }

    func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .newDeviceAvailable: break
            // Handle new device availability
        case .oldDeviceUnavailable: break
            // Handle old device unavailability
        default:
            break
        }
    }
}
