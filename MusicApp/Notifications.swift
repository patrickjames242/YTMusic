//
//  Notifications.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import UIKit

class MNotifications{
    
  static let SongNameDidChangeNotification = Notification.Name("SongNameDidChange")
  static let SongNameDidChangeSongKey = "SongWhoseNameChanged"
  
  static let SongWasDeletedNotification = Notification.Name("SongWasDeleted")
  static let DeletedSongObjectKey = "DeletedSong"
  
  static let NewSongWasCreatedNotification = Notification.Name("NewSongWasCreated")
  static let NewlyCreatedSongObjectKey = "NewSong"
  
  static let UserDidPressPlaySongNext = Notification.Name("UserWantsToPlaySongNext")
  static let SelectedUpNextSongKey = "UpNextSong"
  
  static let AudioPanningStateDidChangeNotification = Notification.Name("AudioPanningDidChangeNotification")
  
  static let AppBottomSafeAreaInsetsDidChange = Notification.Name("AppBottomSafeAreaInsetsDidChange")
  static let AppBottomSafeAreaInsetKey = "BottomSafeAreaInsets"

    
    
    
    static func sendSongNameDidChangeNotification(for song: Song){
        
        NotificationCenter.default.post(name: SongNameDidChangeNotification, object: song, userInfo: [SongNameDidChangeSongKey: song])
    }
    
    static func sendSongWasDeletedNotification(for song: Song){
        NotificationCenter.default.post(name: SongWasDeletedNotification, object: song, userInfo: [DeletedSongObjectKey: song])
    }
    
    static func sendNewSongWasCreatedNotification(for song: Song){
        
        NotificationCenter.default.post(name: NewSongWasCreatedNotification, object: song, userInfo: [NewlyCreatedSongObjectKey: song])
    }
    
    static func sendUserDidPressPlaySongNextNotification(for song: Song){
        NotificationCenter.default.post(name: UserDidPressPlaySongNext, object: song, userInfo: [SelectedUpNextSongKey: song])
        
    }
    
    static func sendAudioPanningStateDidChangeNotification(){
        NotificationCenter.default.post(name: AudioPanningStateDidChangeNotification, object: nil, userInfo: nil)
    }
    static func sendAppBottomSafeAreaInsetsDidChangeNotification(for bottomInset: CGFloat){
        
        NotificationCenter.default.post(name: AppBottomSafeAreaInsetsDidChange, object: nil, userInfo: [AppBottomSafeAreaInsetKey: bottomInset])
    }
    
   
    
    
}












