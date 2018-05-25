//
//  SongStack.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


protocol SongReorderingObserver: class{
    func songWasReordered(song: Song, oldIndexPath: IndexPath, newIndexPath: IndexPath)
    func songWasRemoved(song: Song, at indexPath: IndexPath)
}


enum SongQueueChangeType{
    
    case insert, delete, fill
    
}



class SongStack: SongReorderingObserver{
    
    
    weak private var visualizer: SongQueueVisualizer?
    
    private var storage = [Song]()
    
    private var firstSongStartDate: Date?
    
    func getVisualizer(type: SongQueueVisualizerType) -> UIViewController{
        let controller = SongQueueVisualizer(songs: getAll(), type: type, reorderingDelegate: self)
        self.visualizer = controller
        
        return controller
    }
    
 
    
    
    
    
    func songWasReordered(song: Song, oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        if storage.isEmpty{ firstSongStartDate = Date() }
        storage.insert(storage.remove(at: oldIndexPath.row), at: newIndexPath.row)
    }
    
    
    func songWasRemoved(song: Song, at indexPath: IndexPath) {
        
        storage.remove(at: indexPath.row)
        if storage.isEmpty{ firstSongStartDate = nil }
    }
    
    
    
    
    
    
    
    
    
    func fill(with songs: [Song]){
        
        firstSongStartDate = Date()
        storage = songs
        
        let indexes = Array(songs.indices).map{ IndexPath(row: $0, section: 0) }
        
        visualizer?.songQueueDidChange(type: .fill, at: indexes, newArray: storage)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func push(song: Song){
        if storage.isEmpty{ firstSongStartDate = Date() }
        storage.insert(song, at: 0)

        visualizer?.songQueueDidChange(type: .insert, at: [IndexPath(row: 0, section: 0)], newArray: storage)
    }
    
    
    
    
    func insertRandomly(song: Song){
        if storage.isEmpty{ firstSongStartDate = Date() }
        let randomIndex = Int(arc4random_uniform(UInt32(storage.count)))
        storage.insert(song, at: randomIndex)
        
        visualizer?.songQueueDidChange(type: .insert, at: [IndexPath(row: randomIndex, section: 0)], newArray: storage)
        
    }
    
    
    
    
    
    
    
    
    
    func pop(){
        if storage.isEmpty { return }

        storage.remove(at: 0)
        if storage.isEmpty { firstSongStartDate = nil }
        visualizer?.songQueueDidChange(type: .delete, at: [IndexPath(row: 0, section: 0)], newArray: storage)
    }
    
    func popAndReturn() -> Song? {
        if storage.isEmpty { return nil }
        let itemToReturn = storage[0]
        pop()
        return itemToReturn
    }
    
    
    func popSpecificSong(_ song: Song){
        if let index = storage.index(of: song){
            
            storage.remove(at: index)
            if storage.isEmpty { firstSongStartDate = nil }
            visualizer?.songQueueDidChange(type: .delete, at: [IndexPath(row: index, section: 0)], newArray: storage)
            
        }
    }
    
    
    
    
    
    
    
    func peek() -> Song?{
        if storage.isEmpty { return nil }
        return storage[0]
    }
    
    
    
    func getAll() -> [Song]{
        return storage
    }
}

