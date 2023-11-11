import SwiftUI
import CoreData
import AVFoundation
import CoreLocation

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var colorManager = sharedColorManager
    #if !os(tvOS)
    @ObservedObject var locationManager = LocationManager()
    #else
    @State var isEditing: Bool = false
    @State private var showingDeletionAlert = false
    @State private var itemToDelete: Item? // Replace ItemType with your actual data type
    #endif

    @State private var title = "beRadio"
    @State private var showingAddLinkView = false
    @State private var showLivePlayerView: Bool = false
    @State private var showingLocalStationsView = false

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        predicate: NSPredicate(format: "isItemDeleted == %@", NSNumber(value: false)),
//        animation: .default)
//    var items: FetchedResults<Item>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.order, ascending: true)],
        predicate: NSPredicate(format: "isItemDeleted == %@", NSNumber(value: false)),
        animation: .default)
    var items: FetchedResults<Item>

    #if os(iOS)
    let endRadius = 100.0
    #else
    let endRadius = 200.0
    #endif

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    var deletedItems: FetchedResults<Item>
    var filteredItems: [Item] {
        return items.filter {
            searchText.isEmpty || $0.name?.localizedStandardContains(searchText) == true
        }
    }

    let radioStationsData = RadioStationData()

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Link.url, ascending: true)],
                  animation: .default) private var links: FetchedResults<Link>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RemovedLink.url, ascending: true)],
                  animation: .default) private var removedLinks: FetchedResults<RemovedLink>
    
    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
    @State private var imageSrc: String? = "https://example.com/image.jpg"
    @State private var heading: String = "Some Heading"
    @State private var isLive: Bool = false
    @State private var isAuthorized = false

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRadioStationsViewPresented = true
    @State private var searchText = ""

    @State var stationColors: [(station: String, colors: [Color])] = []
    @State var gradientColors: [Color] = []

    let genres = ["Search Stations", "Pop", "Rock","50s", "Country", "Jazz", "Blues", "60s", "Reggae", "Hip Hop", "Classical", "70s","Latin", "Bluegrass", "Soul", "Punk", "80s", "Metal", "Gospel", "90s", "EDM", "Folk", "Disco", "Funk", "New Age"]

    let colors: [[Color]] = [
        [Color.blue, Color.gray],
        [Color.blue, Color.purple],
        [Color.purple, Color.red],
        [Color.orange, Color.yellow],
        [Color.pink, Color.blue],
        [Color.green, Color.orange],
        [Color.green, Color.gray],
        [Color.yellow, Color.red],
        [Color.blue, Color.pink],
        [Color.red, Color.yellow],
        [Color.pink, Color.purple],
        [Color.purple, Color.green],
        [Color.red, Color.blue],
        [Color.blue, Color.purple],
        [Color.purple, Color.red],
        [Color.brown, Color.yellow],
        [Color.orange, Color.yellow],
        [Color.pink, Color.blue],
        [Color.blue, Color.orange],
        [Color.yellow, Color.red],
        [Color.blue, Color.pink],
        [Color.red, Color.yellow],
        [Color.purple, Color.green],
        [Color.red, Color.blue]
    ]

    init() {
        print("init")
    }

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    #if os(tvOS)
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Cancel" : "Edit")
                    }.disabled(items.isEmpty)
                    #endif
