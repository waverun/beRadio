import UIKit

func averageColor(of image: UIImage) -> UIColor {
    var bitmap = [UInt8](repeating: 0, count: 4)
    
    // Create a 1x1 pixel context
    let context = CGContext(data: &bitmap,
                            width: 1,
                            height: 1,
                            bitsPerComponent: 8,
                            bytesPerRow: 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    let red = CGFloat(bitmap[0]) / 255.0
    let green = CGFloat(bitmap[1]) / 255.0
    let blue = CGFloat(bitmap[2]) / 255.0
    let alpha = CGFloat(bitmap[3]) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

func getImageBrightness(of image : UIImage) -> CGFloat {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    let averageColor = averageColor(of: image)
    averageColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
    return brightness
}
//
//    func getImageBrightness(of : image: UIImage) -> CGFloat

func isDarkColor(of image : UIImage) -> Bool {
    return getImageBrightness(of: image) < 0.5
}

func avoidBlackBackground(of image: UIImage) -> Bool {
    return getImageBrightness(of: image) < 0.25
}
//}

