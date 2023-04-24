import SwiftUI
import AVFoundation

var gAudioPlayerView: AudioPlayerView?

struct AudioPlayerView: View {
    
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
    
    let onAppearAction: (() -> Void)?
    
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
                                    .frame(width: 120, height: 120)
                                    .onChange(of: self.imageSrc) { newValue in
                                        currentImageSrc = newValue
                                        print("currentImageSrc: \(currentImageSrc ?? "no value")")
                                    }
                            }
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
                                    }
                                    
                                    Text("\(audioPlayer.currentProgressString)")
                                        .frame(width: 70, alignment: .leading)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
                                    }) {
                                        Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                    }
                                    
                                    Text("\(audioPlayer.totalDurationString)")
                                        .frame(width: 70, alignment: .trailing)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        audioPlayer.forward(by: 15)
                                    }) {
                                        Image(systemName: "goforward.15")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                        }
                        Slider(value: $currentProgress,
                               in: 0...$audioPlayer.totalDurationString.wrappedValue.timeStringToDouble(),
                               onEditingChanged: { isEditing in
                            audioPlayer.seekToNewTime(currentProgress.toCMTime())
                        })
                        .padding(.horizontal)
                        .onChange(of: audioPlayer.currentProgressString.timeStringToDouble()) { newValue in
                            currentProgress = newValue
                        }
                    }
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
            gAudioPlayerView = nil
            audioPlayer.pause()
            audioPlayer.removePlayer()
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
