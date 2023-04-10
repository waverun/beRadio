import Foundation
import Combine

class StationListViewModel: ObservableObject {
    @Published var stations: [RadioStation] = []
    private var cancellables: Set<AnyCancellable> = []

    init(stations: [RadioStation]) {
        filterStationsWithValidURLs(stations: stations)
    }

    private func filterStationsWithValidURLs(stations: [RadioStation]) {
        let dispatchGroup = DispatchGroup()

        stations.forEach { station in
            if let urlString = station.favicon {
                dispatchGroup.enter()
                checkIfURLExists(url: urlString) { exists in
                    if exists {
                        DispatchQueue.main.async {
                            self.stations.append(station)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Finished filtering stations.")
        }
    }
}
