import Foundation
class LinkProcessor {
//    static func getRelativeDate(_ date: String) -> String {
//        if let dateStr = date.extract(regexp: "\\d{2}\\.\\d{2}\\.\\d{2}"),
//           let date = dateStr.toDate(format: "dd.MM.yy") {
//            return date.relativeDate()
//        }
//        return "unknown"
//    }

    static func getRelativeDate(_ date: String) -> String {
        if let dateStr = date.extract(regexp: "\\d{1,2}\\.\\d{1,2}\\.\\d{2}"),
           let date = dateStr.toDate(format: "d.M.yy") {
            return date.relativeDate()
        }
        return "Unknown date"
    }

    static func getPodcastDate(_ date: String) -> String {
        if let dateStr = date.extract(regexp: "(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/(19\\d\\d|20\\d\\d)$"),
           let date = dateStr.toDate(format: "dd/MM/yyyy") {
            return date.relativeDate()
        }
        return "unknown"
    }

    static func processLink(_ link: String, completion: @escaping (String, [ExtractedData]) -> Void) {
        var title = ""
        var programs: [ExtractedData] = []

        // Add your logic here to process the link and return the desired output
        title = link.replacingOccurrences(of: "/program/", with: "").replacingOccurrences(of: ".aspx", with: "")


        getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-")) { htmlContent in
            let radioProgram = "תוכנית רדיו -"
            let morningProgram = "תוכנית בוקר ="
            let progremInTitlePattern = #"href="([^"]+)">תוכניות מלאות</a>"#

            guard htmlContent.count > 0 else { return }
            let htmlContent = htmlContent[0]

            let regex = try! NSRegularExpression(pattern: progremInTitlePattern)

            let range = NSRange(location: 0, length: htmlContent.utf16.count)
            let matches = regex.matches(in: htmlContent, options: [], range: range)

            if matches.isEmpty || htmlContent.contains("<title>ורדה רזיאל ז'קונט - תוכנית רדיו | 103fm</title>") || htmlContent.contains("<title>הרב אפרים בן צבי - תוכנית רדיו | 103fm</title>") || htmlContent.contains("<title>הכול פתוח - תוכנית רדיו עם אמנון רגב | 103fm</title>") {
                //            if !(htmlContent.contains(radioProgram) || htmlContent.contains(morningProgram)) {
                getPodcasts(htmlContent: htmlContent) { programs in
                    completion(title, programs)
                }
                return
            }

//            getHtmlContent(url: "https://103fm.maariv.co.il" + link.replacingOccurrences(of: " ", with: "-"), search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
            _ = extractLinks(htmlContent: htmlContent, search: #"href="([^"]+)">תוכניות מלאות</a>"#) { extractedLinks in
                guard extractedLinks.count == 1 else {
                    print("\(extractedLinks.count) extracted. Should be only 1")
                    return
                }

//                getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0], search: #"(?<=href=")(/programs/complete_episodes\.aspx\?[^"]+)(?=">תוכניות מלאות</a>)"#) { extractedLink in
//                    if extractedLink.count == 1 {
                        getHtmlContent(url: "https://103fm.maariv.co.il" + extractedLinks[0].replacingOccurrences(of: " ", with: "-")) { htmlContent in
                            guard htmlContent.count > 0 else { return }
                            programs = extractDatesAndLinks(html: htmlContent[0])
                            programs = programs.map { program -> ExtractedData in
                                var updatedProgram = program
                                updatedProgram.date = getRelativeDate(program.date)
                                return updatedProgram
                            }
                            completion(title, programs)
                            return
//                        }
//                    }
                }
            }
        }
    }

    static func getPodcasts(htmlContent: String, completion: @escaping ([ExtractedData]) -> Void) {
        var programs = extractPodcastLinks(html: htmlContent)
        programs = programs.map { program -> ExtractedData in
            var updatedProgram = program
            updatedProgram.date = getPodcastDate(program.date)
            return updatedProgram
        }
        completion(programs)
    }
}
