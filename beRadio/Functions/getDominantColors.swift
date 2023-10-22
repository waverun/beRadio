import UIKit
import SwiftUI

func getDominantColors(in image: UIImage, k: Int = 2, maxIterations: Int = 100) -> [Color]? {
    // Safeguard 1: Check if k is valid
    switch k {
        case 1...Int.max: break // k is valid
        default: return nil
    }

    // Safeguard 2: Check for valid cgImage
    guard let cgImage = image.cgImage else {
        print("Invalid CGImage.")
        return nil
    }

    let width = cgImage.width
    let height = cgImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var rawData = [UInt8](repeating: 0, count: width * height * 4)
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

    // Safeguard 3: Create context
    guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Could not create CGContext.")
        return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    var colorSum = [[CGFloat]](repeating: [0, 0, 0], count: k)
    var clusterCount = [Int](repeating: 0, count: k)
    var previousCentroids = [[CGFloat]]()
    var centroids = [[CGFloat]](repeating: [CGFloat.random(in: 0...1), CGFloat.random(in: 0...1), CGFloat.random(in: 0...1)], count: k)

    var iteration = 0
    while previousCentroids != centroids {
        // Safeguard 4: Check for maximum iterations
        if iteration >= maxIterations {
            print("Max iterations reached, exiting.")
            break
        }

        iteration += 1
        previousCentroids = centroids
        centroids = [[CGFloat]](repeating: [0, 0, 0], count: k)
        colorSum = [[CGFloat]](repeating: [0, 0, 0], count: k)
        clusterCount = [Int](repeating: 0, count: k)

        for y in 0..<height {
            for x in 0..<width {
                let byteIndex = (bytesPerRow * Int(y)) + Int(x) * bytesPerPixel
                let red = CGFloat(rawData[byteIndex]) / 255
                let green = CGFloat(rawData[byteIndex + 1]) / 255
                let blue = CGFloat(rawData[byteIndex + 2]) / 255

                var bestCentroidIndex = 0
                var bestDistance = CGFloat.infinity
                for (index, centroid) in centroids.enumerated() {
                    let distance = pow(red - centroid[0], 2) + pow(green - centroid[1], 2) + pow(blue - centroid[2], 2)
                    if distance < bestDistance {
                        bestDistance = distance
                        bestCentroidIndex = index
                    }
                }
                colorSum[bestCentroidIndex][0] += red
                colorSum[bestCentroidIndex][1] += green
                colorSum[bestCentroidIndex][2] += blue
                clusterCount[bestCentroidIndex] += 1
            }
        }

        for (index, count) in clusterCount.enumerated() {
            // Safeguard 5: Handle empty clusters by reinitializing
            if count == 0 {
                centroids[index] = [CGFloat.random(in: 0...1), CGFloat.random(in: 0...1), CGFloat.random(in: 0...1)]
                continue
            }

            centroids[index] = [colorSum[index][0] / CGFloat(count), colorSum[index][1] / CGFloat(count), colorSum[index][2] / CGFloat(count)]
        }
    }

    return centroids.map { Color(UIColor(red: $0[0], green: $0[1], blue: $0[2], alpha: 1)) }
}

//func getDominantColors(in image: UIImage, k: Int = 2) -> [Color]? {
//    guard let cgImage = image.cgImage else { return nil }
//
//    let width = cgImage.width
//    let height = cgImage.height
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    var rawData = [UInt8](repeating: 0, count: width * height * 4)
//    let bytesPerPixel = 4
//    let bytesPerRow = bytesPerPixel * width
//    let bitsPerComponent = 8
//    let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
//
//    guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
//
//    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//    var colorSum = [[CGFloat]](repeating: [0, 0, 0], count: k)
//    var clusterCount = [Int](repeating: 0, count: k)
//    var previousCentroids = [[CGFloat]]()
//    var centroids = [[CGFloat]](repeating: [CGFloat.random(in: 0...1), CGFloat.random(in: 0...1), CGFloat.random(in: 0...1)], count: k)
//
//    while previousCentroids != centroids {
//        previousCentroids = centroids
//        centroids = [[CGFloat]](repeating: [0, 0, 0], count: k)
//        colorSum = [[CGFloat]](repeating: [0, 0, 0], count: k)
//        clusterCount = [Int](repeating: 0, count: k)
//
//        for y in 0..<height {
//            for x in 0..<width {
//                let byteIndex = (bytesPerRow * y) + x * bytesPerPixel
//                let red = CGFloat(rawData[byteIndex]) / 255
//                let green = CGFloat(rawData[byteIndex + 1]) / 255
//                let blue = CGFloat(rawData[byteIndex + 2]) / 255
//
//                var bestCentroidIndex = 0
//                var bestDistance = CGFloat.infinity
//                for (index, centroid) in centroids.enumerated() {
//                    let distance = pow(red - centroid[0], 2) + pow(green - centroid[1], 2) + pow(blue - centroid[2], 2)
//                    if distance < bestDistance {
//                        bestDistance = distance
//                        bestCentroidIndex = index
//                    }
//                }
//                colorSum[bestCentroidIndex][0] += red
//                colorSum[bestCentroidIndex][1] += green
//                colorSum[bestCentroidIndex][2] += blue
//                clusterCount[bestCentroidIndex] += 1
//            }
//        }
//
//        for (index, count) in clusterCount.enumerated() {
//            if count > 0 {
//                centroids[index] = [colorSum[index][0] / CGFloat(count), colorSum[index][1] / CGFloat(count), colorSum[index][2] / CGFloat(count)]
//            }
//        }
//    }
//
//    return centroids.map { Color(UIColor(red: $0[0], green: $0[1], blue: $0[2], alpha: 1)) }
//}
