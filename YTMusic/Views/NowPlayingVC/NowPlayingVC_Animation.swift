//
//  MusicView_ViewObjects.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/19/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


extension NowPlayingViewController{
    
    
    
    // MARK: - ANIMATIONS
    // MARK: -
    
    func makeMyselfInvisible(){
        

        deactivateAllSongPlayingFeatures()
        

        UIView.animate(withDuration: 0.4) {
            self.set_makeMyselfInvisible_Constraints()
            self.view.layoutIfNeeded()
        }
        self.musicViewIsMinimized = true
        
        prepareMusicViewFor_Minimization()
        
        
        AppManager.shared.musicViewWasHidden()
        iAmVisible = false
        
    }

    
    
    
    
    
    
    
    
    
    
    
    func makeMyselfVisible(){
        
        activateAllSongPlayingFeatures()
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            self.setMinimizedConstraints()
            
            
        
        }, completion: nil)
        
        AppManager.shared.musicViewWasShown()
        iAmVisible = true
    }
    
    
    
    
    
    // MARK: - LIFTING UP MUSIC VIEW
    
    
    
    
    func prepareMusicViewFor_Maximization(animationTime: TimeInterval){
        delegate?.userDidMaximizeNowPlayingView()
        UIView.animate(withDuration: 0.1, animations: {
            
            self.view.backgroundColor = .white
        
        }) { (success) in
            
            UIView.animate(withDuration: 0.1) {
                self.backGroundBluryView.alpha = 0
                
            }
        }
        

        
        UIView.animate(withDuration: animationTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.view.layer.cornerRadius = self.musicViewEndingFrameCornerRadius
            self.topNub.alpha = 1
            
            self.setMaximizedAlbumCoverConstraints(sliding: false, playing: self.songIsPlaying)
            
        }, completion: nil)
        
        
        UIView.animate(withDuration: 0.3) {
            self.minimizedNowPlayingPreview.alpha = 0
            
            
        }
        
        if songIsPlaying{
            albumImage.showShadow(with: 0.2)
        }
        
    }
    
    
    
    
    

    
    
    
    
    
    
    
    func liftUpMusicView(animationTime: Double){
        musicViewIsMinimized = false
        topNub.addGestureRecognizer(topNubGesture)
        minimizedNowPlayingPreview.removeGestureRecognizer(goUpRecognizer)
        self.view.removeGestureRecognizer(longPressGesture)
 
        
        prepareMusicViewFor_Maximization(animationTime: animationTime)
        
        UIView.animate(withDuration: animationTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.setMaximizedConstraints()
        }, completion: nil)
    }
    
    
    
    
    
    
    @objc func liftUpMusicViewTapGestureSelectorFunction(){
        liftUpMusicView(animationTime: 0.7)
        self.view.addGestureRecognizer(bringBackDownGesture)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - PULLING THE MUSIC VIEW BACK DOWN
    
    
    
    
    
    func panGestureTranslationDidChangeTo(yTranslation: CGFloat){
        if lengthOfPan < elasticDistance {

            self.userDraggedMusicViewBy(yTranslation * 0.55)
            lengthOfPan += yTranslation
        } else {
            finishBringingMusicViewDown()
        }
    }
    
    
    
    
    
    func prepareMusicViewFor_Minimization(){
        
        delegate?.userDidMinimizeNowPlayingView()
        
        
        lengthOfPan = 0
        
        view.removeGestureRecognizer(bringBackDownGesture)
        minimizedNowPlayingPreview.addGestureRecognizer(goUpRecognizer)
        view.addGestureRecognizer(longPressGesture)
        topNub.removeGestureRecognizer(topNubGesture)
        
        albumImage.hideShadow(with: 0.2)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.backGroundBluryView.alpha = 1
        }) { (success) in
            
            UIView.animate(withDuration: 0.1) {
                self.view.backgroundColor = .clear
                
                
            }
            
            
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.view.layer.cornerRadius = 0
            self.setMinimizedAlbumCoverConstraints()
            self.topNub.alpha = 0
            self.minimizedNowPlayingPreview.alpha = 1
            
            // this is because sometimes the label doesn't appear, because it was probably set to zero for some reason when the song changed. I don't feel like figuring it out, so I acknowledge the fact that I am a lazy, crappy programmer.
            self.minimizedNowPlayingPreview.songNameLabel.alpha = 1
            
        }, completion: nil)
        
        
        
        
        
    }
    
    
    
    
    @objc func finishBringingMusicViewDown(){
        musicViewIsMinimized = true
        

        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
            self.setMinimizedConstraints()
            
            
        }, completion: nil)
        
        
        prepareMusicViewFor_Minimization()
        
        
        
        
    }
    

    
    
    
    
    
    
    @objc func bringMusicViewBackDown(gesture: UIPanGestureRecognizer){
        
        
        let gestureTranslation = gesture.translation(in: self.view)
        
        switch gesture.state{
        case .began, .changed:
            
            panGestureTranslationDidChangeTo(yTranslation: gestureTranslation.y)
            
        case .ended:
            
            liftUpMusicView(animationTime: 0.4)
            
            
            lengthOfPan = 0
        default: break
        }
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    
    
}
