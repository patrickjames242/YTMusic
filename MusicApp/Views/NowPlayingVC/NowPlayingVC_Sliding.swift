//
//  MusicView_Sliding.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/19/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


extension NowPlayingViewController{
    
    
    //MARK: - HANDLE SLIDING
    func sliderDidBeginSliding(withAnimationTime time: Double) {
        stop_SyncingSliderPositionWithMusicPlaybackPosition()
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.setMaximizedAlbumCoverConstraints(sliding: true, playing: self.songIsPlaying)
        }, completion: nil)
    }
    
    func sliderDidEndSliding(withAnimationTime time: Double, at point: Double) {
        
        
        
        songPlayer.currentTime = songPlayer.duration * point
        syncNowPlayingSliderWithCurrentSongTime()
        
        if songPlayer.isPlaying{
            start_SyncingSliderPositionWithMusicPlaybackPosition()
            
        }
        minimizedNowPlayingPreview.progressBar.changeProgressTo(point)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveLinear, animations: {
            self.setMaximizedAlbumCoverConstraints(sliding: false, playing: self.songIsPlaying)        }, completion: nil)
        

    }
    
    func stop_SyncingSliderPositionWithMusicPlaybackPosition(){
        timer.invalidate()
    }
    
    func start_SyncingSliderPositionWithMusicPlaybackPosition(){
        timer.invalidate()
        
        
        timer = Timer(timeInterval: 0.1, repeats: true, block: { (timer) in
            self.scrubbingSlider.syncSliderPositionWith(playBackPosition: self.songPlayer.currentTime)
            self.minimizedNowPlayingPreview.progressBar.changeProgressTo(self.songPlayer.currentTime / self.songPlayer.duration)
        })
        
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        
        
    }
    
    
    func syncNowPlayingSliderWithCurrentSongTime(){

        NowPlayingInfoUpdator.main.updateElapsedTime()


    }
    
    
    
    
}
