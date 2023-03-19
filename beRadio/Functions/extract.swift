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

func getHtmlContent(url: String, search: String, completion: @escaping ([String]) -> Void) {
    guard let url = URL(string: url) else {
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
                extractLinks(htmlContent: htmlContent, search: search, completion: completion)
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
