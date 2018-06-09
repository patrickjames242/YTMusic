//
//  MusicView_SongPlayer.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/21/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//


import UIKit
import MediaPlayer
import AVFoundation






extension MusicView: SongQueueDelegate{
    
    
    //MARK: - HANDLE MEDIA PLAYER CONTROL ACTIONS
    
    func playMusic(){
    
        syncNowPlayingSliderWithCurrentSongTime()
        
        songPlayer.prepareToPlay()

        songPlayer.play()
        currentlyPlayingSong?.changeNowPlayingStatusTo(.playing)
        

        
        self.start_SyncingSliderPositionWithMusicPlaybackPosition()
        
        if musicViewIsMinimized{ return }
        
        albumImage.showShadow(with: 0.2)
        albumImage.maximizeImage()
    }
    
    
    
   
    
    func pauseMusic(){
    
        syncNowPlayingSliderWithCurrentSongTime()
        songPlayer.pause()
        currentlyPlayingSong?.changeNowPlayingStatusTo(.paused)
    
        stop_SyncingSliderPositionWithMusicPlaybackPosition()
        
        if musicViewIsMinimized {return}
        albumImage.hideShadow(with: 0.3)
        
        albumImage.minimizeImage()

        
    }
    
    
    private func justRewindToTheBeginningOfCurrentSong(){
        songPlayer.currentTime = 0
        self.scrubbingSlider.syncSliderPositionWith(playBackPosition: 0)
        minimizedProgressBar.changeProgressTo(0)
    }
    
    
    
    func rewindMusic(playWhenRewinded: Bool){
        
        
        func tryPlayingPreviousSong(){
            if let previousSong = songQueue.getLastPlayedSong(){
                setUpMusicPlayer(withSong: previousSong, userHandPicked: false, playWhenSetted: playWhenRewinded, animated: false)
            } else {
                justRewindToTheBeginningOfCurrentSong()
            }
        }
        
        
        
        if songPlayer.currentTime < 5{
            tryPlayingPreviousSong()
        } else {
            justRewindToTheBeginningOfCurrentSong()
        }
        syncNowPlayingSliderWithCurrentSongTime()
    }
    
    
    
    
    
