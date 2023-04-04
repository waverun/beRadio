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

    let link: String
    
//    func processLink(_ link: String) -> String {
//        // Add your logic here to process the link and return the desired output
//        print("processLink: link: \(link)")
//        title = link.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
//        getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-"), search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
//            //            DispatchQueue.main.async {
//            //                links = extractedLinks
//            //            }
//            guard extractedLinks.count == 1 else {
//                print("process link extracteLinks: \(extractedLinks)")
//                print("\(extractedLinks.count) extracted. Should be only 1")
//                return
//            }
//            print("processLink: url: \("https://103fm.maariv.co.il" + extractedLinks[0])")
//            getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0], search: #"(?<=href=")(/programs/complete_episodes\.aspx\?[^"]+)(?=">תוכניות מלאות</a>)"#) { extractedLink in
//                if extractedLink.count == 1 {
//                    getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLink[0]) { htmlContent in
//                        programs = extractDatesAndLinks(html: htmlContent[0])
//                        return
//                    }
//                }
//                print("getHtmlContent: searching for the link to full episodes gave: \(extractedLink)")
//            }
//        }
//        return "Processed Link: \(link)"
//    }
    
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
                List {
                    ForEach (programs) { program in
//                        if let dateStr = program.date.extract(regexp: "\\d{2}\\.\\d{2}\\.\\d{2}"),
//                           let date = dateStr.toDate(format: "dd.MM.yy") {
                        ProgramButton(label: program.date, link: program.link, imageUrl: program.image) { link in
                            if URL(string: "https://103fm.maariv.co.il" + link) != nil {
//                                    UIApplication.shared.open(url)
//                                    selectedURL = url
//                                    showSafariView = true
                                    didSelectURL(link)
                                }
                            }
                            .font(.title)
                            .foregroundColor(program.date.relativeColor())
//                        }
                    }
                    .onDelete(perform: deleteProgram)
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