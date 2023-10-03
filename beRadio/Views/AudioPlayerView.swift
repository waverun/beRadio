import SwiftUI
import AVFoundation

var gAudioPlayerView: AudioPlayerView?

struct AudioPlayerView: View {
//    @Environment(\.presentationMode) var presentationMode

    @State private var currentProgress: Double = 0
    
    //    let skipIntervals = [15, 30, 60, 120, 240, 480]
    
    @ObservedObject var audioPlayer: AudioPlayer
    
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
    let frameWidth = 70.0
#endif

    init(url: Binding<URL>, image: String?, date: Binding<String>, isLive: Binding<Bool>, title: String, artist: String, onAppearAction: (() -> Void)? = nil) {
        self.audioPlayer = AudioPlayer(isLive: isLive.wrappedValue, albumArt: image, title: title, artist: artist)
        _audioUrl = url
        self.imageSrc = image
        _heading = date
        _isLive = isLive
        self.title = title
        self.artist = artist
        self.onAppearAction = onAppearAction
        gAudioPlayerView = self
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadialGradient(gradient: Gradient(colors: [.red, .yellow]), center: .center, startRadius: 5, endRadius: 500)
                    .scaleEffect(1.5)
                    .ignoresSafeArea()
                LinearGradient(gradient: Gradient(colors: [.adaptiveBlack, .clear]), startPoint: .top, endPoint: .bottom)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 8)
                    .ignoresSafeArea()
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
                                .foregroundColor(.secondary)
                            if let imageSrc = currentImageSrc {
                                if #available(iOS 17, *) {
                                    switch true {
                                        case audioUrl.absoluteString.hasPrefix("/"):
                                            AsyncImage(url: imageSrc)
                                                .frame(width: 240, height: 240)
                                                .onChange(of: self.imageSrc) { newValue, _ in
                                                    currentImageSrc = newValue
                                                    print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                                }
                                        default:
                                            AsyncImage(url: imageSrc)
                                                .frame(width: 120, height: 120)
                                                .onChange(of: self.imageSrc) { newValue, _ in
                                                    currentImageSrc = newValue
                                                    print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                                }
                                    }
                                } else {
                                    switch true {
                                        case audioUrl.absoluteString.hasPrefix("/"):
                                            AsyncImage(url: imageSrc)
                                                .frame(width: 240, height: 240)
                                                .onChange(of: self.imageSrc) { newValue in
                                                    currentImageSrc = newValue
                                                    print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                                }
                                        default:
                                            AsyncImage(url: imageSrc)
                                                .frame(width: 120, height: 120)
                                                .onChange(of: self.imageSrc) { newValue in
                                                    currentImageSrc = newValue
                                                    print("currentImageSrc: \(currentImageSrc ?? "no value")")
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
                            Slider(value: $currentProgress,
                                   in: 0...$audioPlayer.totalDurationString.wrappedValue.timeStringToDouble(),
                                   onEditingChanged: { isEditing in
                                print("slider: \(isEditing)")
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
                            .onChange(of: currentProgress) {newValue in
                                audioPlayer.setCurrentProgressString(time: newValue)
                            }
                            .onChange(of: audioPlayer.currentProgressString.timeStringToDouble()) { newValue in
                                currentProgress = newValue
                            }
#else
                            Spacer()
#endif
                        }
                        #if !os(tvOS)
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
//            .edgesIgnoringSafeArea(.all)
        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading:
//            Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            HStack(spacing: 0) {
//                Text("Back")
//                Image(systemName: "chevron.right") // SF Symbols arrow
//            }
//        }
//        )
        .onAppear {
            currentImageSrc = imageSrc
            if let action = onAppearAction {
                action()
            }
        }
        .onDisappear {
            gAudioPlayerView = nil
            audioPlayer.pause()
            audioPlayer.removePlayer()
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