    func fastForwardMusic(playWhenFastForwarded: Bool){
      
        
        let newSong = songQueue.getNewUpNextSong()
        scrubbingSlider.syncSliderPositionWith(playBackPosition: 0)
        minimizedProgressBar.changeProgressTo(0)
        setUpMusicPlayer(withSong: newSong, userHandPicked: false, playWhenSetted: playWhenFastForwarded, animated: false)
         
        syncNowPlayingSliderWithCurrentSongTime()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SELECTORS
    
    @objc func carryOutRewindingButtonTarget(){
        rewindMusic(playWhenRewinded: (songPlayer.isPlaying) ? true : false)
    }
    
    @objc func carryOutPlayPauseButtonTarget(){

        if songPlayer.isPlaying{ pauseMusic() }
        else { playMusic() }
        
        self.changePlayPauseButtonImagesTo(self.songIsPlaying ? .pause : .play)

    }
    @objc func carryOutFastForwardButtonTarget(){
        fastForwardMusic(playWhenFastForwarded: songPlayer.isPlaying)
    }
    
    
    
    
    @objc func respondToNowPlaying_Play_Button(){

        self.playMusic()
        changePlayPauseButtonImagesTo(.pause)
    }
    
    @objc func respondToNowPlaying_Pause_Button(){

        self.pauseMusic()
        changePlayPauseButtonImagesTo(.play)
    }
    
    func changePlayPauseButtonImagesTo(_ type: MediaButtonType){
        
        play_PauseButton.changeButtonImage(withEndingType: type)
        minimizedPlayPauseButton.changeButtonImage(withEndingType: type)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // delegate method of the songQueue protocol
    
    func currentSongWasDeleted(deletedSong: Song, newSong: Song?) {
        
        if let song = newSong{
            setUpMusicPlayer(withSong: song, userHandPicked: false, playWhenSetted: songIsPlaying, animated: false)
        } else {
            makeMyselfInvisible()
        }
        
        
    }
    
    
    
    
    
    
    
    

    
    private final class Storage{
    
        static weak var currentlyPlayingSong: Song?
        
    }
    
    var currentlyPlayingSong: Song?{
        get{
            return Storage.currentlyPlayingSong
        } set {
            Storage.currentlyPlayingSong = newValue
        }
    }
    
    
    
    //MARK: - MUSIC PLAYER SETUP
    
    enum SongPlayingError: Error{ case couldNotPlay}
    
    
    
    
    
    
    
    
    
    
    
    func setUpMusicPlayer(withSong song: Song, userHandPicked: Bool, playWhenSetted: Bool, animated: Bool) {
        var shouldIAnimatePlayButtonWhenImDone = animated
        
    
        
        
        
        // CARRIED OUT IF THE USER CHOSE THE SONG BY HAND
        if userHandPicked{
            if let player = songPlayer{
                shouldIAnimatePlayButtonWhenImDone = (player.isPlaying) ? false : true
            }
            if let currentSong = currentlyPlayingSong{
                if song == currentSong{
                    justRewindToTheBeginningOfCurrentSong()
                    
                    self.playMusic()
                    
                    if shouldIAnimatePlayButtonWhenImDone{
                        changePlayPauseButtonImagesTo(.pause)
                    }
                    
                    return
                }
            }
        }
        

        
        
        stop_SyncingSliderPositionWithMusicPlaybackPosition()
        
        do{
            songPlayer = try AVAudioPlayer(data: song.data)
        }
        catch{
            
            fatalError("setting the song, \(song.name) resulted in an error in the MusicView_SongPlayer.swift file, in the 'setUpMusicPlayer' function")
        
        }
        
        
        
        if !iAmVisible{
            makeMyselfVisible()
            
        }
        
        
        songPlayer.delegate = self
        songPlayer.pan = DBPanning.audioPanningPositionToUse
        
        if userHandPicked{ songQueue.songWasChosenByHand(song: song)}
        
        let song = song
        song.duration = songPlayer.duration
        
        setUpAudioSession()
        
        NowPlayingInfoUpdator.main.updateWith(song, songPlayer: songPlayer)
        
        
        
        setSongInfoLabelsAndAlbumCover(withSong: song)
        self.currentlyPlayingSong?.changeNowPlayingStatusTo(.inactive)
        self.currentlyPlayingSong = song

        
        NotificationCenter.default.removeObserver(self, name: MNotifications.SongNameDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(respondToSongNameDidChangeNotification), name: MNotifications.SongNameDidChangeNotification, object: currentlyPlayingSong!)
        
        
        
        if playWhenSetted == true {
            self.playMusic()
            if shouldIAnimatePlayButtonWhenImDone{
                changePlayPauseButtonImagesTo(.pause)
            }
        } else { currentlyPlayingSong?.changeNowPlayingStatusTo(.paused) }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @objc private func respondToSongNameDidChangeNotification(){
        
        self.minimizedViewSongNameLabel.text = currentlyPlayingSong?.name
        self.songNameLabel.text = currentlyPlayingSong?.name
        self.artistAndAlbumLabel.text = currentlyPlayingSong?.artistName
    }
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            scrubbingSlider.syncSliderPositionWith(playBackPosition: 0)
            minimizedProgressBar.changeProgressTo(0)
            fastForwardMusic(playWhenFastForwarded: true)
        }
    }
    
    
    
    private func setUpAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("error in setupAudioSession function in the Music view")
            print(error)
            
        }
        
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
    }
    
    
    
    private func setSongInfoLabelsAndAlbumCover(withSong song: Song){
        
        
        self.albumImage.image = song.image
        self.scrubbingSlider.songDuration = songPlayer.duration
        
        let MINIMUM_ALPHA: CGFloat = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.songNameLabel.alpha = MINIMUM_ALPHA
            self.artistAndAlbumLabel.alpha = MINIMUM_ALPHA
            if self.musicViewIsMinimized{
                self.minimizedViewSongNameLabel.alpha = MINIMUM_ALPHA
                
            }
        }) { (success) in
        
            if let currentSong = self.currentlyPlayingSong{
                if currentSong != song {return}
            }

            self.songNameLabel.text = song.name
            self.minimizedViewSongNameLabel.text = song.name
            self.artistAndAlbumLabel.text = song.artistName

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.songNameLabel.alpha = 1
                if self.musicViewIsMinimized{
                    self.minimizedViewSongNameLabel.alpha = 1
                    
                }
            }, completion: nil)
            
            
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
               self.artistAndAlbumLabel.alpha = 1
            }, completion: nil)
            
        }
    }
    
    
    
    
    
    
    
    
    

    @objc private func respondToMPRemoteCommandCenter__ChangePositionCommand(event: MPChangePlaybackPositionCommandEvent){
        songPlayer.currentTime = event.positionTime
        scrubbingSlider.syncSliderPositionWith(playBackPosition: event.positionTime)
        minimizedProgressBar.changeProgressTo(event.positionTime / songPlayer.duration)
    }
    
    
    
    
    @objc private func respondTo__AVAudioSessionInteruption__Notification(notification: NSNotification){
        
        
        
        
        let interuptionTypeInt = notification.userInfo!["AVAudioSessionInterruptionTypeKey"]! as! UInt
        
        let interuptionType = AVAudioSessionInterruptionType(rawValue: interuptionTypeInt)!

        switch interuptionType{
        case .began:
            
            
            if songIsPlaying{
                self.pauseMusic()
                changePlayPauseButtonImagesTo(.play)
            }
        case .ended:
            if let optionsValue = notification.userInfo![AVAudioSessionInterruptionOptionKey] as? UInt{
                let options = AVAudioSessionInterruptionOptions.init(rawValue: optionsValue)
                if options.contains(.shouldResume){
                    
                    if !songIsPlaying {
                        self.playMusic()
                        changePlayPauseButtonImagesTo(.pause)
                    }
                    
                } else {
                    if songIsPlaying{
                        self.pauseMusic()
                        changePlayPauseButtonImagesTo(.play)
                    }
                }
                
                
            }
            
            
            
        }
    }
    
    
    
    
    
    @objc func respondToAudioRouteDidChangeNotification(notification: NSNotification){
        if let player = songPlayer { if !player.isPlaying { return } }
        else { return }
        
        let reasonRawValue = notification.userInfo![AVAudioSessionRouteChangeReasonKey]! as! Int
        
        let reason = AVAudioSessionRouteChangeReason(rawValue: UInt(reasonRawValue))
        
        if reason != AVAudioSessionRouteChangeReason.oldDeviceUnavailable { return }
        
        let session = AVAudioSession.sharedInstance()
        
        for x in session.currentRoute.outputs{
            if x.portType != AVAudioSessionPortBuiltInSpeaker{ continue }
            DispatchQueue.main.sync {
                self.pauseMusic()
                changePlayPauseButtonImagesTo(.play)
                
            }
        }
    }
    
    
    
    
    
    func activateAllSongPlayingFeatures(){
        
        songQueue = SongQueue()
        songQueue.delegate = self
        
        let controller = MPRemoteCommandCenter.shared()
        
        controller.playCommand.isEnabled = true
        controller.pauseCommand.isEnabled = true
        controller.previousTrackCommand.isEnabled = true
        controller.nextTrackCommand.isEnabled = true
        controller.changePlaybackPositionCommand.isEnabled = true
        
        
        
        controller.playCommand.addTarget(self, action: #selector(respondToNowPlaying_Play_Button))
        controller.pauseCommand.addTarget(self, action: #selector(respondToNowPlaying_Pause_Button))
        controller.previousTrackCommand.addTarget(self, action: #selector(carryOutRewindingButtonTarget))
        controller.togglePlayPauseCommand.addTarget(self, action: #selector(carryOutPlayPauseButtonTarget))
        controller.nextTrackCommand.addTarget(self, action: #selector(carryOutFastForwardButtonTarget))
        controller.changePlaybackPositionCommand.addTarget(self, action: #selector(respondToMPRemoteCommandCenter__ChangePositionCommand))
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToAudioRouteDidChangeNotification(notification:)), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondTo__AVAudioSessionInteruption__Notification(notification:)), name: Notification.Name.AVAudioSessionInterruption, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToAudioPanningStateChangeNotification), name: MNotifications.AudioPanningStateDidChangeNotification, object: nil)
        
    }
    
    @objc func respondToAudioPanningStateChangeNotification(){
        
        guard let player = songPlayer else {return}
        
        player.pan = DBPanning.audioPanningPositionToUse
    }
    
    func deactivateAudioSession(){
        
        
        do{
            try AVAudioSession.sharedInstance().setActive(false)
            
        } catch {
            print("error in 'deactivateAudioSession' function in the Music view")
            print(error)
            
        }
        
        
        
    }
    

    
    
    
    
    
    /// Attempts to return playback features of app to a state as if it had just been opened.
    
    func deactivateAllSongPlayingFeatures(){
    
        albumImage.image = nil
        
        songNameLabel.text = nil
        minimizedViewSongNameLabel.text = nil
        artistAndAlbumLabel.text = nil
        
        stop_SyncingSliderPositionWithMusicPlaybackPosition()
        
        songQueue = nil
        currentlyPlayingSong = nil
        
        songPlayer.stop()
        songPlayer.delegate = nil
        songPlayer = nil
    
        
        deactivateAudioSession()
        
        
        UIApplication.shared.endReceivingRemoteControlEvents()
        

        
        let controller = MPRemoteCommandCenter.shared()
        
        controller.playCommand.isEnabled = false
        controller.pauseCommand.isEnabled = false
        controller.previousTrackCommand.isEnabled = false
        controller.nextTrackCommand.isEnabled = false
        controller.changePlaybackPositionCommand.isEnabled = false
        
        
        
        controller.playCommand.removeTarget(self)
        controller.pauseCommand.removeTarget(self)
        controller.previousTrackCommand.removeTarget(self)
        controller.nextTrackCommand.removeTarget(self)
        controller.changePlaybackPositionCommand.removeTarget(self)
        controller.togglePlayPauseCommand.removeTarget(self)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioSessionInterruption, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: MNotifications.SongNameDidChangeNotification, object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: MNotifications.AudioPanningStateDidChangeNotification, object: nil)
        

    }
    
    

    
}



