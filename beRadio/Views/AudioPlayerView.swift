import SwiftUI
import AVFoundation

var gAudioPlayerView: AudioPlayerView?

struct AudioPlayerView: View {

    @State var currentProgress: Double = 0
//    let dominantColors = [Color.red, Color.yellow]

    //    let skipIntervals = [15, 30, 60, 120, 240, 480]
    
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var colorManager = sharedColorManager

//    @State private var dominantColors: [Color] = [Color.red, Color.yellow]  // Default values
    @State private var dominantColors: [Color] = []  // Default values
    @State private var playerTextColor: Color = Color.black  // Default value

    @StateObject private var routeChangeHandler = RouteChangeHandler()

    @Binding private var audioUrl: URL
    private var imageSrc: String?
    @Binding private var heading: String
    @Binding private var isLive: Bool
    
    private var title, artist: String
    
    @State private var currentImageSrc: String?
    @State private var isCurrentlyPlaying = false

    let onAppearAction: (() -> Void)?
    
#if os(tvOS)
    let frameWidth = 140.0
#else
    let frameWidth = 80.0

    var sliderRange: ClosedRange<Double> {
        let totalDuration = audioPlayer.totalDurationString.timeStringToDouble()
        let startSlider = max(0, totalDuration - audioPlayer.bufferDuration)

        // Using switch true to determine the range based on isLive
        switch true {
            case isLive:
                // If isLive is true, return a different range
                return startSlider...totalDuration
            default:
                // Default case for when isLive is false
                return 0...totalDuration
        }
    }
#endif

    init(url: Binding<URL>, image: String?, date: Binding<String>, isLive: Binding<Bool>, title: String, artist: String, onAppearAction: (() -> Void)? = nil) {
        print("AudioPlayerView init title \(title)")
        switch true {
            case gAudioPlayer == nil :
                self.audioPlayer = AudioPlayer(isLive: isLive.wrappedValue, albumArt: image, title: title, artist: artist)
            default:
                self.audioPlayer = gAudioPlayer!
        }
        _audioUrl = url
        self.imageSrc = image
        _heading = date
        _isLive = isLive
        self.title = title
        self.artist = artist
        self.onAppearAction = onAppearAction
        gAudioPlayerView = self
//        if let image = image,
//           let imageUrl = URL(string: image) {
//            imageLoader.loadDominantColors(from: imageUrl)
//        }
    }

