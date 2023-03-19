//
//  Full programs view.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI

struct fullProgramsView: View {
    let link: String
    
    func processLink(_ link: String) -> String {
        // Add your logic here to process the link and return the desired output
        return "Processed Link: \(link)"
    }
    
    var body: some View {
        Text(processLink(link))
    }
}
