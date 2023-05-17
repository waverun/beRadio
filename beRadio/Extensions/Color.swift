import SwiftUI

extension Color {
    static let adaptiveWhite = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })
}
