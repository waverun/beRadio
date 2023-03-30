//
//  Array.swift
//  beRadio
//
//  Created by Shay  on 30/03/2023.
//

import Foundation

extension Array where Element: Hashable {
    func unique () -> Array {
        return Array(Set(self))
    }
}
