//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

public struct TertiaryButton: View {
    public var viewModel: ButtonViewModel
    
    public init(viewModel: ButtonViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ButtonViewBuilder.button(viewModel: viewModel)
            .buttonStyle(TertiaryButtonStyle(style: viewModel.style))
    }
}
