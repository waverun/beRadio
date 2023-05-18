//
//  String.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI

extension String {
    
    func timeStringToDouble() -> Double {
        let timeStr = self
        let timeParts = timeStr.split(separator: ":")
        var totalSeconds: Double = 0.0
        
        switch timeParts.count {
        case 1: // Format: ss
            guard let seconds = Double(timeParts[0]) else {
                print("Invalid time format. Please use 'ss', 'mm:ss', or 'hh:mm:ss' formats.")
                return -1.0
            }
            totalSeconds = seconds
        case 2: // Format: mm:ss
            guard let minutes = Double(timeParts[0]), let seconds = Double(timeParts[1]) else {
                print("Invalid time format. Please use 'ss', 'mm:ss', or 'hh:mm:ss' formats.")
                return -1.0
            }
            totalSeconds = minutes * 60 + seconds
        case 3: // Format: hh:mm:ss
            guard let hours = Double(timeParts[0]), let minutes = Double(timeParts[1]), let seconds = Double(timeParts[2]) else {
                print("Invalid time format. Please use 'ss', 'mm:ss', or 'hh:mm:ss' formats.")
                return -1.0
            }
            totalSeconds = hours * 3600 + minutes * 60 + seconds
        default:
            print("Invalid time format. Please use 'ss', 'mm:ss', or 'hh:mm:ss' formats.")
            return -1.0
        }
        
        return totalSeconds
    }
    
    func relativeColor() -> Color {
        switch self {
        case "Today" : return .green
        case "Yesterday" : return .orange
        default : return .gray
        }
    }
    
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    func extract(regexp regexPattern: String) -> String? {
        let inputString = self
        let regex = try! NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: inputString, range: NSRange(inputString.startIndex..., in: inputString))

        if let match = matches.first, let range = Range(match.range, in: inputString) {
            let string = String(inputString[range])
            return string
        }
        
        return nil
    }
    
    func openInSafari() {
        if let url = URL(string: self) {
                UIApplication.shared.open(url)
        }
    }
    
    func createEncodedURL() -> URL? {
        guard let encodedURLString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedURLString)
    }
}
