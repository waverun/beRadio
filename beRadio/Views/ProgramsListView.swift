//import SwiftUI
//
//struct ProgramsListView: View {
//    let links: FetchedResults<Link>
//    let removedLinks: FetchedResults<RemovedLink>
//    let removeLinks: (IndexSet) -> Void
//    @Binding var title: String
//    @Binding var liveImageSrc: String?
//    @Binding var showingAddLinkView: Bool
//
//    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
//    @State private var imageSrc: String? = "https://example.com/image.jpg"
//    @State private var heading: String = "Some Heading"
//    @State private var isLive: Bool = false
//    @State private var orderedLinks: [Link] = []
//
//    var body: some View {
//        List {
//            NavigationLink(destination: AudioPlayerView(url: $audioUrl, image: imageSrc, date: $heading, isLive: $isLive, title: "103 FM רדיו", artist: "Live")) {
//                HStack {
//                    AsyncImage(url: liveImageSrc ?? "")
//                        .frame(width: 60, height: 60) // Adjust the size as needed
//                    Spacer()
//                    Button(action: {
//                    }) {
//                        Text("Live!")
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 8)
//                            .background(Color.blue)
//                            .foregroundColor(.primary)
//                            .cornerRadius(8)
//                    }
//                    Spacer()
//                }
//            }
//            .onAppear {
//                if let url = URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio") {
//                    audioUrl = url
//                    imageSrc = liveImageSrc
//                    heading = title
//                    isLive = true
//                }
//            }
//
//            ForEach(orderedLinks, id: \.self) { link in
//                if !removedLinks.contains(where: { $0.url == link.url }) {
//                    if let url = link.url {
//                        let text = getUrlOrTitle(url: url, part: 1)
//                        let url = getUrlOrTitle(url: url, part: 0)
//                        NavigationLink(destination: fullProgramsView(link: url, title: text)) {
//                            LinkButton(label: text, link: url) { _ in }
//                        }
//                    }
//                }
//            }
//            .onDelete(perform: removeLinks)
//            .onMove(perform: moveLinks)
//            .padding(.top, -10)
//            .padding(.bottom, -10)
//        }
//        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//        .onAppear {
//            title = "103 FM"
//            loadOrder()
//            orderedLinks = orderedLinks.isEmpty ? Array(links) : mergeLinks()
//        }
//        .toolbar {
//#if !os(tvOS)
//            ToolbarItem(placement: .navigationBarTrailing) {
//                EditButton()
//            }
//#endif
//            ToolbarItem {
//                Button(action: { showingAddLinkView.toggle() }) {
//                    Label("Add link", systemImage: "plus")
//                }
//            }
//        }
//    }
//
//    func getUrlOrTitle(url: String, part: Int) -> String { // part 0 is url. 1 is title.
//        if url.contains("@") {
//            let urlParts = url.components(separatedBy: "@")
//            if urlParts.count > part {
//                return urlParts[part]
//            }
//        }
//        if part == 0 {
//            return url
//        }
//        return url.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
//    }
//
//    func moveLinks(from source: IndexSet, to destination: Int) {
//        orderedLinks.move(fromOffsets: source, toOffset: destination)
//        saveOrder()
//    }
//
//    func saveOrder() {
//        let order = orderedLinks.compactMap { $0.url }
//        UserDefaults.standard.set(order, forKey: "orderedLinks")
//    }
//
//    func loadOrder() {
//        if let savedOrder = UserDefaults.standard.stringArray(forKey: "orderedLinks") {
//            orderedLinks = savedOrder.compactMap { url in
//                links.first { $0.url == url }
//            }
//        }
//    }
//
//    func mergeLinks() -> [Link] {
//        var merged = orderedLinks
//        let newLinks = links.filter { link in
//            !orderedLinks.contains(where: { $0.url == link.url })
//        }
//        merged.insert(contentsOf: newLinks, at: 0)
//        return merged
//    }
//}

import SwiftUI

struct ProgramsListView: View {
    let links: FetchedResults<Link>
    let removedLinks: FetchedResults<RemovedLink>
    let removeLinks: (IndexSet) -> Void
    @Binding var title: String
    @Binding var liveImageSrc: String?
    @Binding var showingAddLinkView: Bool

    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
    @State private var imageSrc: String? = "https://example.com/image.jpg"
    @State private var heading: String = "Some Heading"
    @State private var isLive: Bool = false
    @State private var orderedLinks: [Link] = []
    @State private var searchText: String = ""

    var filteredLinks: [Link] {
        if searchText.isEmpty {
            return orderedLinks
        } else {
            return orderedLinks.filter { link in
                if let url = link.url {
                    return getUrlOrTitle(url: url, part: 1).localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }

    var body: some View {
//        NavigationView {
            List {
                NavigationLink(destination: AudioPlayerView(url: $audioUrl, image: imageSrc, date: $heading, isLive: $isLive, title: "103 FM רדיו", artist: "Live")) {
                    HStack {
                        AsyncImage(url: liveImageSrc ?? "")
                            .frame(width: 60, height: 60) // Adjust the size as needed
                        Spacer()
                        Button(action: {
                        }) {
                            Text("Live!")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                }
                .onAppear {
                    if let url = URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio") {
                        audioUrl = url
                        imageSrc = liveImageSrc
                        heading = title
                        isLive = true
                    }
                }

                ForEach(filteredLinks, id: \.self) { link in
                    if !removedLinks.contains(where: { $0.url == link.url }) {
                        if let url = link.url {
                            let text = getUrlOrTitle(url: url, part: 1)
                            let url = getUrlOrTitle(url: url, part: 0)
                            NavigationLink(destination: fullProgramsView(link: url, title: text)) {
                                LinkButton(label: text, link: url) { _ in }
                            }
                        }
                    }
                }
                .onDelete(perform: removeLinks)
                .onMove(perform: moveLinks)
                .padding(.top, -10)
                .padding(.bottom, -10)
            }
            .searchable(text: $searchText)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .navigationTitle("103 FM")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
#if !os(tvOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLinkView.toggle() }) {
                        Label("Add link", systemImage: "plus")
                    }
                }
//            }
        }
        .onAppear {
            title = "103 FM"
            loadOrder()
            orderedLinks = orderedLinks.isEmpty ? Array(links) : mergeLinks()
        }
    }

    func getUrlOrTitle(url: String, part: Int) -> String { // part 0 is url. 1 is title.
        if url.contains("@") {
            let urlParts = url.components(separatedBy: "@")
            if urlParts.count > part {
                return urlParts[part]
            }
        }
        if part == 0 {
            return url
        }
        return url.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
    }

    func moveLinks(from source: IndexSet, to destination: Int) {
        orderedLinks.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }

    func saveOrder() {
        let order = orderedLinks.compactMap { $0.url }
        UserDefaults.standard.set(order, forKey: "orderedLinks")
    }

    func loadOrder() {
        if let savedOrder = UserDefaults.standard.stringArray(forKey: "orderedLinks") {
            orderedLinks = savedOrder.compactMap { url in
                links.first { $0.url == url }
            }
        }
    }

    func mergeLinks() -> [Link] {
        var merged = orderedLinks
        let newLinks = links.filter { link in
            !orderedLinks.contains(where: { $0.url == link.url })
        }
        merged.insert(contentsOf: newLinks, at: 0)
        return merged
    }
}
