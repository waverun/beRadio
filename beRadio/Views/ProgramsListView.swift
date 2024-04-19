import SwiftUI

struct ProgramsListView: View {
    let links: FetchedResults<Link>
    let removedLinks: FetchedResults<RemovedLink>
    let removeLinks: (IndexSet) -> Void
//    let title: String
    @Binding var title: String
    @Binding var liveImageSrc: String?
    
//    @Binding var showLivePlayerView: Bool
    @Binding var showingAddLinkView: Bool

    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
    @State private var imageSrc: String? = "https://example.com/image.jpg"
    @State private var heading: String = "Some Heading"
    @State private var isLive: Bool = false

    var body: some View {
        List {
//                NavigationLink (destination: AudioPlayerView(url: url, image: nil, date: "103 FM", isLive: true)) {
                NavigationLink (destination: AudioPlayerView(url: $audioUrl, image: imageSrc, date: $heading, isLive: $isLive, title: "103 FM רדיו", artist: "Live")) {
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
//            }
            ForEach(links, id: \.self) { link in
                if !removedLinks.contains(where: { $0.url == link.url }) {
                    if var url = link.url {
                        let text = getUrlOrTitle(url: url, part: 1)
                        let url = getUrlOrTitle(url: url, part: 0)
                        NavigationLink(destination: fullProgramsView(link: url, title: text)) {
//                            if url.contains("@") {
//                                let urlParts = url.components(separatedBy: "@")
//                                if urlParts.count > 0 {
//                                    text = urlParts[1]
//                                    url = urlParts[0]
//                                }
//                            } else {
//                                text = url.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
//                            }
                            return LinkButton(label: text, link: url) { _ in }
                        }
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
        .toolbar {
#if !os(tvOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: { showingAddLinkView.toggle() }) {
                    Label("Add link", systemImage: "plus")
                }
            }
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
}
