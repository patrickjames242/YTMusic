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


extension NowPlayingViewController {
    

    
    
    func setInitialConstraints(){
     
        view.pin(left: parentView.leftAnchor, right: parentView.rightAnchor)
        view.heightAnchor.constraint(equalTo: parentView.heightAnchor, constant: -APP_INSETS.top - endingMusicViewFrameSpaceFromTop).isActive = true
        
        topAnchorConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: parentView.frame.height)
        topAnchorConstraint.isActive = true
        
        parentView.layoutIfNeeded()
    }
    
    func set_makeMyselfInvisible_Constraints(){
        parentView.layoutIfNeeded()
        topAnchorConstraint.constant = parentView.frame.height
        parentView.layoutIfNeeded()
        
    }
    
    
    
    func setMinimizedConstraints() {
        
        parentView.layoutIfNeeded()
        let minimizedViewHeight = AppManager.minimizedMusicViewHeight + AppManager.tabBarHeight + APP_INSETS.bottom
        topAnchorConstraint.constant = parentView.frame.height - minimizedViewHeight
        parentView.layoutIfNeeded()
    }
    
    
    
    func setMaximizedConstraints() {
        let maximizedTopSpace = endingMusicViewFrameSpaceFromTop + APP_INSETS.top
        topAnchorConstraint.constant = maximizedTopSpace
        parentView.layoutIfNeeded()

    }

    func userDraggedMusicViewBy(_ points: CGFloat) {
        let minimumTopSpace = endingMusicViewFrameSpaceFromTop + APP_INSETS.top
        topAnchorConstraint.constant = max(topAnchorConstraint.constant + points, minimumTopSpace)
        parentView.layoutIfNeeded()
    }
    

    
    
    //MARK: - MINIMIZED VIEW FRAMES
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var albumCoverMinimizedTopInset: CGFloat{
        return 5
    }
    
    
    
    func setInitialAlbumCoverConstraints(){
        
        
        albumCover_topConstraint = albumImage.topAnchor.constraint(equalTo: view.topAnchor, constant: albumCoverMinimizedTopInset)
        albumCover_topConstraint.isActive = true
        
        albumCover_leftConstraint = albumImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10)
        albumCover_leftConstraint.isActive = true
        
        albumCover_heightConstraint = albumImage.heightAnchor.constraint(equalToConstant: 0)
        albumCover_heightConstraint.isActive = true
        
        albumCover_widthConstraints = albumImage.widthAnchor.constraint(equalToConstant: 0)
        albumCover_widthConstraints.isActive = true
        
        
        albumCoverSize = self.minimizedAlbumCover_Size
        
        
        
        albumCover_centerXConstraint = albumImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        
        view.layoutIfNeeded()
    }
    
    
    func setMinimizedAlbumCoverConstraints(){
        albumImage.maximizeImage()
        albumCover_centerXConstraint.isActive = false
        albumCover_leftConstraint.isActive = true
        
        albumCover_topConstraint.constant = albumCoverMinimizedTopInset
        albumCoverSize = minimizedAlbumCover_Size
        view.layoutIfNeeded()
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
        
        
        view.layoutIfNeeded()
    }
    
    
    
    
    
    
    
    //MARK: - ALBUM COVER SIZING
    
    
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
        
        
        let height = AppManager.minimizedMusicViewHeight - (albumCoverMinimizedTopInset * 2)
        let width = height
        return CGSize(width: width, height: height)
        
        
    }
    
    var maximizedAlbumCoverSize_Paused_Sliding: CGSize{
        return maximizedAlbumCoverSize_Paused_NotSliding
        
    }
    
    var maximizedAlbumCoverSize_Paused_NotSliding: CGSize{
        
        let minFrameWidth = min(parentView.frame.width, parentView.frame.height)
        
        let width = minFrameWidth - (maximizedAlbumCoverInset * 2)
        let height = width - albumDifferenceFactor
        
        return CGSize(width: width, height: height)
        
        
        
    }
    
    var maximizedAlbumCoverSize_Playing_Sliding: CGSize {
        
        let decreaseConstant: CGFloat = 0.9
        
        let minFrameWidth = min(parentView.frame.width, parentView.frame.height)
    
        let width = (minFrameWidth - (maximizedAlbumCoverInset * 2)) * decreaseConstant
        let height = (width - albumDifferenceFactor) * decreaseConstant
        
        return CGSize(width: width, height: height)
    }
    
    var maximizedAlbumCoverSize_Playing_NotSliding: CGSize{
        let minFrameWidth = min(parentView.frame.width, parentView.frame.height)
        
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
