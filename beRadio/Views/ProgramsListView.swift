import SwiftUI

struct ProgramsListView: View {
    let links: FetchedResults<Link>
    let removedLinks: FetchedResults<RemovedLink>
    let removeLinks: (IndexSet) -> Void
//    let title: String
    @Binding var title: String
    @Binding var showLivePlayerView: Bool
    @Binding var showingAddLinkView: Bool

    var body: some View {
        List {
            HStack {
                Spacer()
                Button(action: {
                    showLivePlayerView.toggle()
                }) {
                    Text("Live!")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: { showingAddLinkView.toggle() }) {
                    Label("Add link", systemImage: "plus")
                }
            }
        }
    }
}
