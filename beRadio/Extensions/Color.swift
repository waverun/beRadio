import SwiftUI

extension Color {
    static let adaptiveWhite = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })

    static let adaptiveBlack = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    })

    func toUIColor() -> UIColor {
        if let cgColor = cgColor,
           let components = self.cgColor!.components,
           components.count > 3 {
            return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        }
        return .gray
    }
}
