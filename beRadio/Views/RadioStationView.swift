import SwiftUI

struct RadioStationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    
//    @ObservedObject var radioStationsData = RadioStationData()
    @ObservedObject var radioStationsData: RadioStationData

    @State private var showNoStationFound = false
    @State private var showingWebView = false
    @State private var searching = false
    @State private var isError = false
    @State private var showingAlert = false

    private var localStations = false
    private var country = ""
    private var state = ""
    private var genre = ""
    private var gradientLight: Gradient!
    private var gradientDark: Gradient!
    private var title = ""
    private var approvedStations: [RadioStation]!

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(radioStationsData: RadioStationData, isPresented: Binding<Bool>, approvedStations: [RadioStation], genre: String = "", colors: [Color]? = nil, localStations: Bool = false, country: String = "", state: String = "", onDone: @escaping (RadioStation) -> Void) {
//        radioStationsData.searchQuery = ""
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
        self.approvedStations = approvedStations
        self._isPresented = isPresented
        self.radioStationsData = radioStationsData
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

            VStack (alignment: .leading) {
                HStack {
                    TextField("Search Text", text: $radioStationsData.searchQuery, onCommit: {
                        if localStations {
                        }
                        searchRadioStations(approvedStations, genre, country, state)
                    })
                    .padding(5)
                    .background(Color.clear)
                    .foregroundColor(.purple)
                    .padding(.horizontal)

                    if showNoStationFound {
                        Text("No station found")
                    }
                    Button(action: {
                        searchRadioStations(approvedStations, genre, country, state)
                    }) {
                        Image(systemName: "magnifyingglass") // replace with your custom image name if any
                            .foregroundColor(.purple)
                    }
                    .padding(.trailing)
                }
                .padding()
                ScrollView {
                    VStack(alignment: .leading) {
                        Button(action: {
                            showingAlert = true
                        }) {
                            HStack {
                                Image("AppIconImage")
                                    .resizable()
                                    .frame(width: 60, height: 60) // Adjust the size as needed
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("beRadio")
                                        .font(.headline)
                                    Text("App")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding() // Padding around the text
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.adaptiveBlack.opacity(0.5)))
                        }
                        .padding(.horizontal, 10)
                        ForEach(radioStationsData.radioStations, id: \.self) { station in
                            Button(action: {
                                radioStationsData.selectedStation = station
                                onDone(station)
//                                isPresented = false
//                                radioStationsData.showingActionSheet = true
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
        .onChange(of: isPresented) { value, _ in
            if !value {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
#if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            isPresented = true

            if localStations && !country.isEmpty
                || !genre.isEmpty {
                radioStationsData.searchQuery = ""
                searchRadioStations(approvedStations, genre, country, state)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Attention radio station owners and authorized representatives!"),
                message: Text("If you own or hold the rights to authorize the streaming of a radio station, we would love to feature your station on our beRadio app."),
                primaryButton: .default(Text("Email Us")) {
                    if let url = URL(string: "mailto:shanymore1222@gmail.com") {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    func searchRadioStations(_ approvedStations: [RadioStation], _ genre: String = "", _ country: String = "", _ state: String = "") {
        searching = true
        if !genre.isEmpty && !radioStationsData.searchQuery.contains(genre) {
            radioStationsData.searchQuery = genre + " " + radioStationsData.searchQuery
        }
        fetchRadioStations(approvedStations: approvedStations, genre: genre, name: radioStationsData.searchQuery, country: country, state: state) { stations in
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
}

