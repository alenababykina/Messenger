

import UIKit

class LoadingView: UIView {
    
    private var parentView: UIView!
    private let centerView = UIView()
    private let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    convenience init(view: UIView!) {
        self.init(frame: view.bounds)
        parentView = view
        
        backgroundColor = UIColor.clear
        centerView.backgroundColor = UIColor.clear
        centerView.translatesAutoresizingMaskIntoConstraints = false
        centerView.layer.cornerRadius = 3
        centerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = centerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        centerView.insertSubview(blurEffectView, at: 0)
        
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        self.addSubview(centerView)
        let views = ["centerView": centerView, "superview": self]
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[superview]-(<=1)-[centerView]", options: .alignAllCenterX, metrics: nil, views: views)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[centerView]", options: .alignAllCenterY, metrics: nil, views: views)
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        
        centerView.addSubview(label)
        centerView.addSubview(activityIndicator)
        
        let viewLoading = ["label": label, "activity": activityIndicator]
        let hConstraintsLoading = NSLayoutConstraint.constraints(withVisualFormat: "|-[activity]-[label]-|", options: [], metrics: nil, views: viewLoading)
        let vConstraintsLabel = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: viewLoading)
        let vConstraintsActivity = NSLayoutConstraint.constraints(withVisualFormat: "V:|[activity]|", options: [], metrics: nil, views: viewLoading)
        
        centerView.addConstraints(hConstraintsLoading)
        centerView.addConstraints(vConstraintsLabel)
        centerView.addConstraints(vConstraintsActivity)
    }
    
    private func addDefaultConstraints(to view: UIView) {
        let constraints = [
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view.superview!, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view.superview!, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view.superview!, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view.superview!, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        view.superview!.addConstraints(constraints)
    }
    
    func startLoading(text: String?){
        label.text = text
        
        parentView.addSubview(self)
        addDefaultConstraints(to: self)
        
        activityIndicator.startAnimating()
    }
    
    
    func endLoading(){
        centerView.removeFromSuperview()
        
        self.removeFromSuperview()
    }
}
