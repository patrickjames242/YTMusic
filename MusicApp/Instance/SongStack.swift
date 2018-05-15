//
//  SongStack.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


protocol SongReorderingObserver: class{
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
        
        let indexes = Array(songs.indices)
        
        visualizer?.songQueueDidChange(type: .fill, at: indexes, newArray: getAll().reversed())
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func push(song: Song){
        storage.append(song)
        let newIndex = visualizedIndexTranslator(index: storage.lastItemIndex!)
        
        let newSongArray: [Song] = self.getAll().reversed()
        
        visualizer?.songQueueDidChange(type: .insert, at: [newIndex], newArray: newSongArray)
    }
    
    func insertRandomly(song: Song){
        
        let randomIndex = Int(arc4random_uniform(UInt32(storage.count)))
        
        storage.insert(song, at: randomIndex)
        let visualizerIndex = visualizedIndexTranslator(index: randomIndex)
        
        
        visualizer?.songQueueDidChange(type: .insert, at: [visualizerIndex], newArray: getAll().reversed())
        
    }
    
    
    
    
    
    
    
    
    
    func pop(){
        if storage.isEmpty { return }
        
        let index = storage.lastItemIndex!
        let newIndex = visualizedIndexTranslator(index: index)
        storage.remove(at: index)
        
        
        visualizer?.songQueueDidChange(type: .delete, at: [newIndex], newArray: getAll().reversed())
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
            
            visualizer?.songQueueDidChange(type: .delete, at: [newIndex], newArray: getAll().reversed())
            
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

