//
//  Created by Bojan on 14.5.23..
//

import UIKit

public enum DefaultActivityIndicatorView {
    public static let color = UIColor.white
    
    @objc public enum Size: Int {
        case extraLarge = 48
        case large = 40
        case medium = 32
        case small = 26
    }
}

public enum ActivityIndicatorViewNavigationItemPosition {
    case left
    case right
}

struct ActivityIndicatorViewTag {
    static let background = -1111
    static let indicator = -2222
}

extension UIView {
    fileprivate var backgroundView: UIView? { return self.viewWithTag(ActivityIndicatorViewTag.background) }
    fileprivate var indicatorView: UIActivityIndicatorView? { return self.backgroundView?.viewWithTag(ActivityIndicatorViewTag.indicator) as? UIActivityIndicatorView }
    
    @objc public func showLoading(_ color: UIColor = DefaultActivityIndicatorView.color, _ size: DefaultActivityIndicatorView.Size = .extraLarge, delay: Double = 0.0) {
        if self.isLoading(), let backgroundView = self.backgroundView {
            backgroundView.superview?.bringSubviewToFront(backgroundView)
            return
        }
        
        let loadingView = UIView.createLoadingView(for: self, color, CGFloat(size.rawValue))
        self.addSubview(loadingView)
        if delay > 0 {
            self.indicatorView?.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.indicatorView?.alpha = 1
                }
            }
        }
    }
    
    @objc public func hideLoading(delay: Double = 0.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundView?.alpha = 0
            }, completion: { (finished) in
                self.hide()
            })
        }
    }
    
    public func isLoading() -> Bool {
        return self.backgroundView != nil
    }
    
    static func createLoadingView(for view: UIView? = nil, _ color: UIColor, _ size: CGFloat) -> UIView {
        let loadingView = UIView(frame: view?.bounds ?? CGRect(x: 0, y: 0, width: size, height: size))
        loadingView.accessibilityIdentifier = "loading"
        loadingView.tag = ActivityIndicatorViewTag.background
        loadingView.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin,.flexibleWidth,.flexibleHeight]
        loadingView.backgroundColor = view?.backgroundColor
        loadingView.layer.cornerRadius = view?.layer.cornerRadius ?? 0
        
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        activityIndicatorView.tag = ActivityIndicatorViewTag.indicator
        activityIndicatorView.tintColor = color
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.frame = view != nil ? CGRect(x: (view!.frame.size.width-size)/2, y: (view!.frame.size.height-size)/2, width: size, height: size) : CGRect(x: 0, y: 0, width: size, height: size)
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin,.flexibleBottomMargin]
        loadingView.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        return loadingView
    }
    
    fileprivate func hide() {
        self.indicatorView?.stopAnimating()
        self.backgroundView?.removeFromSuperview()
    }
}

extension UIButton {
    override public func showLoading(_ color: UIColor = DefaultActivityIndicatorView.color, _ size: DefaultActivityIndicatorView.Size = .medium, delay: Double = 0.0) {
        super.showLoading(color, size, delay: delay)
        
        self.setImage(UIImage(named: "clear"), for: .disabled)
        self.setTitle("", for: .disabled)
        
        self.isEnabled = false
    }
    
    override public func hideLoading(delay: Double = 0.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            super.hide()
            
            self.setImage(self.image(for: .normal), for: .disabled)
            self.setTitle(self.title(for: .normal), for: .disabled)
            
            self.isEnabled = true
        }
    }
}

extension UINavigationItem {
    public func showLoading(for barButtonItem: UIBarButtonItem, atPosition position: ActivityIndicatorViewNavigationItemPosition, _ color: UIColor = DefaultActivityIndicatorView.color, _ size: DefaultActivityIndicatorView.Size = .small) {
        let loadingView = UIView.createLoadingView(color, CGFloat(size.rawValue))
        let loadingBarButtonItem = UIBarButtonItem(customView: loadingView)
        
        if position == .left {
            self.setLeftBarButton(loadingBarButtonItem, animated: false)
        } else {
            self.setRightBarButton(loadingBarButtonItem, animated: false)
        }
    }
    
    public func hideLoading(for barButtonItem: UIBarButtonItem, atPosition position: ActivityIndicatorViewNavigationItemPosition, delay: Double = 0.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if position == .left {
                self.setLeftBarButton(barButtonItem, animated: false)
            } else {
                self.setRightBarButton(barButtonItem, animated: false)
            }
        }
    }
}
