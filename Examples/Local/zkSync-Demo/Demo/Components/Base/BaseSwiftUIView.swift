//
//  Created by Bojan on 14.5.23..
//

import UIKit

open class BaseSwiftUIView: UIView {
    public var hostingViewController: UIViewController?
    
    public var isLoading: Bool = false { didSet { setupUI() } }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    open func setupUI() {
        guard let view = self.hostingViewController?.view else { return }
        
        for i in 0..<self.subviews.count {
            if self.subviews[0].tag > 0 {
                self.subviews[0].removeFromSuperview()
            }
        }
        
        self.addSubview(view)
        
        self.backgroundColor = .clear
        
        view.tag = 1
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
    
    public func showLoading() {
        self.isLoading = true
    }
    
    public func hideLoading() {
        self.isLoading = false
    }
}
