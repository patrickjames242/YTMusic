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






protocol SongReorderingObserver{
    func songWasReordered(song: Song, oldIndex: Int, newIndex: Int)
    func songWasRemoved(song: Song, at index: Int)
}


enum SongQueueChangeType{
    
    case insert, delete, fill
    
}



class SongStack: SongReorderingObserver{

   
    weak private var visualizer: SongQueueVisualizer?

    private var storage = [Song]()

    
    
    func getVisualizer(type: SongQueueVisualizerType) -> UIViewController{
        let controller = SongQueueVisualizer(songs: self.getAll().reversed(), type: type, reorderingDelegate: self)
        self.visualizer = controller
        
        return controller
    }
    
    private func visualizedIndexTranslator(index: Int) -> Int{
        return storage.lastItemIndex! - index
    }
    
    
    
    
    func songWasReordered(song: Song, oldIndex: Int, newIndex: Int) {
        let oi = visualizedIndexTranslator(index: oldIndex)
        let ni = visualizedIndexTranslator(index: newIndex)
        
        storage.insert(storage.remove(at: oi), at: ni)
    }
    
    
    func songWasRemoved(song: Song, at index: Int) {
        let newIndex = visualizedIndexTranslator(index: index)
        storage.remove(at: newIndex)
    }
    
    
    
    
    
    
    
    
    
    func fill(with songs: [Song]){
        storage = songs
        
        visualizer?.songQueueDidChange(type: .fill, object: nil, at: nil, newArray: getAll().reversed())
        
    }
    
    

    
    
    
    
    
    
    
    
    func push(song: Song){
        storage.append(song)
        let newIndex = visualizedIndexTranslator(index: storage.lastItemIndex!)

        let newSongArray: [Song] = self.getAll().reversed()
        
        visualizer?.songQueueDidChange(type: .insert, object: song, at: newIndex, newArray: newSongArray)
    }
    
    func insertRandomly(song: Song){
        
        let randomIndex = Int(arc4random_uniform(UInt32(storage.count)))
        
        storage.insert(song, at: randomIndex)
        let visualizerIndex = visualizedIndexTranslator(index: randomIndex)

        
        visualizer?.songQueueDidChange(type: .insert, object: song, at: visualizerIndex, newArray: getAll().reversed())
        
    }
    
    
    
    
    
    
    
    
    
    func pop(){
        if storage.isEmpty { return }
        
        let index = storage.lastItemIndex!
        let song = storage[index]
        let newIndex = visualizedIndexTranslator(index: index)
        storage.remove(at: index)
        
        
        visualizer?.songQueueDidChange(type: .delete, object: song, at: newIndex, newArray: getAll().reversed())
    }
    
    func popAndReturn() -> Song? {
        if storage.isEmpty { return nil }
        let itemToReturn = storage[storage.lastItemIndex!]
        pop()
        return itemToReturn
    }
    
    
    func popSpecificSong(_ song: Song){
        if let index = storage.index(of: song){
           let newIndex = visualizedIndexTranslator(index: index)
            storage.remove(at: index)

            visualizer?.songQueueDidChange(type: .delete, object: song, at: newIndex, newArray: getAll().reversed())

        }
    }
    
    
    
    
    
    
    
    func peek() -> Song?{
        if storage.isEmpty { return nil }
        return storage[storage.lastItemIndex!]
    }
    
    
    
    func getAll() -> [Song]{
        return storage
    }
}

















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
        
        if let currentSong = nowPlayingSong{
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

