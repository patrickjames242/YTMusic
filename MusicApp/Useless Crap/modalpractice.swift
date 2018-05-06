//
//  modalpractice.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit




class BaseViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.backgroundColor = .white

    }



    lazy var button: UIButton = {

        let x = UIButton(frame: CGRect(x: 200, y: 200, width: 50, height: 50))
        x.backgroundColor = .purple
        x.addTarget(self, action: #selector(respondToButtonPressed), for: .touchUpInside)
        return x

    }()

    @objc func respondToButtonPressed(){


        let newController = ControllerToPresent()
        newController.modalPresentationStyle = .custom
        modalPresentationStyle = .custom
        
        let transitionDelegate = TransitioningDelegate()
        newController.transitioningDelegate = transitionDelegate
        transitioningDelegate = transitionDelegate
        
        present(newController, animated: true, completion: nil)
        
    }

}



class ControllerToPresent: UIViewController{

   



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(dismissGesture)
    }
    
    
    @objc func viewTapped(){
        
        dismiss(animated: true, completion: nil)
        
    }
    


}












class TransitioningDelegate:NSObject, UIViewControllerTransitioningDelegate{
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DissmisalAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator()
    }
    
    
    
}









class DissmisalAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    let duration = 0.5
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        transitionContext.completeTransition(true)
    }
    
    
    
    
}







class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    var duration = 0.5
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {return}
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {return}
        
        let container = transitionContext.containerView
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: 0, y: -(toView.frame.height) - 20)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            fromView.transform = CGAffineTransform(translationX: 0, y: 600)
            toView.transform = CGAffineTransform.identity
        }) { (success) in
            transitionContext.completeTransition(true)

        }
        
        
    }
    
}





































