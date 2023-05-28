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
                HStack {
                    TextField("Search Text", text: $searchQuery, onCommit: {
                        if localStations {
                        }
                        searchRadioStations()
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
                    Button(action: {
                        searchRadioStations()
                    }) {
                        Image(systemName: "magnifyingglass") // replace with your custom image name if any
                            .foregroundColor(.purple)
                    }
                    .padding(.trailing)
                }
                ScrollView {
                    GeometryReader { geometry in
                        VStack(alignment: .leading) {
                            ForEach(radioStations, id: \.self) { station in
                                Button(action: {
                                    onDone(station)
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        if let urlString = station.favicon {
                                            AsyncImage(url: urlString)
                                                .frame(width: 60, height: 60) // Adjust the size as needed
                                        }
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(station.name)
                                                    .font(.headline)
                                                Text(station.country ?? "")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding() // Padding around the text
                                        .background(RoundedRectangle(cornerRadius: 10) // Rounded rectangle with corner radius 10
                                            .fill(Color.white.opacity(0.5))) // Fill the rectangle with gray color
                                    }
                                    //                                }
                                    //                                .padding(.leading)
                                    Divider() // Optional: If you want a line between each item like List
                                }
                            }
                            .padding(.horizontal, 10) // Add horizontal padding to separate the image from the text box
                        }
                        .frame(width: geometry.size.width)
                    }
                }

                //                ScrollView {
                //                    VStack {
                //                        ForEach(radioStations, id: \.self) { station in
                //                            Button(action: {
                //                                onDone(station)
                //                                presentationMode.wrappedValue.dismiss()
                //                            }) {
                //                                HStack {
                //                                    if let urlString = station.favicon {
                //                                        AsyncImage(url: urlString)
                //                                            .frame(width: 60, height: 60) // Adjust the size as needed
                //                                    }
                //                                    VStack(alignment: .leading) {
                //                                        Text(station.name)
                //                                            .font(.headline)
                //                                        Text(station.country ?? "")
                //                                            .font(.subheadline)
                //                                            .foregroundColor(.secondary)
                //                                    }
                //                                }
                //                            }
                //                            Divider() // Optional: If you want a line between each item like List
                //                        }
                //                    }
                //                }
                //                List(radioStations) { station in
                //                    Button(action: {
                //                        onDone(station)
                //                        presentationMode.wrappedValue.dismiss()
                //                    }) {
                //                        HStack {
                //                            if let urlString = station.favicon {
                //                                AsyncImage(url: urlString)
                //                                    .frame(width: 60, height: 60) // Adjust the size as needed
                //                            }
                //                            VStack(alignment: .leading) {
                //                                Text(station.name)
                //                                    .font(.headline)
                //                                Text(station.country ?? "")
                //                                    .font(.subheadline)
                //                                    .foregroundColor(.secondary)
                //                            }
                //                        }
                //                    }
                //                }
            }
        }
        .navigationBarTitle("Search Stations")
        .environment(\.layoutDirection, .leftToRight)
    }

    func searchRadioStations() {
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
    }
}

