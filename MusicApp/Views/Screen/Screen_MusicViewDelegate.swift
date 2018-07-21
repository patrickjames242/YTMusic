//
//  TabBarController_MusicViewDelegate.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import UIKit
extension Screen: NowPlayingViewControllerDelegate{

    
    
    
    func delegate_Stuff_To_Be_Done_In_ViewDidLoad(){
        self.nowPlayingVC.delegate = self
        
    }
    
    
    var holderViewSideInsets: CGFloat{
        return 10
    }
    
    var holderViewTopInset: CGFloat{
        return 7 + APP_INSETS.top
    }
    
    
    
    private var holderViewMinimizedFrame: CGRect{
        
        return CGRect(x: holderViewSideInsets,
                      y: holderViewTopInset,
                      width: view.frame.width - (holderViewSideInsets * 2),
                      height: view.frame.height - holderViewTopInset)
    }
    
    
    
    //MARK: - MUSIC VIEW DELEGATE METHODS
    
    func userDidMaximizeNowPlayingView(){
        
        self.desiredStatusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            
            let xTranslation = self.holderViewMinimizedFrame.width / self.view.frame.width
            let yTranslation = self.holderViewMinimizedFrame.height / self.view.frame.height
            let scaleTransform = CGAffineTransform(scaleX: xTranslation, y: yTranslation)
            
            let topSpace = (self.view.frame.height - (self.view.frame.height * yTranslation)) / 2
            let remainingSpace = self.holderViewMinimizedFrame.minY - topSpace
            
            self.viewHolder.transform = scaleTransform.translatedBy(x: 0, y: remainingSpace)
            
            
            
            self.viewHolder.layer.cornerRadius = 10
            self.viewHolder.alpha = 0.7
        }, completion: nil)
        self.dismissTabBar()
        
        
    }
    
    func userDidMinimizeNowPlayingView() {
        self.desiredStatusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            self.viewHolder.center = self.view.centerInFrame
            
            self.viewHolder.transform = CGAffineTransform.identity
            self.viewHolder.center = self.view.centerInBounds
            self.viewHolder.layer.cornerRadius = 0
            self.viewHolder.alpha = 1
            
        })
        self.showTabBar()
        
        
    }
}







