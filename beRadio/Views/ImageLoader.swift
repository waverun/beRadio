import SwiftUI
import Combine
import Foundation

//var gDominantColors = ThreadSafeDict<String, [Color]>()

let sharedColorManager = ColorManager()

class ColorManager: ObservableObject {
//    @AppStorage("dominantColorsBeingCalculatedForString") private var dominantColorsBeingCalculatedForString: String = ""

    var dominantColorsBeingCalculatedFor = Set<String>()
//    {
//        get {
//            Set(dominantColorsBeingCalculatedForString.split(separator: ",").map { String($0) })
//        }
//        set {
//            dominantColorsBeingCalculatedForString = newValue.joined(separator: ",")
//        }
//    }


    @Published var dominantColorsDict: [String: [Color]] = [:]
//    @Published var dominantColorsBeingCalculatedFor = Set<String>()
    @Published var playerTextColorDict: [String: Color] = [:]
    @Published var imageDict: [String: UIImage] = [:]


//    init() {
//        if !dominantColorsBeingCalculatedForString.isEmpty {
//            dominantColorsBeingCalculatedFor = Set(dominantColorsBeingCalculatedForString.split(separator: ",").map { String($0) })
//        }
//    }

    func updateColors(for url: String, dominantColors: [Color]) {
        DispatchQueue.main.async {
            self.dominantColorsDict[url] = dominantColors
            let playerTextColor = dominantColors.count > 1 && isBrightColor(of: dominantColors[0]) ? .black : Color(.white)
            self.playerTextColorDict[url] = playerTextColor
        }
    }
}

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
                       sharedColorManager.dominantColorsDict [currentUrl] == nil ||
                        sharedColorManager.dominantColorsDict [currentUrl]!.isEmpty,
                       !sharedColorManager.dominantColorsBeingCalculatedFor.contains(currentUrl) {
                        sharedColorManager.dominantColorsBeingCalculatedFor.insert(currentUrl)
                        DispatchQueue.global(qos: .background).async {
                            print("ImageLoader update DispatchQueue.global")
                            if let dominantColors = getDominantColors(in: image),
                               dominantColors.count > 1 {
                                DispatchQueue.main.async {
                                    sharedColorManager.updateColors(for: currentUrl, dominantColors: dominantColors)
                                    sharedColorManager.dominantColorsBeingCalculatedFor.remove(currentUrl)
                                }
                            }
                        }
                    }
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
