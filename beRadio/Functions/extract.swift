//
//  extract.swift
//  beRadio
//
//  Created by Shay  on 16/03/2023.
//

import Foundation
import Foundation
import SwiftSoup
import SwiftUI

import Foundation

struct ExtractedData: Identifiable {
    let id = UUID()
    let date: String
    let link: String
}

import Foundation

//func extractDatesAndLinks(html: String) -> [ExtractedData] {
//    let dateStart = "<div class=\"segment_date_txt\">"
//    let dateEnd = "</div>"
//    let linkStart = "<a href=\""
//    let linkEnd = "\">"
//
//    var dates: [String] = []
//    var links: [String] = []
//
//    var searchStartIndex = html.startIndex
//
//    while let dateRangeStart = html.range(of: dateStart, options: [], range: searchStartIndex..<html.endIndex) {
//        if let dateRangeEnd = html.range(of: dateEnd, options: [], range: dateRangeStart.upperBound..<html.endIndex) {
//            let date = String(html[dateRangeStart.upperBound..<dateRangeEnd.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
//            dates.append(date)
//            searchStartIndex = dateRangeEnd.upperBound
//        } else {
//            break
//        }
//    }
//
//    searchStartIndex = html.startIndex
//
//    while let linkRangeStart = html.range(of: linkStart, options: [], range: searchStartIndex..<html.endIndex) {
//        if let linkRangeEnd = html.range(of: linkEnd, options: [], range: linkRangeStart.upperBound..<html.endIndex) {
//            let link = String(html[linkRangeStart.upperBound..<linkRangeEnd.lowerBound])
//            links.append(link)
//            searchStartIndex = linkRangeEnd.upperBound
//        } else {
//            break
//        }
//    }
//
//    var result: [ExtractedData] = []
//
//    if dates.count == links.count {
//        for (date, link) in zip(dates, links) {
//            result.append(ExtractedData(date: date, link: link))
//        }
//    }
//
//    return result
//}

func extractDatesAndLinks(html: String) -> [ExtractedData] {
//    let datePattern = "<div class=\"segment_date_txt\">\\s*(\\d{2}/\\d{2}/\\d{4})\\s*</div>"
    let datePattern = "התוכנית המלאה \\d\\d\\.\\d\\d\\.\\d\\d"
//    let linkPattern = "<a href=\"(/programs/media\\.aspx\\?[^\"]+)\""

//    let dateRegex = try? NSRegularExpression(pattern: datePattern, options: [])
//    let linkRegex = try? NSRegularExpression(pattern: linkPattern, options: [])

//    let dates = dateRegex?.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html)).compactMap { result -> String? in
//            guard let range = Range(result.range(at: 1), in: html) else { return nil }
//            return String(html[range])
//        }
//    let dates = dateRegex?.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html)).map { result -> String in
//        let range = Range(result.range(at: 1), in: html)!
//        return String(html[range])
//    }

    let dates = getDates(html: html, pattern: datePattern)
    
//    let links = linkRegex?.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html)).map { result -> String in
//        let range = Range(result.range(at: 1), in: html)!
//        return String(html[range])
//    }

    let links = getLinks(html: html, pattern: #"(?<=<a href=")[^"]*(?=" id="mainPageSegmentsRpt_fullShowLink_\d+")"#)
    var result: [ExtractedData] = []

//    if let links = links {
        for (date, link) in zip(dates, links) {
            result.append(ExtractedData(date: date, link: link))
            print("Found: " + date + link)
//        }
    }

    print(result[0])

    return result
}

func getLinks(html: String, pattern: String) -> [String] {
//    let pattern = #"(?<=<a href=")[^"]*(?=" id="mainPageSegmentsRpt_fullShowLink_\d+">)"#
    let regex = try! NSRegularExpression(pattern: pattern, options: [])

    let matches = regex.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html))

    var links: [String] = []
    
    matches.forEach { match in
        let range = match.range(at: 0)
        if let swiftRange = Range(range, in: html) {
            let link = html[swiftRange]
            print(link)
            links.append(String(link))
        }
    }
    return links
}

