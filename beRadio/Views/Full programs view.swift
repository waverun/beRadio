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
    var imageUrl: String
    var action: (String) -> Void
    var color : UIColor = .gray

    var body: some View {
           Button(action: {
               action(link)
           },
           label: {
               HStack {
                   AsyncImage(url: "https://103fm.maariv.co.il" + imageUrl)
                       .frame(width: 60, height: 60) // Adjust the size as needed
                   Text(label)
               }
           })
       }
//    var body: some View {
//        Button(action: {
//            action(link)
//        },
//        label: {
//            Text(label)
//        })
//    }
}

struct fullProgramsView: View {
    @State private var showSafariView: Bool = false
    @State private var selectedURL: URL?
    
    @State private var programs: [ExtractedData] = []
    @State private var title = ""
    
    @State private var showAudioPlayerView: Bool = false
    static private var selectedAudioUrl: URL?

    private static let audioPlayer = AudioPlayer()

    let link: String
    
    var body: some View {
        //        Text(processLink(link))
        VStack {
            if programs.isEmpty {
                Text("Loading...").onAppear {
//                    _ = processLink(link)
                    LinkProcessor.processLink(link) { (processedTitle, extractedPrograms) in
                        title = processedTitle
                        programs = extractedPrograms
                    }
                }
            } else {
//                List {
//                    ForEach (programs) { program in
//                        if URL(string: "https://103fm.maariv.co.il" + program.link) != nil {
//                            NavigationLink(destination: AudioPlayerView(url: URL(string: "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3")!)) {
//                                ProgramButton(label: program.date, link: program.link, imageUrl: program.image) { link in }
//                                    .font(.title)
//                                    .foregroundColor(program.date.relativeColor())
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteProgram)
//                }
                List {
                    ForEach (programs) { program in
                        if URL(string: "https://103fm.maariv.co.il" + program.link) != nil {
                            // Update the ProgramButton's action to toggle the sheet's visibility
                            ProgramButton(label: program.date, link: program.link, imageUrl: program.image) { link in
                                fullProgramsView.selectedAudioUrl = URL(string: "https://awaod01.streamgates.net/103fm_aw/mag0404238.mp3")
//                                DispatchQueue.main.async {
                                    showAudioPlayerView.toggle()
//                                }
                            }
                            .font(.title)
                            .foregroundColor(program.date.relativeColor())
                        }
                    }
                    .onDelete(perform: deleteProgram)
                }
                // Present the AudioPlayerView using a sheet
                .sheet(isPresented: $showAudioPlayerView) {
                    if let url = fullProgramsView.selectedAudioUrl {
                        AudioPlayerView(url: url)
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
//                    ToolbarItem {
//                        Button(action: addProgram) {
//                            Label("Add program", systemImage: "plus")
//                        }
//                    }
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
