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
    var action: (String) -> Void

    var body: some View {
        Button(action: {
            action(link)
        }, label: {
            Text(label)
        })
    }
}

struct fullProgramsView: View {
    @State private var programs: [ExtractedData] = []
    @State private var title = ""

    let link: String
    
    func processLink(_ link: String) -> String {
        // Add your logic here to process the link and return the desired output
        print("processLink: link: \(link)")
        title = link.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
        getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-"), search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
            //            DispatchQueue.main.async {
            //                links = extractedLinks
            //            }
            guard extractedLinks.count == 1 else {
                print("process link extracteLinks: \(extractedLinks)")
                print("\(extractedLinks.count) extracted. Should be only 1")
                return
            }
            print("processLink: url: \("https://103fm.maariv.co.il" + extractedLinks[0])")
            getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0], search: #"(?<=href=")(/programs/complete_episodes\.aspx\?[^"]+)(?=">תוכניות מלאות</a>)"#) { extractedLink in
                if extractedLink.count == 1 {
                    getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLink[0]) { htmlContent in
                        programs = extractDatesAndLinks(html: htmlContent[0])
                        return
                    }
                }
                print("getHtmlContent: searching for the link to full episodes gave: \(extractedLink)")
            }
        }
        return "Processed Link: \(link)"
    }
    
    var body: some View {
        //        Text(processLink(link))
        VStack {
            if programs.isEmpty {
                Text("Loading...").onAppear {
                    _ = processLink(link)
                }
            } else {
                List {
                    ForEach (programs) { program in
                        ProgramButton(label: program.date, link: program.link) { link in
                            if let url = URL(string: "https://103fm.maariv.co.il" + link) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.title)
                        .foregroundColor(.blue)
                    }
                    .onDelete(perform: deleteProgram)
                }
                .toolbar {
    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
    #endif
                    ToolbarItem {
                        Button(action: addProgram) {
                            Label("Add program", systemImage: "plus")
                        }
                    }
                }
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
    
    private func deleteProgram(at offsets: IndexSet) {
        programs.remove(atOffsets: offsets)
    }
    
    private func addProgram() {
        // Create a new Program instance and add it to the programs array
        let newProgram = ExtractedData(date: "New Date", link: "New Link")
        programs.append(newProgram)
    }

}
