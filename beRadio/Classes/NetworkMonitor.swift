import Network

class NetworkMonitor {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global(qos: .background)

    init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            switch true {
                case path.status == .satisfied:
                    print("Network connection is available")
                    guard gAudioPlayer != nil else { return }
//                    gAudioPlayer?.handleNetworkIsAvailabel()
//                    gAudioPlayer?.handleAudioRouteChange()
                    if path.usesInterfaceType(.wifi) {
                        print("Connected via WiFi")
                    } else {
                        print("Connected via Cellular")
                    }
                case path.status == .unsatisfied:
                    print("No network connection")
                default:
                    break
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