//                    ForEach(items.filter { item in
//                        searchText.isEmpty || item.name?.localizedStandardContains(searchText) == true
//                    }) { item in
//                    ForEach(filteredItems) { item in
                    ForEach(Array(zip(items, stationColors)), id: \.0) { item, stationColor in
                        HStack {
                            #if os(tvOS)
                            if isEditing {
                                Image(systemName: "trash") // Deletion symbol
                                    .foregroundColor(.red) // Set the color to red
                            }
                            #endif
                            if let url = item.favicon {
                                AsyncImage(url: url)
                                    .frame(width: 60, height: 60) // Adjust the size as needed
                            }
                            NavigationLink {
                                switch true {
#if os(tvOS)
                                    case isEditing :
                                        RemovalConfirmationView(stationName: item.name ?? "") {
                                            if let indexToRemove = items.firstIndex(where: { $0.id == item.id }) {
                                                let indexSet = IndexSet(arrayLiteral: indexToRemove)
                                                deleteItems(offsets: indexSet)
                                                if items.isEmpty {
                                                    isEditing = false
                                                }
                                            }
                                        }
#endif
#if DEBUG
                                    case item.url == "https://cdn.cybercdn.live/103FM/Live/icecast.audio" :
                                        ProgramsListView(links: links,
                                                         removedLinks: removedLinks,
                                                         removeLinks: removeLinks(atOffsets:),
                                                         title: $heading,
                                                         liveImageSrc: $imageSrc,
                                                         //                                                         showLivePlayerView: $showLivePlayerView,
                                                         showingAddLinkView: $showingAddLinkView)
                                        .onAppear {
                                            heading = item.name ?? "Radio"
                                            imageSrc = item.favicon
                                        }
#endif
                                    default :
                                        if  let urlString = item.url,
                                            let url = URL(string: urlString) {
                                            AudioPlayerView(url: $audioUrl, image: item.favicon, date: $heading, isLive: $isLive, title: item.name ?? "Radio", artist: "Live")
                                                .onAppear {
                                                    DispatchQueue.main.async {
                                                        audioUrl = url
                                                        heading =  item.name ?? "Radio"
                                                        isLive = true
                                                    }
                                                }
                                        }
                                }
                            } label: {
                                ZStack {
                                    RadialGradient(
                                        gradient: Gradient(colors: stationColor.colors),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: endRadius
                                    )
                                    .edgesIgnoringSafeArea(.all)
                                    .cornerRadius(10)
                                    Text(item.name ?? "New station")
                                    .foregroundColor(.white)
                                }
//                                .onAppear {
////                                    gradientColors = stationColor.colors!.isEmpty ? [Color.red, .yellow] : stationColor.colors
////                                    let defaultColors: [Color] = [Color.red, .yellow]
//                                    let actualColors = stationColor.colors
//                                    if !actualColors.isEmpty {
////                                        gradientColors = actualColors
//                                        stationColors.colors[urlString] = [.red, .yellow]
//                                    }
////                                    else {
////                                        gradientColors = defaultColors
////                                    }
//                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems) // Add this line for enabling the move functionality
//                    This is Local stations link:
//                    NavigationLink { // Local Stations
////                        var country = ""
////                        var state = ""
//#if os(tvOS)
////                        country = NSLocale.current.regionCode ?? ""
////                        state = ""
//#else
//                        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
////                            country = locationManager.currentCountry
////                            state = locationManager.currentState
//                        }
//                        //                    }
//                        else {
//                            LocationPermissionView(locationManager: locationManager)
//                        }
//#endif
//                        RadioStationsView(radioStationsData: radioStationsData, isPresented: $isRadioStationsViewPresented, approvedStations: ApprovedStations.shared.approvedStations, localStations: true, country: "country", state: "state") { station in
//                            addItem(station)
//                        }
//                    } label: {
//                        ZStack {
//                            //                            LinearGradient(
//                            //                                gradient: Gradient(colors: [.red, .blue]),
//                            //                                startPoint: .top,
//                            //                                endPoint: .bottom
//                            //                            )
//                            RadialGradient(
//                                gradient: Gradient(colors: [.red, .blue]),
//                                center: .center,
//                                startRadius: 0,
//                                endRadius: 200
//                            )
//                            //                            AngularGradient(
//                            //                                gradient: Gradient(colors: [.red, .blue]),
//                            //                                center: .center,
//                            //                                angle: .degrees(45)
//                            //                            )
//                            .edgesIgnoringSafeArea(.all)
//                            .cornerRadius(10) // Adjust the corner radius as needed
//                            Text("Local stations")
//                                .foregroundColor(.white)
//                        }
//                    }
                    ForEach(Array(zip(genres, colors)), id: \.0) { genre, colors1 in
                        NavigationLink {
                            RadioStationsView(radioStationsData: radioStationsData, isPresented: $isRadioStationsViewPresented, approvedStations: ApprovedStations.shared.approvedStations, genre: genre, colors: colors1) { station in
                                addItem(station)
                            }
                        } label: {
                            ZStack {
                                RadialGradient(
                                    gradient: Gradient(colors: colors1),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 200
                                )
                                .edgesIgnoringSafeArea(.all)
                                .cornerRadius(10)
                                Text(genre)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .searchable(text: $searchText)
                //                .sheet(isPresented: $showLivePlayerView) {
                //                    AudioPlayerView(url: URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio")!, image: nil, date: "103 FM", isLive: true)
                //                }
                //                .sheet(isPresented: $showingAddLinkView) {
                //                    //                                AddLinkView(links: $links)
                //                    AddLinkView(links: .constant(Array(links)), removedLinks: .constant(Array(removedLinks)))
                //                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                }
                .onAppear {
                    print("List: onAppear")
                    if items.count > 1 && items[0].order == 0 && items[1].order == 0 {
                        updateOrderForExistingItems()
                    }
                    if stationColors.isEmpty {
                        for item in items {
//                            var colors = [Color.red, Color.yellow]
                            var colors: [Color] = []
                            var urlString = ""
                            if let favicon = item.favicon {
                                urlString = favicon
                                if let colorsData = item.colors,
                                   let colorsFromData = dataToColors(data: colorsData) {
                                    colors = colorsFromData
                                    if colors.contains(.red) {
                                        print("colors are red and yellow")
                                    }
                                    switch true {
                                        case colorManager.dominantColorsBeingCalculatedFor.contains(urlString) :
                                            // For getting the colors again in case the operation of detecting the dominant colors which takes a long time was aborted due to exit app.
                                            colorManager.dominantColorsBeingCalculatedFor.remove(urlString)
                                        default:
                                            print("Content view onAppear colors", colors)
                                            colorManager.dominantColorsDict[urlString] = colors
                                    }
                                }
                            }
                            if colors.isEmpty {
                                colors = [.red, .yellow]
                            }
                            stationColors.append((urlString, colors))
                        }
                    }
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    //                        stationColors = []
                    //                        for item in items {
                    //                            if let urlString = item.url {
                    //                                stationColors.append((urlString, [Color.black, Color.white]))
                    //                            }
                    //                        }
                    //                    }
                    //                    addApprovedStations()
#if DEBUG
                    getHtmlContent(url: "https://103fm.maariv.co.il/programs/", search: "href=\"(/program/[^\"]+\\.aspx)\"") { extractedLinks in
                        DispatchQueue.main.async {
                            //                        links = extractedLinks
                            //                        clearAllUrls()
                            addLinks(urls: extractedLinks)
                        }
                    }
#endif
#if !os(tvOS)
                    locationManager.checkLocationAuthorization()
                    isAuthorized = locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse
#endif
                }
                .onReceive(colorManager.$dominantColorsDict) { dict in
                    onReceiveDominantColors(dict: dict)
                }
#if !os(tvOS)
#if targetEnvironment(macCatalyst)
                .onChange(of: locationManager.authorizationStatus) { newStatus in
                    isAuthorized = newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse
                }
#else
                .onChange(of: locationManager.authorizationStatus) { oldStatus, newStatus in
                    isAuthorized = newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse
                }
#endif
                .navigationBarTitle(title, displayMode: .inline)
#endif
                Text("Select an item")
            }
            .navigationViewStyle(.stack) // add this line after your NavigationView
        }
        .environment(\.layoutDirection, .leftToRight)
#if !os(tvOS)
        .navigationBarTitle("beRadio", displayMode: .inline)
#endif
        .onAppear {
            print("ZStak: onAppear")
//            addApprovedStations()
            configureAudioSession()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Excellent Choice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
//        .onDisappear {
//            showingAlert = false
//        }
    }
    
    func onReceiveDominantColors(dict: [String : [Color]]) {
        print("ContentView onReceive dict.count \(dict.count)")
        for station in dict.keys {
            let indexes = stationColors.enumerated().compactMap { (index, element) in
                return element.station == station ? index : nil
            }
            for index in indexes {
//            if let index = stationColors.firstIndex(where: { $0.station == station }) {
                print("Found index:", index, "stationColors.count:", stationColors.count)

//                stationColors[index].colors = dict[station] ?? [.red, .yellow]
                stationColors[index].colors = dict[station] ?? [.red, .yellow]

                let colorsForData = dict[station] ?? []
//                if let colors = colorsToData(colors: stationColors[index].colors) {
                if let colors = colorsToData(colors: colorsForData) {
                    items[index].colors = colors
                }
            }
        }
        saveItems()
    }

    private func clearAllUrls() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Link.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            for linkObject in results {
                if let link = linkObject as? Link {
                    viewContext.delete(link)
                }
            }
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func addLinks(urls: [String]) {
        withAnimation {
            for url in urls {
                if !urlFound(url) {
                    let newLink = Link(context: viewContext)
                    newLink.url = url
                }
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func urlFound(_ url: String) -> Bool {
        return links.contains(where: { $0.url == url }) || removedLinks.contains(where: { $0.url == url })
    }
    
    static var firstRemove = true
    
    private func removeLinks(atOffsets offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if !removedLinks.contains(where: { $0.url == links[index].url }) {
                    let removedLink = RemovedLink(context: viewContext)
                    removedLink.url = links[index].url
                }
                if !ContentView.firstRemove {
                    viewContext.delete(links[index]) // Delete the removedLink from viewContext
                }
                ContentView.firstRemove = false
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
        
    private func addItem(_ station: RadioStation) {
        withAnimation {
            addStation(station)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach { item in
                item.isItemDeleted = true
                if let index = stationColors.firstIndex(where: { $0.station == item.favicon }) {
                    print("Found index:", index)
                    stationColors.remove(at: index)
                }
            }

            // After deletion, update the order of the remaining items
            var index = 0
            for item in items {
                if !item.isItemDeleted {
                    item.order = Int16(index)
                    index += 1
                }
            }
            saveItems()
        }
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach { item in
//                item.isItemDeleted = true
//                if let index = stationColors.firstIndex(where: { $0.station == item.favicon }) {
//                    print("Found index:", index)  // Output will be 2
//                    stationColors.remove(at: index)
//                }
//
//            }
//            saveItems()
//        }
//    }

    func saveItems() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addApprovedStations() {
        for station in ApprovedStations.shared.approvedStations {
            let isDeleted = deletedItems.contains { $0.url == station.url }
            if !isDeleted {
                addStation(station, showMessage: false)
            }
        }
    }

    private func addStation(_ station: RadioStation, showMessage: Bool = true) {
        if itemExists(station: station) {
            if showMessage {
                alertMessage = "The station \(station.name) already exists."
                showingAlert = true
            }
            return
        }
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        newItem.name = station.name
        newItem.url = station.url
        newItem.favicon = station.favicon
        newItem.homepage = station.homepage
        newItem.isItemDeleted = false
        newItem.order = Int16(items.count)
//        if let index = stationColors.firstIndex(where: { $0.station == newItem.favicon }) {
//            newItem.colors = colorsToData(colors: stationColors[index].colors)
//        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        isRadioStationsViewPresented = false

        if let favicon = newItem.favicon {
//            stationColors.append((favicon, colorManager.dominantColorsDict[favicon] ?? [.red, .yellow]))
            stationColors.append((favicon, colorManager.dominantColorsDict[favicon] ?? [.red, .yellow]))
        }
    }

    private func itemExists(station: RadioStation) -> Bool {
        return items.contains(where: { $0.url == station.url && $0.favicon == station.favicon })
    }

    // Convert an array of Colors to Data
    func colorsToData(colors: [Color]) -> Data? {
        let codableColors = colors.map { CodableColor(UIColor($0)) }
        return try? JSONEncoder().encode(codableColors)
    }

    // Convert Data back to an array of Colors
    func dataToColors(data: Data) -> [Color]? {
        guard let decodedColors = try? JSONDecoder().decode([CodableColor].self, from: data) else {
            return nil
        }
        return decodedColors.map { Color($0.color) }
    }

    func updateOrderForExistingItems() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            let existingItems = try viewContext.fetch(fetchRequest)
            for (index, item) in existingItems.enumerated() {
                item.order = Int16(index)
            }
            try viewContext.save()
        } catch {
            // Handle the error appropriately
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        // Create a temporary array to represent the new order
        var reorderedItems = Array(items)

        // Reorder the temporary array
        reorderedItems.move(fromOffsets: source, toOffset: destination)

        // Update the order of items in Core Data
        for (index, item) in reorderedItems.enumerated() {
            // Assuming 'order' is an attribute in your Core Data model
            item.order = Int16(index)
        }

        // Save the changes to Core Data
        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
        }

        // Update the stationColors array
        stationColors.move(fromOffsets: source, toOffset: destination)
    }
}
