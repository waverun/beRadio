//import SwiftUI
////not used
//struct ColoredProgramButton: View {
//    var label: String
//    var link: String
//    var imageUrl: String
//    var action: (String) -> Void
//
//    @State private var buttonColor: Color = .gray
//
//    private func updateButtonColor() {
//        getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-"), search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
//            guard extractedLinks.count == 1 else {
//                return
//            }
//            getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0], search: #"(?<=href=")(/programs/complete_episodes\.aspx\?[^"]+)(?=">תוכניות מלאות</a>)"#) { extractedLink in
//                if extractedLink.count == 1 {
//                    getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLink[0]) { htmlContent in
//                        let programs = extractDatesAndLinks(html: htmlContent[0])
//                        if let firstProgram = programs.first,
//                           let dateStr = firstProgram.date.extract(regexp: "\\d{2}\\.\\d{2}\\.\\d{2}"),
//                           let date = dateStr.toDate(format: "dd.MM.yy") {
//
//                            let relativeDate = date.relativeDate()
//
//                            DispatchQueue.main.async {
//                                if relativeDate == "Today" {
//                                    buttonColor = .green
//                                } else if relativeDate == "Yesterday" {
//                                    buttonColor = .orange
//                                } else {
//                                    buttonColor = .gray
//                                }
//                            }
//                        }
//                        return
//                    }
//                }
//            }
//        }
//    }
//
//    var body: some View {
//        Button(action: {
//            action(link)
//        },
//        label: {
//            HStack {
//                AsyncImage(url: "https://103fm.maariv.co.il" + imageUrl)
//                    .frame(width: 60, height: 60) // Adjust the size as needed
//                Text(label)
//                    .foregroundColor(buttonColor)
//            }
//        })
//        .onAppear(perform: updateButtonColor)
//    }
//}
