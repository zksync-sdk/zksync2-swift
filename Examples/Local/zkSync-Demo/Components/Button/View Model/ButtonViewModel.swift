//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

public class ButtonViewModel {
    public var size: ButtonSize
    public var style: ButtonStyle
    public var fullWidth: Bool
    public var title: String? = nil
    public var leftImage: UIImage? = nil
    public var rightImage: UIImage? = nil
    public var isLoading: Bool
    public var action: () -> Void
    
    public init(size: ButtonSize = .normal, style: ButtonStyle, fullWidth: Bool = false, title: String? = nil, leftImage: UIImage? = nil, rightImage: UIImage? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.size = size
        self.style = style
        self.fullWidth = fullWidth
        self.title = title
        self.leftImage = leftImage
        self.rightImage = rightImage
        self.isLoading = isLoading
        self.action = action
    }
}
