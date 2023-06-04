import SwiftUI

class RadioStationData: ObservableObject {
    @Published var radioStations: [RadioStation] = []
    @Published var searchQuery = ""
    @Published var selectedStation: RadioStation?
    @Published var showingActionSheet = false
}
