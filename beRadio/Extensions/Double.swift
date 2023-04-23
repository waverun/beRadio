//
//  Double.swift
//  beRadio
//
//  Created by Shay  on 23/04/2023.
//

import AVFoundation

extension Double {
    func toCMTime() -> CMTime {
        let timeAsCMTime = CMTimeMakeWithSeconds(self, preferredTimescale: Int32(NSEC_PER_SEC))
        return timeAsCMTime
    }
}
