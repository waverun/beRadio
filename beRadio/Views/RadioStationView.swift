import SwiftUI

struct RadioStationsView: View {
    @State private var searchQuery: String = ""
    @State private var radioStations: [RadioStation] = []
    
    @Environment(\.presentationMode) private var presentationMode
    let onDone: (RadioStation) -> Void

    var body: some View {
        VStack {
            TextField("Search", text: $searchQuery, onCommit: {
                fetchRadioStations(searchQuery: searchQuery) { stations in
                    radioStations = stations
                }
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            List(radioStations) { station in
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
                    Button(action: {
                        onDone(station)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}
