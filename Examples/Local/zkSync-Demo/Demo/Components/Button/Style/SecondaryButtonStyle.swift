//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

public struct SecondaryButtonStyle: SwiftUI.ButtonStyle {
    public static let primary: ButtonStyle = .init(background: UIColor(named: "4e529a")!, foreground: UIColor.white)
    
    @SwiftUI.Environment(\.isEnabled) var isEnabled
    
    public var style: ButtonStyle
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    if configuration.isPressed {
                        Color(style.background).opacity(0.12)
                    }
                }
            )
            .foregroundColor(
                Color(isEnabled ? style.foreground : UIColor.gray.withAlphaComponent(0.4))
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color(isEnabled ? style.background : UIColor.gray.withAlphaComponent(0.12)), lineWidth: 2)
            )
            .contentShape(Capsule())
    }
}
