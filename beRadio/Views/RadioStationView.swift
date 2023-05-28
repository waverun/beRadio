import SwiftUI

struct RadioStationsView: View {
    @State private var searchQuery: String = ""
    @State private var radioStations: [RadioStation] = []
    @State private var showNoStationFound = false
    @State private var searching = false // <- Here

    private var localStations = false
    private var country = ""
    private var state = ""

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(localStations: Bool = false, country: String = "", state: String = "", onDone: @escaping (RadioStation) -> Void) {
        self.onDone = onDone
        self.localStations = localStations
        self.country = country
        self.state = state
//        if localStations && !country.isEmpty {
//            searchRadioStations(country, state)
//        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.adaptiveBlack, .blue, .purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if searching {
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
            }

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
                    .padding(.horizontal)

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
//                    VStack {
//                        GeometryReader { geometry in
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
                                            .background(RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(0.5)))
                                        }
//                                        Divider()
                                    }
                                }
                                .padding(.horizontal, 10)
//                            }
//                            .frame(width: geometry.size.width)
//                        }
                    }
                }

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
        .onAppear {
            if localStations && !country.isEmpty {
                searchRadioStations(country, state)
            }
        }
    }

    func searchRadioStations(_ country: String = "", _ state: String = "") {
        searching = true
        fetchRadioStations(name: searchQuery, country: country, state: state) { stations in
            searching = false
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

