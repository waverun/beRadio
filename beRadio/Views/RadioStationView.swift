import SwiftUI

class RadioStationData: ObservableObject {
    @Published var radioStations: [RadioStation] = []
    @Published var searchQuery = ""
}

struct RadioStationsView: View {
    @Environment(\.colorScheme) var colorScheme

//    @State private var searchQuery: String = ""
    @ObservedObject var radioStationsData = RadioStationData()
    @State private var showNoStationFound = false
    @State private var searching = false

    private var localStations = false
    private var country = ""
    private var state = ""
    private var genre = ""
    private var gradientLight: Gradient!
    private var gradientDark: Gradient!
    private var title = ""

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(genre: String = "", colors: [Color]? = nil, localStations: Bool = false, country: String = "", state: String = "", onDone: @escaping (RadioStation) -> Void) {
        self.onDone = onDone
        self.localStations = localStations
        self.country = country
        self.state = state
        self.genre = genre
        var colors = colors == nil ? [.blue, .purple] : colors!
        colors = [Color.adaptiveBlack] + colors
        self.gradientLight = Gradient(colors: colors)
        self.gradientDark =  Gradient(stops: [
            .init(color: colors[0], location: 0),
            .init(color: colors[1], location: 0.4),
            .init(color: colors[2], location: 1)
        ])

        switch true {
            case localStations: title = "Local Stations"
            case genre.contains(" Stations") :
                title = genre
                self.genre = ""
            default: title = genre + " Stations"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: colorScheme == .light ? gradientLight : gradientDark, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            if searching {
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
            }

            VStack {
                HStack {
                    TextField("Search Text", text: $radioStationsData.searchQuery, onCommit: {
                        if localStations {
                        }
                        searchRadioStations(genre, country, state)
                    })
                    .padding(5)
                    .background(Color.clear)
                    .foregroundColor(.purple)
                    .padding(.horizontal)

                    if showNoStationFound {
                        Text("No station found")
                    }
                    Button(action: {
                        searchRadioStations(genre, country, state)
                    }) {
                        Image(systemName: "magnifyingglass") // replace with your custom image name if any
                            .foregroundColor(.purple)
                    }
                    .padding(.trailing)
                }
                ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(radioStationsData.radioStations, id: \.self) { station in
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
                                                .fill(Color.adaptiveBlack.opacity(0.5)))
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                    }
                }
            }
        }
        .navigationBarTitle(title)
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            if localStations && !country.isEmpty
                || !genre.isEmpty {
                searchRadioStations(genre, country, state)
            }
        }
    }

    func searchRadioStations(_ genre: String = "", _ country: String = "", _ state: String = "") {
        searching = true
        if !genre.isEmpty && !radioStationsData.searchQuery.contains(genre) {
            radioStationsData.searchQuery = genre + " " + radioStationsData.searchQuery
        }
        fetchRadioStations(genre: genre, name: radioStationsData.searchQuery, country: country, state: state) { stations in
            searching = false
            radioStationsData.radioStations = stations
            showNoStationFound = false
            if stations.count == 0 {
                showNoStationFound = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showNoStationFound = false
                }
            }
        }
    }
//    func searchRadioStations(_ genre: String = "", _ country: String = "", _ state: String = "") {
//        searching = true
//        if !genre.isEmpty && !searchQuery.contains(genre) {
//            searchQuery = genre + " " + searchQuery
//        }
//        fetchRadioStations(genre: genre, name: searchQuery, country: country, state: state) { stations in
//            searching = false
//            radioStations = stations
//            showNoStationFound = false
//            if stations.count == 0 {
//                showNoStationFound = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    showNoStationFound = false
//                }
//            }
//        }
//    }
}

