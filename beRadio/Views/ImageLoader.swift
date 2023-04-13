//import SwiftUI
//import Combine
//import Foundation
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
//            } else {
//                ProgressView()
//            }
//        }
//    }
//}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    init(url: String) {
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

import SwiftUI
import Combine
import Foundation

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    
    init(url: String) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
//                let b = avoidBlackBackground(of: image)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(avoidBlackBackground(of: image) ? Color(UIColor.darkGray) : Color.clear)
            } else {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .resizable()
            }
        }
    }
}

//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//    @Published var showFallbackImage = false
//
//    private var cancellable: AnyCancellable?
//    private let timeoutInSeconds: TimeInterval = 5
//
//    init(url: String) {
//        guard let url = URL(string: url) else { return }
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .timeout(timeoutInSeconds, scheduler: DispatchQueue.main)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.showFallbackImage = true
//                default:
//                    break
//                }
//            }, receiveValue: { [weak self] image in
//                self?.image = image
//            })
//    }
//}

//class ImageLoader: ObservableObject {
//    @Published var image: UIImage?
//    @Published var showFallbackImage = false
//
//    private var cancellable: AnyCancellable?
//    private let timeoutInSeconds: TimeInterval = 5
//
//    init(url: String) {
//        guard let url = URL(string: url) else { return }
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data) }
//            .replaceError(with: nil)
//            .timeout(RunLoop.SchedulerTimeType.Stride(timeoutInSeconds), scheduler: RunLoop.main)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    self?.showFallbackImage = true
//                default:
//                    break
//                }
//            }, receiveValue: { [weak self] image in
//                self?.image = image
//            })
//    }
//}
