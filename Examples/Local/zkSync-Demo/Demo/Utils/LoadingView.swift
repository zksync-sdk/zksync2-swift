//
//  Created by Bojan on 14.6.23..
//

import SwiftUI

struct LoadingView: UIViewRepresentable {
    @Binding var isLoading: Bool
    
    var color: UIColor?
    var size: DefaultActivityIndicatorView.Size?
    
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        return v
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        if isLoading {
            view.showLoading(color ?? DefaultActivityIndicatorView.color, size ?? DefaultActivityIndicatorView.Size.extraLarge)
        } else {
            view.hideLoading()
        }
    }
}
