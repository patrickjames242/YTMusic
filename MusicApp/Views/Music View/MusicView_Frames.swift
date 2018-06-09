//
//  MusicView_Frames.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/19/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


extension MusicView {
    

    func setUpInitialViewPosition_Constraints(){
        guard let superview = superview else { return }
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        
        heightAnchor.constraint(equalTo: superview.heightAnchor, constant: -endingMusicViewFrameSpaceFromTop - AppManager.appInsets.top).isActive = true
        
        topAnchorPositionConstraint = topAnchor.constraint(equalTo: superview.topAnchor, constant: superview.frame.height)
        topAnchorPositionConstraint.isActive = true
    }
    
    func set_makeMyselfInvisible_Constraints(){
        guard let superview = superview else {return}
        superview.layoutIfNeeded()
        topAnchorPositionConstraint.constant = superview.frame.height
        
        
    }
    
    
    
    func setMinimizedConstraints() {
        guard let superview = superview else { return }
        superview.layoutIfNeeded()
        let minimizedViewHeight = AppManager.minimizedMusicViewHeight + AppManager.shared.screen.tabBar.frame.height
        topAnchorPositionConstraint.constant = superview.frame.height - minimizedViewHeight
        superview.layoutIfNeeded()
    }
    
    
    
    func setMaximizedConstraints() {
        guard let superview = superview else { return }

        let maximizedTopSpace = endingMusicViewFrameSpaceFromTop + AppManager.appInsets.top
        topAnchorPositionConstraint.constant = maximizedTopSpace
        superview.layoutIfNeeded()

    }

    func userDraggedMusicViewBy(_ points: CGFloat) {
        guard let constraint = topAnchorPositionConstraint else { return }
        guard let superview = superview else { return }


        let minimumTopSpace = endingMusicViewFrameSpaceFromTop + AppManager.appInsets.top
        
        constraint.constant = max(constraint.constant + points, minimumTopSpace)
        superview.layoutIfNeeded()
    }
    

    
    
    //MARK: - MINIMIZED VIEW FRAMES
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var albumCoverTopInset: CGFloat{
        return 5
    }
    
    
    
    func setInitialAlbumCoverConstraints(){
        
        
        albumCover_topConstraint = albumImage.topAnchor.constraint(equalTo: topAnchor, constant: albumCoverTopInset)
        albumCover_topConstraint.isActive = true
        
        albumCover_leftConstraint = albumImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
        albumCover_leftConstraint.isActive = true
        
        albumCover_heightConstraint = albumImage.heightAnchor.constraint(equalToConstant: 0)
        albumCover_heightConstraint.isActive = true
        
        albumCover_widthConstraints = albumImage.widthAnchor.constraint(equalToConstant: 0)
        albumCover_widthConstraints.isActive = true
        
        
        albumCoverSize = self.minimizedAlbumCover_Size
        
        
        
        albumCover_centerXConstraint = albumImage.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        
        layoutIfNeeded()
    }
    
    
    func setMinimizedAlbumCoverConstraints(){
        albumImage.maximizeImage()
        albumCover_centerXConstraint.isActive = false
        albumCover_leftConstraint.isActive = true
        
        albumCover_topConstraint.constant = albumCoverTopInset
        albumCoverSize = minimizedAlbumCover_Size
        layoutIfNeeded()
    }
    
    
    func setMaximizedAlbumCoverConstraints(sliding: Bool, playing: Bool){
        albumCover_leftConstraint.isActive = false
        albumCover_centerXConstraint.isActive = true
        albumCover_topConstraint.constant = maximizedAlbumCoverInset
        
        
        if !playing{ albumImage.minimizeImage() }
        
        
        if sliding && playing{
            
            albumCoverSize = maximizedAlbumCoverSize_Playing_Sliding
            
            
        }
        
        if !sliding && playing{
            albumCoverSize = maximizedAlbumCoverSize_Playing_NotSliding
            
            
        }
        
        if sliding && !playing{
            albumCoverSize = maximizedAlbumCoverSize_Paused_Sliding
            albumCover_topConstraint.constant = 5
            
        }
        
        if !sliding && !playing{
            albumCoverSize = maximizedAlbumCoverSize_Paused_NotSliding

            
        }
        
        
        layoutIfNeeded()
    }
    
    
    
    
    var albumDifferenceFactor: CGFloat{
        return Variations.MusicView.albumImageDifferenceFactor
    }
    
    
    
    
    
    
    
    var albumCoverSize: CGSize{
        get{
            return CGSize(width: albumCover_widthConstraints.constant,
                          height: albumCover_heightConstraint.constant)
        }
        set{
            albumCover_widthConstraints.constant = newValue.width
            albumCover_heightConstraint.constant = newValue.height
            
        }
    }
    
    
    
    
    
    var minimizedAlbumCover_Size: CGSize{
        
        
        let height = AppManager.minimizedMusicViewHeight - (albumCoverTopInset * 2)
        let width = height
        return CGSize(width: width, height: height)
        
        
    }
    
    var maximizedAlbumCoverSize_Paused_Sliding: CGSize{
        return maximizedAlbumCoverSize_Paused_NotSliding
        
    }
    
    var maximizedAlbumCoverSize_Paused_NotSliding: CGSize{
        
        let minFrameWidth = min(superview!.frame.width, superview!.frame.height)
        
        let width = minFrameWidth - (maximizedAlbumCoverInset * 2)
        let height = width - albumDifferenceFactor
        
        return CGSize(width: width, height: height)
        
        
        
    }
    
    var maximizedAlbumCoverSize_Playing_Sliding: CGSize {
        
        let decreaseConstant: CGFloat = 0.9
        
        let minFrameWidth = min(superview!.frame.width, superview!.frame.height)
    
        let width = (minFrameWidth - (maximizedAlbumCoverInset * 2)) * decreaseConstant
        let height = (width - albumDifferenceFactor) * decreaseConstant
        
        return CGSize(width: width, height: height)
    }
    
    var maximizedAlbumCoverSize_Playing_NotSliding: CGSize{
        let minFrameWidth = min(superview!.frame.width, superview!.frame.height)
        
        let width = minFrameWidth - (maximizedAlbumCoverInset * 2)
        let height = width - albumDifferenceFactor
        
        return CGSize(width: width, height: height)
        
        
    }
    
    
    var maximizedAlbumCoverInset: CGFloat{
        
        return 30
        
    }
    
    var distanceFromTopOfMusicViewToBottomOfAlbumCover: CGFloat{
        
        return maximizedAlbumCoverInset + maximizedAlbumCoverSize_Playing_NotSliding.height
        
    }
    
    

    
}
