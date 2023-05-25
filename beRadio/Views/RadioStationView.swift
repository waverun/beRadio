import SwiftUI

struct RadioStationsView: View {
    @State private var searchQuery: String = ""
    @State private var radioStations: [RadioStation] = []
//    @State private var searchStarted = false
//    @State private var searchEnded = false
    @State private var showNoStationFound = false
    @State private var country = ""
    @State private var state = ""
    private var localStations = false

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(localStations: Bool = false, onDone: @escaping (RadioStation) -> Void) {
//        if localStations {
//            _ = LocationManager()
//            print("locationMananger: \(LocationManager.shared.currentCountry) \(LocationManager.shared.currentState)")
//        }
        self.onDone = onDone
        self.localStations = localStations
    }

    var body: some View {
        VStack {
            TextField("Search", text: $searchQuery, onCommit: {
//                searchStarted = true
                if localStations {
//                    _ = LocationManager()
                }
                fetchRadioStations(searchQuery: searchQuery) { stations in
                    radioStations = stations
//                    searchEnded = true
                    showNoStationFound = false
                    if stations.count == 0 {
                        showNoStationFound = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showNoStationFound = false
                        }
                    }
                }
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if showNoStationFound {
                Text("No station found")
            }
            List(radioStations) { station in
                Button(action: {
                    onDone(station)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        if let urlString = station.favicon {
                            AsyncImage(url: urlString)
                                .frame(width: 60, height: 60) // Adjust the size as needed
                        }
                        VStack(alignment: .leading) {
                            Text(station.name)
                                .font(.headline)
                            Text(station.country ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

