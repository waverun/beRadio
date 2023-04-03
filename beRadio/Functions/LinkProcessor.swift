class LinkProcessor {
    static func getRelativeDate(_ date: String) -> String {
        if let dateStr = date.extract(regexp: "\\d{2}\\.\\d{2}\\.\\d{2}"),
           let date = dateStr.toDate(format: "dd.MM.yy") {
           return date.relativeDate()
        }
        return ""
    }
    
    static func processLink(_ link: String, completion: @escaping (String, [ExtractedData]) -> Void) {
        var title = ""
        var programs: [ExtractedData] = []
        
        // Add your logic here to process the link and return the desired output
        title = link.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")
        
        getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-"), search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
            guard extractedLinks.count == 1 else {
                print("\(extractedLinks.count) extracted. Should be only 1")
                return
            }
            
            getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0], search: #"(?<=href=")(/programs/complete_episodes\.aspx\?[^"]+)(?=">תוכניות מלאות</a>)"#) { extractedLink in
                if extractedLink.count == 1 {
                    getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLink[0]) { htmlContent in
                        programs = extractDatesAndLinks(html: htmlContent[0])
                        programs = programs.map { program -> ExtractedData in
                            var updatedProgram = program
                            updatedProgram.date = getRelativeDate(program.date)
                            return updatedProgram
                        }
                        completion(title, programs)
                        return
                    }
                }
            }
        }
    }
}
