//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

public enum ButtonSize {
    case normal
    case small
    
    var textHorizontalPadding: CGFloat {
        switch self {
        case .normal: return 10
        case .small: return 5
        }
    }
    
    var font: Font {
        switch self {
        case .normal: return Font.headline
        case .small: return Font.footnote
        }
    }
    
    var imageSize: CGFloat {
        switch self {
        case .normal: return 24
        case .small: return 18
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .normal: return 8
        case .small: return 3
        }
    }
    
    var interitemSpacing: CGFloat {
        switch self {
        case .normal: return 8
        case .small: return 8
        }
    }
}
