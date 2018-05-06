//
//  NowPlayingInfoCenter.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MediaPlayer

class NowPlayingInfoUpdator{
    
    static let main = NowPlayingInfoUpdator()
    
    private var songInfoTimer = Timer()
    private var songDurationTimer = Timer()
    
    
    private var newSong: Song!
    private var currentAudioPlayer: AVAudioPlayer!
    
    
    func updateElapsedTime(){
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentAudioPlayer.currentTime
        
        
        
        //        songInfoTimer.invalidate()
        //        songDurationTimer.invalidate()
        //
        //        let newID = NSUUID().uuidString
        //
        //        songInfoTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
        //            self.checkSongInfo(using: newID)
        //        })
        //
        //
        
        
        
        /*
         guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
         info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentAudioPlayer.currentTime
         
         if currentAudioPlayer != nil{
         
         if currentAudioPlayer.isPlaying{
         info[MPNowPlayingInfoPropertyPlaybackRate] = 0
         info[MPNowPlayingInfoPropertyPlaybackRate] = 1
         
         } else{
         info[MPNowPlayingInfoPropertyPlaybackRate] = 1
         info[MPNowPlayingInfoPropertyPlaybackRate] = 0
         
         }
         
         } else { return }
         
         */
        
        
    }
    
    func invalidateNowPlayingInfo(){
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        
    }
    
    private lazy var elapsedTimeTimer = Timer()
    
    func updateWith(_ song: Song, songPlayer: AVAudioPlayer){
        
        
        songInfoTimer.invalidate()
        songDurationTimer.invalidate()
        
        newSong = song
        
        let newID = NSUUID().uuidString
        
        currentAudioPlayer = songPlayer
        songInfoTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (timer) in
            self.checkSongInfo(using: newID)
        })
        
        //        elapsedTimeTimer.invalidate()
        //        elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (timer) in
        //            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentAudioPlayer.currentTime
        //
        //        })
        
        
    }
    
    
    
    
    
    private func checkSongInfo(using ID: String){
        
        guard let info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            setNowPlayingInformationFor_LockScreenAnd_ControlCenter(withSong: newSong, and: ID)
            return
        }
        
        if info[nowPlayingUniqueIDString] as! String != ID{
            setNowPlayingInformationFor_LockScreenAnd_ControlCenter(withSong: newSong, and: ID)
        } else {
            songInfoTimer.invalidate()
        }
    }
    
    private var nowPlayingUniqueIDString = "unique ID"
    
    private func setNowPlayingInformationFor_LockScreenAnd_ControlCenter(withSong song: Song, and ID: String){
        
        let mp = MPNowPlayingInfoCenter.default()
        
        let imageProvider = { (size: CGSize) -> UIImage in
            return song.image
        }
        
        
        mp.nowPlayingInfo = [
            
            
            nowPlayingUniqueIDString : ID,
            MPMediaItemPropertyTitle: song.name,
            MPMediaItemPropertyArtist: song.artistName,
            MPMediaItemPropertyPlaybackDuration: song.duration,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: CGSize.zero, requestHandler: imageProvider),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentAudioPlayer.currentTime
        ]
        
    }
    
    
}
