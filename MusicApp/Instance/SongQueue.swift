//
//  MusicView_Playlist.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/24/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import MediaPlayer
import UIKit
import Foundation






protocol SongQueueDelegate: class {
    
    func currentSongWasDeleted(deletedSong: Song, newSong: Song?)
    
}



class SongQueue{
    

    
    private var historyStack = SongStack()
    private var upNextStack = SongStack()
    
    private var nowPlayingSong: Song!
    
    weak var delegate: SongQueueDelegate?
    
    init(){
        fillSongDictionary()
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToSongDeletedNotification(notification:)), name: SongWasDeletedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToNewSongWasCreatedNotification(notification:)), name: NewSongWasCreatedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToUserPressedPlaySongNextNotification(notification:)), name: UserDidPressPlaySongNext, object: nil)
    }
    
    
    
    
    
    @objc private func respondToUserPressedPlaySongNextNotification(notification: Notification){
        
        let newSong = notification.userInfo![SelectedUpNextSongKey]! as! Song
        
        if let nextSong = upNextStack.peek(){
            if newSong == nextSong {return}
        }
        
        if let currentSong = nowPlayingSong {
            if newSong == currentSong{ return }
        } else { return }
        
        
        upNextStack.push(song: newSong)
        
        
        
    }
    
    
    
    @objc private func respondToSongDeletedNotification(notification: Notification){
        
        
        let deletedSong = notification.userInfo![DeletedSongObjectKey]! as! Song
        
        upNextStack.popSpecificSong(deletedSong)
        historyStack.popSpecificSong(deletedSong)
        
        if nowPlayingSong == nil { return }
        
        if nowPlayingSong == deletedSong{
            
            nowPlayingSong = upNextStack.popAndReturn()
            delegate?.currentSongWasDeleted(deletedSong: deletedSong, newSong: nowPlayingSong)
        }
        
        
        
        
    }
    
    
    @objc private func respondToNewSongWasCreatedNotification(notification: Notification){
        
        
        let newSong = notification.userInfo![NewlyCreatedSongObjectKey]! as! Song
        upNextStack.insertRandomly(song: newSong)
        
        
        
    }
    

    
    
    
    
    
    
    
    
    private func fillSongDictionary(){
        let songs = Song.getAll().shuffled()
        upNextStack.fill(with: songs)
    }
    
    func songWasChosenByHand(song: Song){
        if let oldSong = nowPlayingSong{
            historyStack.push(song: oldSong)
        }
        
        nowPlayingSong = song
        upNextStack.popSpecificSong(song)
    }
    
    
    
    func getNewUpNextSong() -> Song{
        if let song = upNextStack.popAndReturn(){
            historyStack.push(song: nowPlayingSong)
            nowPlayingSong = song
            return song
        } else {
            fillSongDictionary()
            return getNewUpNextSong()
        }
    }
    
    func getLastPlayedSong() -> Song?{
        if let song = historyStack.popAndReturn(){
            upNextStack.push(song: nowPlayingSong)
            nowPlayingSong = song
            return song
        } else { return nil }
    }
    
    
    
    
    
    
    
    
    
    
    
    func getVisualizer() -> UIViewController{
        
        let upNextController = upNextStack.getVisualizer(type: .upNext)
        let upNextItem = MenuBarControllerItem(viewController: upNextController, name: "Up Next")
        
        
        let historyController = historyStack.getVisualizer(type: .history)
        let historyItem = MenuBarControllerItem(viewController: historyController, name: "History")
        
        
        let controller = MenuBarViewController(items: [historyItem, upNextItem], titleText: "Song Queue", showsDismissButton: true)
        controller.setSelectedView(to: 1, animated: false)
        
        return controller
        
        
    }
    
    
    
    
    
}

