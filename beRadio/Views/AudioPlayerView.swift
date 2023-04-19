import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject private var audioPlayer: AudioPlayer
    
    @StateObject private var routeChangeHandler = RouteChangeHandler()
    
    @Binding private var audioUrl: URL
    private var imageSrc: String?
    @Binding private var heading: String
    @Binding private var isLive: Bool
    
    @State private var currentImageSrc: String?

    let onAppearAction: (() -> Void)?

    init(url: Binding<URL>, image: String?, date: Binding<String>, isLive: Binding<Bool>, onAppearAction: (() -> Void)? = nil) {
        self.audioPlayer = AudioPlayer(isLive: isLive.wrappedValue, albumArt: image)
        _audioUrl = url
        self.imageSrc = image
        _heading = date
        _isLive = isLive
        self.onAppearAction = onAppearAction
    }

    var body: some View {
        GeometryReader { geometry in
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
                        if let imageSrc = currentImageSrc {
                            if audioUrl.absoluteString.hasPrefix("/") {
                                AsyncImage(url: imageSrc)
                                    .frame(width: 240, height: 240)
                                    .onChange(of: self.imageSrc) { newValue in
                                        currentImageSrc = newValue
                                        print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                    }
                            }
                            else {
                                AsyncImage(url: imageSrc)
                                    .frame(width: 60, height: 60)
                                    .onChange(of: self.imageSrc) { newValue in
                                        currentImageSrc = newValue
                                        print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                    }
                            }
                        }
                        HStack {
                            Text("\(audioPlayer.totalDurationString)")
                                .frame(width: 60, alignment: .leading) // Adjust the width as needed
                                .foregroundColor(.white)
                            
                            Button(action: {
                                audioPlayer.rewind()
                            }) {
                                Image(systemName: "gobackward.15")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            }
                            
                            Button(action: {
                                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
                            }) {
                                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            }
                            
                            Button(action: {
                                audioPlayer.forward()
                            }) {
                                Image(systemName: "goforward.15")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            }
                            
                            Text("\(audioPlayer.currentProgressString)")
                                .frame(width: 60, alignment: .trailing) // Adjust the width as needed
                                .foregroundColor(.white)
                        }
                    }
                    
                    let availableSpace = geometry.size.height - geometry.safeAreaInsets.bottom - geometry.size.width / 2
                    Spacer()
                        .frame(height: availableSpace / 2)
                    
                    Button(action: {
                        selectAudioOutput()
                    }) {
                        Image(systemName: "airplayaudio")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            currentImageSrc = imageSrc
            if let action = onAppearAction {
                action()
            }
        }
        .onDisappear {
            audioPlayer.pause()
        }
    }
}
