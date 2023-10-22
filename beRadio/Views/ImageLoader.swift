import SwiftUI
import Combine
import Foundation

//var gDominantColors = ThreadSafeDict<String, [Color]>()

class ColorManager: ObservableObject {
    @Published var dominantColorsDict: [String: [Color]] = [:]
    @Published var playerTextColorDict: [String: Color] = [:]
    @Published var imageDict: [String: UIImage] = [:]

    func updateColors(for url: String, dominantColors: [Color], playerTextColor: Color) {
        DispatchQueue.main.async {
            self.dominantColorsDict[url] = dominantColors
            self.playerTextColorDict[url] = playerTextColor
        }
    }
}

let sharedColorManager = ColorManager()

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private var currentUrl: String?

    init(url: String, _ shouldGetDominantColors: Bool) {
        update(url: url, shouldGetDominantColors)
    }

    func update(url: String, _ shouldGetDominantColors: Bool) {
        if currentUrl == url {
            return
        }
        
        currentUrl = url

        if  let currentUrl = currentUrl,
            let currentImage = sharedColorManager.imageDict[currentUrl] {
            image = currentImage
        }

        cancellable?.cancel()
        
        guard let url = URL(string: url) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
                if let currentUrl = self?.currentUrl,
                   let image = self?.image {
                    sharedColorManager.imageDict[currentUrl] = image
                    if shouldGetDominantColors,
                       sharedColorManager.dominantColorsDict [currentUrl] == nil {
                        DispatchQueue.global(qos: .background).async {
                            print("ImageLoader update DispatchQueue.global")
                            if let dominantColors = getDominantColors(in: image),
                               dominantColors.count > 1 {
                                DispatchQueue.main.async {
                                    let playerTextColor = dominantColors.count > 1 && isBrightColor(of: dominantColors[0]) ? .black : Color(.white)

                                    sharedColorManager.updateColors(for: currentUrl, dominantColors: dominantColors, playerTextColor: playerTextColor.opacity(0.8))
                                }
                            }
                        }
                    }
//                    DispatchQueue.global(qos: .background).async {
//                        if let dominantColors = getDominantColors(in: image) {
//                            DispatchQueue.main.async {
//                                gDominantColors[currentUrl] = dominantColors
//                                gPlayerTextColor[currentUrl] = dominantColors.count > 1 && isBrightColor(of: dominantColors[0]) ? Color(.black) : Color(.systemGray2)
//                            }
//                        }
//                    }
                }
            }
    }
}

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    let url: String
    let shouldGetDominantColors: Bool

    init(url: String, shouldGetDominantColors: Bool = true) {
        self.url = url
        self.shouldGetDominantColors = shouldGetDominantColors
        _loader = StateObject(wrappedValue: ImageLoader(url: url, shouldGetDominantColors))
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
#if targetEnvironment(macCatalyst)
        .onChange(of: url) { newValue in
            loader.update(url: newValue, shouldGetDominantColors)
        }
#else
        .onChange(of: url) { oldValue, newValue in
            loader.update(url: newValue, shouldGetDominantColors)
        }
#endif
    }
}
