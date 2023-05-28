import SwiftUI

extension Color {
    static let adaptiveWhite = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })

    static let adaptiveBlack = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    })
}
