//import UIKit
//
//extension UIColor: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        let ciColor = CIColor(color: self)
//        try container.encode(ciColor.red, forKey: .red)
//        try container.encode(ciColor.green, forKey: .green)
//        try container.encode(ciColor.blue, forKey: .blue)
//        try container.encode(ciColor.alpha, forKey: .alpha)
//    }
//
//    public convenience init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let red = try values.decode(CGFloat.self, forKey: .red)
//        let green = try values.decode(CGFloat.self, forKey: .green)
//        let blue = try values.decode(CGFloat.self, forKey: .blue)
//        let alpha = try values.decode(CGFloat.self, forKey: .alpha)
//        self.init(red: red, green: green, blue: blue, alpha: alpha)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case red, green, blue, alpha
//    }
//}
