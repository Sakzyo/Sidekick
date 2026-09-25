import SwiftUI

enum InterfaceStyle {
    /// The chat composer's corner radius, shared by larger UI surfaces.
    static let cornerRadius: CGFloat = 22

    /// Smaller controls need less rounding to visually match the composer.
    static let chatButtonCornerRadius: CGFloat = 8

    static var roundedRectangle: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    static var chatButtonShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: chatButtonCornerRadius, style: .continuous)
    }
}