func getDates(html: String, pattern: String) -> [String] {
    var dates: [String] = []
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        
        for match in matches {
            let range = match.range
            if let swiftRange = Range(range, in: html) {
                let matchedString = html[swiftRange]
//                print("Found: \(matchedString)")
                dates.append(String(matchedString))
            }
        }
    } catch {
        print("Invalid regex pattern")
    }
    return dates
}
func extractLinks(htmlContent: String, search: String, completion: @escaping ([String]) -> Void) {
    let pattern = search
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: htmlContent.utf16.count))
        
        var links: [String] = []
        
        for match in matches {
            if let range = Range(match.range(at: 1), in: htmlContent) {
                let link = String(htmlContent[range])
                links.append(link.replacingOccurrences(of: "-", with: " "))
            }
        }
        
        completion(links)
    } catch {
        print("Error creating regular expression: \(error)")
        completion([])
    }
}

func getHtmlContent(url: String, search: String? = nil, completion: @escaping ([String]) -> Void) {
    print("gethtmlContent: url: \(url)")
//    guard let url = URL(string: url) else {
    guard let url = url.createEncodedURL() else {
        print("Invalid URL")
        completion([])
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching the web page: \(error)")
            completion([])
        } else if let data = data {
            if let htmlContent = String(data: data, encoding: .utf8) {
                if let search = search {
                    extractLinks(htmlContent: htmlContent, search: search, completion: completion)
                    return
                }
                completion([htmlContent])
            } else {
                print("Failed to decode the data as UTF-8")
                completion([])
            }
        }
    }

    task.resume()
}

//func getHtmlContent(url: String, completion: @escaping (String?) -> Void) {
//    guard let url = URL(string: url) else {
//        print("Invalid URL")
//        completion(nil)
//        return
//    }
//
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        if let error = error {
//            print("Error fetching the web page: \(error)")
//            completion(nil)
//        } else if let data = data {
//            if let htmlContent = String(data: data, encoding: .utf8) {
//                completion(htmlContent)
//            } else {
//                print("Failed to decode the data as UTF-8")
//                completion(nil)
//            }
//        }
//    }
//
//    task.resume()
//}
//
//func extractLinks(htmlContent: String, completion: @escaping ([String]) -> Void) {
//    let pattern = "href=\"(/program/[^\"]+\\.aspx)\""
//
//    do {
//        let regex = try NSRegularExpression(pattern: pattern, options: [])
//        let matches = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: htmlContent.utf16.count))
//
//        var links: [String] = []
//
//        for match in matches {
//            if let range = Range(match.range(at: 1), in: htmlContent) {
//                let link = String(htmlContent[range])
//                links.append(link.replacingOccurrences(of: "-", with: " "))
//            }
//        }
//
//        completion(links)
//    } catch {
//        print("Error creating regular expression: \(error)")
//        completion([])
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

//func get103() -> String {
//
//    // Define the URL of the web page
//    guard let url = URL(string: "https://103fm.maariv.co.il/programs/") else {
//        print("Invalid URL")
//        return "Invalid URL"
//    }
//
//    // Create a URLSessionDataTask to fetch the web page content
//    let task = URLSession.shared.dataTask(with: url) { data, response, error in
//        // Check for errors
//        if let error = error {
//            return("Error fetching the web page: \(error)")
//        } else if let data = data {
//            // Convert the received data to a String with UTF-8 encoding
//            if let htmlContent = String(data: data, encoding: .utf8) {
//                print("HTML content of the web page:")
//                return(htmlContent)
//            } else {
//                return("Failed to decode the data as UTF-8")
//            }
//        }
//    }
//
//    // Start the task
//    task.resume()
//
//    let html = """
//    <li class="footer_link_item w-clearfix">
//        <a class="footer_link" href="/program/גדעון-אוקו-תוכנית-רדיו.aspx" target="_self">
//    </li>
//    """
//    var url : URL!
//    do {
//        let doc = try SwiftSoup.parse(html)
//        if let linkElement = try doc.select("a.footer_link").first(),
//           let link = try? linkElement.attr("href") {
//
//            let baseURL = "https://103fm.maariv.co.il/programs"  // Replace with the base URL of the website
//            url = URL(string: baseURL + link)
//
//            // Open the URL in the default web browser
//            if let url = url {
//                UIApplication.shared.open(url)
//                print("link \(url.absoluteString)")
//            }
//        }
//    } catch {
//        print("Error parsing HTML: \(error)")
//    }
//
//    return ""
//}
