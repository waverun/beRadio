//
//  String.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI

extension String {
    
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
