//
//  Created by Bojan on 14.5.23..
//

import SwiftUI

class ButtonViewBuilder {
    @ViewBuilder
    static func button(viewModel: ButtonViewModel) -> some View {
        Button(action: viewModel.action, label: {
            ZStack {
                HStack(spacing: viewModel.size.padding) {
                    if let leftImage = viewModel.leftImage {
                        SwiftUI.Image(uiImage: leftImage)
                            .resizable()
                            .frame(width: viewModel.size.imageSize, height: viewModel.size.imageSize)
                    }
                    if let title = viewModel.title {
                        Text(title)
                            .font(Font.headline)
                    }
                    if let rightImage = viewModel.rightImage {
                        SwiftUI.Image(uiImage: rightImage)
                            .resizable()
                            .frame(width: viewModel.size.imageSize, height: viewModel.size.imageSize)
                    }
                }
                .isHidden(viewModel.isLoading)
                
                LoadingView(isLoading: .constant(viewModel.isLoading), color: viewModel.style.foreground, size: DefaultActivityIndicatorView.Size.medium)
                    .frame(maxHeight: 30)
                    .isHidden(!viewModel.isLoading)
            }
            .frame(minWidth: viewModel.size.imageSize, minHeight: viewModel.size.imageSize)
            .if(viewModel.fullWidth, transform: { view in
                view
                    .frame(maxWidth: .infinity)
            })
                .padding(.horizontal, viewModel.size.padding + (viewModel.title != nil ? viewModel.size.textHorizontalPadding : 0))
                .padding(.vertical, viewModel.size.padding)
        })
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .allowsHitTesting(!viewModel.isLoading)
    }
}
