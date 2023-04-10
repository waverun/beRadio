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
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            if links.isEmpty {
                                Text("Loading...")
                            } else {
                                List {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            showLivePlayerView.toggle()
                                        }) {
                                            Text("Live!")
                                                .padding(.horizontal, 8) // Adjust horizontal padding
                                                .padding(.vertical, 8) // Adjust vertical padding
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        Spacer()
                                    }
                                    ForEach(links, id: \.self) { link in
                                        if !removedLinks.contains(where: { $0.url == link.url }) {
                                            NavigationLink(destination: fullProgramsView(link: link.url!)) {
                                                let text = link.url!.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
                                                
                                                LinkButton(label: text, link: link.url!) { _ in }
                                            }
                                        }
                                    }
                                    .onDelete(perform: removeLinks)
                                    .padding(.top, -10)
                                    .padding(.bottom, -10)
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .onAppear {
                                    title = "103 FM"
                                }
                                //                                .padding(.top, -10)
                                
                                //                            .padding(.top, -40) // Adjust the value to your desired padding
                                .sheet(isPresented: $showLivePlayerView) {
                                    //                                if let url = fullProgramsView.selectedAudioUrl,
                                    //            //                       let image = fullProgramsView.selectedAudioImage,
                                    //                                   let date = fullProgramsView.selectedAudioDate {
                                    //                                   let image = fullProgramsView.selectedAudioImage
                                    AudioPlayerView(url: URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio")!, image: nil, date: "103 FM")
                                    //                                } else {
                                    //                                    Text("No Stream found")
                                    //                                }
                                }
                                //                            }
                                .toolbar {
#if os(iOS)
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        EditButton()
                                    }
#endif
                                    ToolbarItem {
                                        //                                    Button(action: addNewLink) {
                                        //                                        Label("Add link", systemImage: "plus")
                                        //                                    }
                                        Button(action: { showingAddLinkView.toggle() }) {
                                            Label("Add link", systemImage: "plus")
                                        }
                                    }
                                }
                                .sheet(isPresented: $showingAddLinkView) {
                                    //                                AddLinkView(links: $links)
                                    AddLinkView(links: .constant(Array(links)), removedLinks: .constant(Array(removedLinks)))
                                }
                            }
                            //                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                            Text("beRadio")
                        } label: {
                            Text(item.station ?? "New station")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                    ToolbarItem {
                        Button(action: addItem) {
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
            VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingRadioStationsView.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarTitle("beRadio", displayMode: .inline)
        .onAppear {
            configureAudioSession()
        }
        .sheet(isPresented: $showingRadioStationsView) {
//            SearchView()
            RadioStationsView()
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
                //                addLink(url: url)
                if !urlFound(url) {
                    let newLink = Link(context: viewContext)
                    newLink.url = url
                }
                //                newLink.isHidden = false
                //                ContentView.lastRemovedUrl = ""
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
        //        return false
    }
    //
    //    private func addNewLink() {
    //            addLink()
    //    }
    
    //    private func addLink(url: String? = nil) {
    //        let url = url ?? "New program"
    //        let newLink = Link(context: viewContext)
    //        newLink.url = url
    //        newLink.isHidden = false
    //
    //        do {
    //            try viewContext.save()
    //        } catch {
    //            let nsError = error as NSError
    //            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //        }
    //    }
    
    static var firstRemove = true
    
    private func removeLinks(atOffsets offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                //                let link = links[index]
                //                links[index].isHidden = true
                //                ContentView.lastRemovedUrl = links[index].url!
                
                //                print("Updated lastRemovedUrl: \(ContentView.lastRemovedUrl)")
                //                removedLinks.append(links[index])
                if !removedLinks.contains(where: { $0.url == links[index].url }) {
                    let removedLink = RemovedLink(context: viewContext)
                    removedLink.url = links[index].url
                }
                //                offsets.map { links[$0] }.forEach(viewContext.delete)
                if !ContentView.firstRemove {
                    viewContext.delete(links[index]) // Delete the removedLink from viewContext
                    viewContext.delete(links[index]) // Delete the removedLink from viewContext
                }
                ContentView.firstRemove = false
                //                viewContext.delete(links[index]) // Delete the removedLink from viewContext
                
                //                   do {
                //                       try viewContext.save()
                //                       if let index1 = links.firstIndex(where: { $0.url == links[index].url }) {
                //                           links.remove(at: index1) // Update the removedLinks array
                //                       }
                //                   } catch {
                //                       print("Error saving viewContext: \(error)")
                //                   }
                
                //                link.isHidden = true
                //            }
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            //           refreshLinks()
        }
    }
    
    //    private func removeLinks(atOffsets offsets: IndexSet) {
    //        for index in offsets {
    //            let link = links[index]
    //            link.isHidden = true
    ////            viewContext.delete(link)
    //        }
    //        do {
    //            try viewContext.save()
    //        } catch {
    //            let nsError = error as NSError
    //            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //        }
    //    }
    
    //    private func deleteLink(at offsets: IndexSet) {
    //        links.remove(atOffsets: offsets)
    //    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.station = "103 FM"
            
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
