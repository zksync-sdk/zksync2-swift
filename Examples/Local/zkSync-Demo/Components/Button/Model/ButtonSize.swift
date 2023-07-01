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
        case .small: return 8
        }
    }
    
    var imageSize: CGFloat {
        switch self {
        case .normal: return 24
        case .small: return 24
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .normal: return 8
        case .small: return 8
        }
    }
}
