//
//  ContentView.swift
//  beRadio
//
//  Created by Shay  on 16/03/2023.
//

import SwiftUI
import CoreData
import AVFoundation
import CoreLocation
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var locationManager = LocationManager()

    @State private var title = "beRadio"
    @State private var showingAddLinkView = false
    @State private var showLivePlayerView: Bool = false
//    @State private var showingRadioStationsView = false
    @State private var showingLocalStationsView = false
//    @State private var locationManager = LocationManager()

//    @State private var locationManager: LocationManager!

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Link.url, ascending: true)],
                  animation: .default) private var links: FetchedResults<Link>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RemovedLink.url, ascending: true)],
                  animation: .default) private var removedLinks: FetchedResults<RemovedLink>
    
    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
    @State private var imageSrc: String? = "https://example.com/image.jpg"
    @State private var heading: String = "Some Heading"
    @State private var isLive: Bool = false
    @State private var isAuthorized = false

    let genres = ["Search Stations", "Pop", "Rock","50s", "Country", "Jazz", "Blues", "60s", "Reggae", "Hip Hop", "Classical", "70s","Latin", "Bluegrass", "Soul", "Punk", "80s", "Metal", "Gospel", "90s", "EDM", "Folk", "Disco", "Funk", "New Age"]
//    let gradients = [
//        Gradient(colors: [.blue, .purple]),
//        Gradient(colors: [.purple, .red]),
//        Gradient(colors: [.orange, .yellow]),
//        Gradient(colors: [.pink, .blue]),
//        Gradient(colors: [.green, .orange]),
//        Gradient(colors: [.yellow, .red]),
//        Gradient(colors: [.blue, .pink]),
//        Gradient(colors: [.red, .yellow]),
//        Gradient(colors: [.purple, .green]),
//        Gradient(colors: [.red, .blue]),
//        Gradient(colors: [.blue, .purple]),
//        Gradient(colors: [.purple, .red]),
//        Gradient(colors: [.orange, .yellow]),
//        Gradient(colors: [.pink, .blue]),
//        Gradient(colors: [.green, .orange]),
//        Gradient(colors: [.yellow, .red]),
//        Gradient(colors: [.blue, .pink]),
//        Gradient(colors: [.red, .yellow]),
//        Gradient(colors: [.purple, .green]),
//        Gradient(colors: [.red, .blue])
//    ]

    let colors: [[Color]] = [
        [Color.blue, Color.gray],
        [Color.blue, Color.purple],
        [Color.purple, Color.red],
        [Color.secondary, Color.white],
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

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(items) { item in
                        HStack {
                            if let url = item.favicon {
                                AsyncImage(url: url)
                                    .frame(width: 60, height: 60) // Adjust the size as needed
                            }
                            NavigationLink {
                                switch true {
                                case  links.isEmpty :
                                    Text("Loading...")
//                                case item.url == "https://cdn.cybercdn.live/103FM/Live/icecast.audio" :
//                                        ProgramsListView(links: links,
//                                                         removedLinks: removedLinks,
//                                                         removeLinks: removeLinks(atOffsets:),
//                                                         title: $heading,
//                                                         liveImageSrc: $imageSrc,
////                                                         showLivePlayerView: $showLivePlayerView,
//                                                         showingAddLinkView: $showingAddLinkView)
//                                        .onAppear {
//                                            heading = item.name ?? "Radio"
//                                            imageSrc = item.favicon
//                                        }
                                default :
                                    if  let urlString = item.url,
                                        let url = URL(string: urlString) {
                                        //                                        AudioPlayerView(url: url, image: item.favicon, date: item.name ?? "Radio", isLive: true)
                                        AudioPlayerView(url: $audioUrl, image: item.favicon, date: $heading, isLive: $isLive, title: item.name ?? "Radio", artist: "Live")
                                            .onAppear {
                                                DispatchQueue.main.async {
                                                    audioUrl = url
//                                                    imageSrc = item.favicon
                                                    heading =  item.name ?? "Radio"
                                                    isLive = true
                                                }
                                            }
                                    }
                                }
                            } label: {
                                Text(item.name ?? "New station")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                    NavigationLink {
                        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                            RadioStationsView(localStations: true, country: locationManager.currentCountry, state: locationManager.currentState) { station in
                                addItem(station)
                            }
                        } else {
                            LocationPermissionView(locationManager: locationManager)
                        }
//                        RadioStationsView(localStations: true) { station in
//                            addItem(station)
//                        }
                    } label: {
                        ZStack {
//                            LinearGradient(
//                                gradient: Gradient(colors: [.red, .blue]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
                            RadialGradient(
                                gradient: Gradient(colors: [.red, .blue]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
//                            AngularGradient(
//                                gradient: Gradient(colors: [.red, .blue]),
//                                center: .center,
//                                angle: .degrees(45)
//                            )
                            .edgesIgnoringSafeArea(.all)
                            .cornerRadius(10) // Adjust the corner radius as needed
                            Text("Local stations")
                                .foregroundColor(.white)
                        }
                    }
                    ForEach(Array(zip(genres, colors)), id: \.0) { genre, colors1 in
                        NavigationLink {
                            RadioStationsView(genre: genre, colors: colors1) { station in
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
//                    ToolbarItem {
//                        Button(action: showSearch) {
//                            Label("Add Item", systemImage: "plus")
//                        }
//                    }
                }
                .onAppear {
                    getHtmlContent(url: "https://103fm.maariv.co.il/programs/", search: "href=\"(/program/[^\"]+\\.aspx)\"") { extractedLinks in
                        DispatchQueue.main.async {
                            //                        links = extractedLinks
                            //                        clearAllUrls()
                            addLinks(urls: extractedLinks)
                        }
                    }
                    locationManager.checkLocationAuthorization()
                    isAuthorized = locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse
                }
                .onChange(of: locationManager.authorizationStatus) { newStatus in
                    isAuthorized = newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse
                }
                .navigationBarTitle(title, displayMode: .inline)
                Text("Select an item")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarTitle("beRadio", displayMode: .inline)
        .onAppear {
            configureAudioSession()
        }
//        .sheet(isPresented: $showingRadioStationsView) {
//            RadioStationsView() { station in
//                addItem(station)
//            }
//        }
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
    
//    private func showSearch() {
//        showingRadioStationsView.toggle()
//    }
    
    private func addItem(_ station: RadioStation) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = station.name
            newItem.url = station.url
            newItem.favicon = station.favicon
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
