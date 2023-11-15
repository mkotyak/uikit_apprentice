import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let time = transitionDuration(using: transitionContext)
            
            UIView.animate(
                withDuration: time,
                animations: {
                    fromView.alpha = 0
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
                }
            )
        }
    }
}
