import SwiftUI
import CoreData

struct AddLinkView: View {
    @Binding var links: [Link]
    @Binding var removedLinks: [RemovedLink]
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

//    var hiddenLinks: [Link] {
//        links.filter { $0.isHidden }
//    }

    var body: some View {
        NavigationView {
            List {
                ForEach(removedLinks, id: \.self) { removedLink in
                    Button(action: {
//                        link.isHidden = false
                        if !links.contains(where: { $0.url == removedLink.url }) {
                            let link = Link(context: viewContext)
                            link.url = removedLink.url
                        }
//                        removedLinks.map { removedLinks[$0] }.forEach(viewContext.delete)
//                        removedLinks.removeAll { $0.url == removedLink.url }
//                        removedLinks = removedLinks.filter { $0.url != removedLink.url }
//
//                        try? viewContext.save()
                        
                        viewContext.delete(removedLink) // Delete the removedLink from viewContext

                           do {
                               try viewContext.save()
                               if let index = removedLinks.firstIndex(where: { $0.url == removedLink.url }) {
                                   removedLinks.remove(at: index) // Update the removedLinks array
                               }
                           } catch {
                               print("Error saving viewContext: \(error)")
                           }
                        
                        dismiss()
                    }) {
                        if let url = removedLink.url {
                            Text(url.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: ""))
                        }
                    }
                }
            }
            .navigationTitle("Select a link")
            .navigationBarItems(trailing: Button("Cancel", action: { dismiss() }))
        }
    }
}