    func play() {
        
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
//                RadialGradient(gradient: Gradient(colors: gDominantColors[imageSrc ?? ""] ?? [Color.red, Color.yellow]), center: .center, startRadius: 5, endRadius: 500)
                RadialGradient(gradient: Gradient(colors: dominantColors), center: .center, startRadius: 5, endRadius: 500)
                    .scaleEffect(1.5)
                    .ignoresSafeArea()
//                LinearGradient(gradient: Gradient(colors: [.adaptiveBlack, .clear]), startPoint: .top, endPoint: .bottom)
//                    .frame(height: UIScreen.main.bounds.height / 2)
//                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 8)
//                    .ignoresSafeArea()
                HStack {
                    Spacer()
                    VStack {
                        VStack {
                            Spacer()
                                .frame(height: 50) // Adjust the height value as needed
                            Text(heading)
                                .font(.system(size: 24)) // Adjust the size value as needed
                                .bold()
                                .multilineTextAlignment(.center)
//                                .foregroundColor(gPlayerTextColor[imageSrc ?? ""])
                                .foregroundColor(.white.opacity(0.5))
//                                .foregroundColor(playerTextColor)
                                .padding(EdgeInsets(top: 6, leading: 10, bottom: 8, trailing: 10)) // Add padding
                                .background(
                                    RoundedRectangle(cornerRadius: 20) // Rounded rectangle with corner radius 10
                                        .fill(Color.black.opacity(0.2)) // Fill with black color at 0.2 opacity
                                )
                            ZStack {
                                if let imageSrc = currentImageSrc {
                                    if #available(iOS 17, *) {
                                        switch true {
                                            case audioUrl.absoluteString.hasPrefix("/"):
                                                AsyncImage(url: imageSrc)
                                                    .frame(width: 240, height: 240)
#if targetEnvironment(macCatalyst)
                                                    .onChange(of: self.imageSrc) { newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc1: \(currentImageSrc ?? "no value")")
                                                    }
#else
                                                    .onChange(of: self.imageSrc) { oldValue, newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc2: \(currentImageSrc ?? "no value")")
                                                    }
#endif
                                            default:
                                                AsyncImage(url: imageSrc)
                                                    .frame(width: 120, height: 120)
#if targetEnvironment(macCatalyst)
                                                    .onChange(of: self.imageSrc) { newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc3: \(currentImageSrc ?? "no value")")
                                                    }
#else
                                                    .onChange(of: self.imageSrc) { oldValue, newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc4: \(currentImageSrc ?? "no value")")
                                                    }
#endif
                                        }
                                    } else {
                                        switch true {
                                            case audioUrl.absoluteString.hasPrefix("/"):
                                                AsyncImage(url: imageSrc)
                                                    .frame(width: 240, height: 240)
                                                    .onChange(of: self.imageSrc) { newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc5: \(currentImageSrc ?? "no value")")
                                                    }
                                            default:
                                                AsyncImage(url: imageSrc)
                                                    .frame(width: 120, height: 120)
                                                    .onChange(of: self.imageSrc) { newValue in
                                                        currentImageSrc = newValue
                                                        print("currentImageSrc6: \(currentImageSrc ?? "no value")")
                                                    }
                                        }
                                    }
                                    //                                if audioUrl.absoluteString.hasPrefix("/") {
                                    //                                    AsyncImage(url: imageSrc)
                                    //                                        .frame(width: 240, height: 240)
                                    //                                        .onChange(of: self.imageSrc) { newValue, _ in
                                    //                                            currentImageSrc = newValue
                                    //                                            print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                    //                                        }
                                    //                                }
                                    //                                else {
                                    //                                    AsyncImage(url: imageSrc)
                                    //                                        .frame(width: 120, height: 120)
                                    //                                        .onChange(of: self.imageSrc) { newValue, _ in
                                    //                                            currentImageSrc = newValue
                                    //                                            print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                    //                                        }
                                    //                                }
                                }
                            }
                            .padding(.bottom, 20)
                            HStack {
                                VStack {
                                    HStack {
                                        Button(action: {
                                            audioPlayer.rewind(by: 15)
                                        }) {
                                            Image(systemName: "gobackward.15")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .tint(.white)
                                        }

                                        Text("\(audioPlayer.currentProgressString)")
                                            .frame(width: frameWidth, alignment: .leading)
                                            .foregroundColor(.white)

                                        Button(action: {
                                            audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
                                        }) {
                                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 50)
                                                .tint(.white)
                                        }
                                        Text("\(audioPlayer.totalDurationString)")
                                            .frame(width: frameWidth, alignment: .trailing)
                                            .foregroundColor(.white)

                                        Button(action: {
                                            audioPlayer.forward(by: 15)
                                        }) {
                                            Image(systemName: "goforward.15")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .tint(.white)
                                        }
                                    }
                                }
                            }
#if !os(tvOS)
                            VStack {
                                Slider(value: $currentProgress,
                                       in: sliderRange,
//                                       in: max(0, $audioPlayer.totalDurationString.wrappedValue.timeStringToDouble() - audioPlayer.bufferDuration)...$audioPlayer.totalDurationString.wrappedValue.timeStringToDouble(),
                                       onEditingChanged: { isEditing in
                                    let startSlider = $audioPlayer.totalDurationString.wrappedValue.timeStringToDouble() - audioPlayer.bufferDuration
                                    print("AudioPlayerView slider startSlider: \(startSlider)")
                                    print("AudioPlayerView slider: \(isEditing) timeStringToDouble() \($audioPlayer.totalDurationString.wrappedValue.timeStringToDouble())")
                                    if isEditing {
                                        audioPlayer.shouldUpdateTotalDuration = false
                                        isCurrentlyPlaying = audioPlayer.isPlaying
                                        audioPlayer.pause()
                                    } else {
                                        audioPlayer.seekToNewTime(currentProgress.toCMTime())
                                        if isCurrentlyPlaying {
                                            audioPlayer.play()
                                        }
                                        //                                audioPlayer.shouldUpdateTotalDuration = true
                                    }
                                })
                                .tint(.secondary)
                                .padding(.horizontal)
                            }
#if targetEnvironment(macCatalyst)
                            .onChange(of: currentProgress) {newValue in
                                audioPlayer.setCurrentProgressString(time: newValue)
                            }
                            .onChange(of: audioPlayer.currentProgressString.timeStringToDouble()) { newValue in
                                currentProgress = newValue
                            }
#else
                            .onChange(of: currentProgress) {oldValue, newValue in
                                audioPlayer.setCurrentProgressString(time: newValue)
                            }
                            .onChange(of: audioPlayer.currentProgressString.timeStringToDouble()) { oldValue, newValue in
                                currentProgress = newValue
                            }
#endif
#else
                            Spacer()
#endif
                        }
#if !os(tvOS) && !targetEnvironment(macCatalyst)
                        let availableSpace = geometry.size.height - geometry.safeAreaInsets.bottom - geometry.size.width / 2
                        Spacer()
                            .frame(height: availableSpace / 4)

                        Button(action: {
                            selectAudioOutput()
                        }) {
                            Image(systemName: "airplayaudio")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.gray)
                        .cornerRadius(8)

                        Spacer()
#endif
                    }
                    Spacer()
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .onReceive(colorManager.$dominantColorsDict) { dict in
                if let colors = dict[self.imageSrc ?? ""],
                   !colors.isEmpty {
                    self.dominantColors = colors
                } else {
                    self.dominantColors = [.red, .yellow]
                }
            }
            .onReceive(colorManager.$playerTextColorDict) { dict in
                if let color = dict[self.imageSrc ?? ""] {
                    self.playerTextColor = color
                }
            }
            .onReceive(colorManager.$playerTextColorDict) { dict in
                if let color = dict[self.imageSrc ?? ""] {
                    self.playerTextColor = color
                }
            }
        }
        .onAppear {
            currentImageSrc = imageSrc
            if let imageSrc = currentImageSrc {
//                dominantColors = colorManager.dominantColorsDict[imageSrc] ?? [.red, .yellow]
                dominantColors = colorManager.dominantColorsDict[imageSrc] ?? []
                if dominantColors.isEmpty {
                    dominantColors = [.red, .yellow]
                }
            }
            if let action = onAppearAction {
                action()
            }
        }
        .onDisappear {
            gAudioPlayerView = nil
            audioPlayer.pause()
            audioPlayer.removePlayer()
            audioPlayer.removeRemoteCommandCenterTargets()
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
