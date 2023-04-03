//
//  String.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI

extension String {
    
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    func extract(regexp regexPattern: String) -> String? {
        // Extract numbers from the string using a regular expression
//        let regexPattern = "\\d{2}\\.\\d{2}\\.\\d{2}"
        let inputString = self
        let regex = try! NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: inputString, range: NSRange(inputString.startIndex..., in: inputString))

        if let match = matches.first, let range = Range(match.range, in: inputString) {
            let string = String(inputString[range])
            return string
        }
        
        return nil
//            if let date = dateFormatter.date(from: dateString) {
//                print("Extracted date: \(date)")
//            } else {
//                print("Failed to parse date from string")
//            }
//        } else {
//            print("Failed to find date in string")
//        }
    }
    
    func openInSafari() {
        if let url = URL(string: self) {
//            DispatchQueue.main.async {
    //            url.play()
                UIApplication.shared.open(url)
//            }
        }
    }
    
    func createEncodedURL() -> URL? {
        guard let encodedURLString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedURLString)
    }
}
