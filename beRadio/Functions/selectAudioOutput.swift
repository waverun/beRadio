import AVFoundation
import AVKit

func selectAudioOutput() {
    let audioSession = AVAudioSession.sharedInstance()

    do {
        try audioSession.setCategory(.playback, mode: .default, options: [])
        try audioSession.setActive(true, options: [])
    } catch {
        print("Failed to set up audio session: \(error)")
    }

    let routePickerView = AVRoutePickerView()
    routePickerView.activeTintColor = .blue
    routePickerView.tintColor = .blue

    if let routeButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
        routeButton.sendActions(for: .touchUpInside)
    }
}
