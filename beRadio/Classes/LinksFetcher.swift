//import SwiftUI
//import CoreData
//
////class LinksFetcher: ObservableObject {
////    @Published var links: [Link] = []
////    private var viewContext: NSManagedObjectContext
////
////    init(viewContext: NSManagedObjectContext) {
////        self.viewContext = viewContext
////        fetchLinks()
////    }
////
////    func fetchLinks() {
////        let fetchRequest: NSFetchRequest<Link> = Link.fetchRequest()
////        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Link.url, ascending: true)]
////
////        do {
////            links = try viewContext.fetch(fetchRequest)
////        } catch {
////            print("Error fetching links: \(error)")
////        }
////    }
////}
//
//class LinksFetcher: ObservableObject {
//    @Published var links: [Link] = []
//    var viewContext: NSManagedObjectContext?
//
//    init(viewContext: NSManagedObjectContext? = nil) {
//        self.viewContext = viewContext
//        fetchLinks()
//    }
//
//    func fetchLinks() {
//        guard let viewContext = viewContext else { return }
//
//        let fetchRequest: NSFetchRequest<Link> = Link.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Link.url, ascending: true)]
//
//        do {
//            links = try viewContext.fetch(fetchRequest)
//        } catch {
//            print("Error fetching links: \(error)")
//        }
//    }
//}
//
