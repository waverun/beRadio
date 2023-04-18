//
//  Full programs view.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI
import CoreData

struct ProgramButton: View {

    var label: String
    var link: String
    var imageUrl: String?
    var action: (String) -> Void
    var color : UIColor = .gray

    var body: some View {
           Button(action: {
               action(link)
           },
           label: {
               HStack {
                   if let imageUrl = imageUrl {
                       AsyncImage(url: "https://103fm.maariv.co.il" + imageUrl)
                           .frame(width: 60, height: 60) // Adjust the size as needed
                   }
                   Text(label)
               }
           })
       }
}

struct fullProgramsView: View {
    @State private var showSafariView: Bool = false
    @State private var selectedURL: URL?
    
    @State private var programs: [ExtractedData] = []
    @State private var title = ""
    
    @State private var showAudioPlayerView: Bool = false
    static private var selectedAudioUrl: URL?
    static private var selectedAudioImage: String?
    static private var selectedAudioDate: String?

    private static let audioPlayer = AudioPlayer(isLive: false)

    let link: String
    
    var body: some View {
        VStack {
            if programs.isEmpty {
                Text("Loading...").onAppear {
                    LinkProcessor.processLink(link) { (processedTitle, extractedPrograms) in
                        title = processedTitle
                        programs = extractedPrograms
                    }
                }
            } else {
                List {
                    ForEach (programs) { program in
                            ProgramButton(label: program.date, link: "https://103fm.maariv.co.il" + program.link, imageUrl: program.image) { link in
                                fetchAudioUrl(link: link) { url in
                                    fullProgramsView.selectedAudioUrl = url
                                    fullProgramsView.selectedAudioImage = program.image
                                    fullProgramsView.selectedAudioDate = program.date
                                    //                                DispatchQueue.main.async {
                                    showAudioPlayerView.toggle()
                                }
                            }
                            .font(.title)
                            .foregroundColor(program.date.relativeColor())
                    }
                    .onDelete(perform: deleteProgram)
                }
                .sheet(isPresented: $showAudioPlayerView) {
                    if let url = fullProgramsView.selectedAudioUrl,
                       let image = "https://103fm.maariv.co.il" + (fullProgramsView.selectedAudioImage ?? ""),
                       let date = title + "\n" + (fullProgramsView.selectedAudioDate ?? "") {
                        AudioPlayerView(url: url, image: image, date: date, isLive: false)
                    } else {
                        Text("No URL selected")
                    }
                }
                .sheet(isPresented: $showSafariView) {
                    if let url = selectedURL {
                        SafariView(url: url)
                    } else {
                        Text("No URL selected")
                    }
                }
                .onChange(of: selectedURL) { newValue in
                    showSafariView = newValue != nil
                }
                .toolbar {
    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
    #endif
                }
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
    
    private func deleteProgram(at offsets: IndexSet) {
        programs.remove(atOffsets: offsets)
    }
    
    func didSelectURL(_ link: String) {
        if let url = URL(string: "https://103fm.maariv.co.il" + link) {
            DispatchQueue.main.async {
                selectedURL = url
                showSafariView = true
            }
        }
    }
}
