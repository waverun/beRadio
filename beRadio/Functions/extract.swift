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
    var date: String
    let link: String
    let image: String
}

import Foundation

func extractDatesAndLinks(html: String) -> [ExtractedData] {
    let datePattern = "התוכנית המלאה \\d\\d\\.\\d\\d\\.\\d\\d"

    let dates = getDates(html: html, pattern: datePattern)
    
    let links = getLinks(html: html, pattern: #"(?<=<a href=")[^"]*(?=" id="mainPageSegmentsRpt_fullShowLink_\d+")"#)
    
    var images = extractLinks(htmlContent: html, search:  #"<img src="(?:https?://[^/]+)?(/download/programs/(FullShowImg_\d+_\d+_\d+_|imgNewTop_\d+)\.jpg)"#)
    
    if images.count == 0 {
        images = extractImages(html: html, search: #"(?<=https:\/\/103fm\.maariv\.co\.il)\/download\/programs\/imgNewTop_\d+\.jpg"#)
    }
    
    var result: [ExtractedData] = []

    for ((date, link), image) in zip(zip(dates, links), images) {
        result.append(ExtractedData(date: date, link: link, image: image))
    }

    return result
}

func getLinks(html: String, pattern: String) -> [String] {
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
                dates.append(String(matchedString))
            }
        }
    } catch {
        print("Invalid regex pattern")
    }
    return dates
}

func extractLinks(htmlContent: String, search: String, completion: (([String]) -> Void)? = nil) -> [String] {
    let pattern = search
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: htmlContent, options: [], range: NSRange(location: 0, length: htmlContent.utf16.count))
        
        var links: [String] = []
        
        for match in matches {
            if let range = (search.contains("program.aspx") ? Range(match.range, in: htmlContent) : Range(match.range(at: 1), in: htmlContent)) {
                let link = String(htmlContent[range])
                print("link:", link)
                links.append(link.replacingOccurrences(of: "-", with: " "))
            }
        }
        
        if let completion = completion {
            completion(links.unique())
        }
           
        return links
        
    } catch {
        print("Error creating regular expression: \(error)")
        if let completion = completion {
            completion([])
        }
    }
    return []
}

func extractImages(html: String, search: String) -> [String] {
    let pattern = search

    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: html, options: [], range: NSRange(html.startIndex..., in: html))

        var extractedImageURLs: [String] = []

        for match in matches {
            if let range = Range(match.range, in: html) {
                let url = String(html[range])
                extractedImageURLs.append(url)
            }
        }
        
        print(extractedImageURLs)
        return extractedImageURLs

    } catch {
        print("Error with regex: \(error)")
    }
    
    return []
}

func getHtmlContent(url: String, search: String? = nil, completion: @escaping ([String]) -> Void) {
    print("gethtmlContent: url: \(url)")
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
                    _ = extractLinks(htmlContent: htmlContent, search: search, completion: completion)
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
