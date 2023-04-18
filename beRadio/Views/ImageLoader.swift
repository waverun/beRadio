import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private var currentUrl: String?

    init(url: String) {
        update(url: url)
    }

    func update(url: String) {
        if currentUrl == url {
            return
        }
        
        currentUrl = url
        cancellable?.cancel()
        
        guard let url = URL(string: url) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
            }
    }
}

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    private let url: String

    init(url: String) {
        self.url = url
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if url.isEmpty {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
            } else if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(avoidBlackBackground(of: image) ? Color(UIColor.darkGray) : Color.clear)
            } else {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
            }
        }
        .onChange(of: url) { newValue in
            loader.update(url: newValue)
        }
    }
}

//struct AsyncImage: View {
//    @StateObject private var loader: ImageLoader
//    private let url: String
//
//    init(url: String) {
//        self.url = url
//        _loader = StateObject(wrappedValue: ImageLoader(url: url))
//    }
//
//    var body: some View {
//        Group {
//            if let image = loader.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .background(avoidBlackBackground(of: image) ? Color(UIColor.darkGray) : Color.clear)
//            } else {
//                Image(systemName: "antenna.radiowaves.left.and.right")
//                    .resizable()
//            }
//        }
//        .onChange(of: url) { newValue in
//            loader.update(url: newValue)
//        }
//    }
//}

//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//    private var cancellable: AnyCancellable?
//
//    init(url: String) {
//        guard let url = URL(string: url) else { return }
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                self?.image = $0
//            }
//    }
//}
//
//struct AsyncImage: View {
//    @StateObject private var loader: ImageLoader
//
//    init(url: String) {
//        _loader = StateObject(wrappedValue: ImageLoader(url: url))
//    }
//
//    var body: some View {
//        Group {
//            if let image = loader.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .background(avoidBlackBackground(of: image) ? Color(UIColor.darkGray) : Color.clear)
//            } else {
//                Image(systemName: "antenna.radiowaves.left.and.right")
//                    .resizable()
//            }
//        }
//    }
//}
