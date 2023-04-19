//
//  ContentView.swift
//  beRadio
//
//  Created by Shay  on 16/03/2023.
//

import SwiftUI
import CoreData
import AVFoundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title = "beRadio"
    @State private var showingAddLinkView = false
    @State private var showLivePlayerView: Bool = false
    @State private var showingRadioStationsView = false
    
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
                                default :
                                    if  let urlString = item.url,
                                        let url = URL(string: urlString) {
                                        //                                        AudioPlayerView(url: url, image: item.favicon, date: item.name ?? "Radio", isLive: true)
                                        AudioPlayerView(url: $audioUrl, image: item.favicon, date: $heading, isLive: $isLive)
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
                }
//                .sheet(isPresented: $showLivePlayerView) {
//                    AudioPlayerView(url: URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio")!, image: nil, date: "103 FM", isLive: true)
//                }
                .sheet(isPresented: $showingAddLinkView) {
                    //                                AddLinkView(links: $links)
                    AddLinkView(links: .constant(Array(links)), removedLinks: .constant(Array(removedLinks)))
                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: showSearch) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .onAppear {
                    getHtmlContent(url: "https://103fm.maariv.co.il/programs/", search: "href=\"(/program/[^\"]+\\.aspx)\"") { extractedLinks in
                        DispatchQueue.main.async {
                            //                        links = extractedLinks
                            //                        clearAllUrls()
                            addLinks(urls: extractedLinks)
                        }
                    }
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
        .sheet(isPresented: $showingRadioStationsView) {
            RadioStationsView() { station in
                addItem(station)
            }
        }
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
    
    private func showSearch() {
        showingRadioStationsView.toggle()
    }
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
