import SwiftUI

struct RadioStationsView: View {
    @State private var searchQuery: String = ""
    @State private var radioStations: [RadioStation] = []
    @State private var showNoStationFound = false
    @State private var country = ""
    @State private var state = ""
    private var localStations = false

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(localStations: Bool = false, onDone: @escaping (RadioStation) -> Void) {
        self.onDone = onDone
        self.localStations = localStations
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.adaptiveBlack, .blue, .purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                TextField("Search Text", text: $searchQuery, onCommit: {
                    if localStations {
                    }
                    fetchRadioStations(searchQuery: searchQuery) { stations in
                        radioStations = stations
                        showNoStationFound = false
                        if stations.count == 0 {
                            showNoStationFound = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showNoStationFound = false
                            }
                        }
                    }
                })
                .padding(5)
                .background(Color.clear)
                .foregroundColor(.purple)
//                .cornerRadius(8)
                .padding(.horizontal)
//                .textFieldStyle(RoundedBorderTextFieldStyle())

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
        .navigationBarTitle("Search for Stations")
        .environment(\.layoutDirection, .leftToRight)
    }
}

