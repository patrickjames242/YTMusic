//
//  SearchAPI.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/20/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit





class Searcher{
    
    private var recentSearches = [String: [Song]]()
    
    var searchIsActive: Bool{
        return _searchIsActive
    }
    
    
    private var _searchIsActive = false
    
    private var currentArray = [Song]()
    
    func beginSearchSessionWith(_ array: [[Song]]){
        
        _searchIsActive = true
        currentArray = convertNestedArray(array)
    }
    
    private func convertNestedArray(_ array: [[Song]]) -> [Song]{
        var rawSongArray = [Song]()
        for songArray in array{
            rawSongArray.append(contentsOf: songArray)
        }
        return rawSongArray
    }
    
    
    
    
    
    func cancelCurrentSearchSession(){
        _searchIsActive = false
        recentSearches.removeAll()
        currentArray = []
    }
    
    
    
    
    private func loopThrough(_ songs: [Song], for searchText: String) -> [Song]{
        
        if recentSearches[searchText] != nil{ return recentSearches[searchText]! }
        
        let songsToReturn = EArray<Song>()
        
        
        
        songsToReturn.irateThrough(array: songs) { (song) -> Song? in
            if song.artistName.localizedCaseInsensitiveContains(searchText) || song.name.localizedCaseInsensitiveContains(searchText){
                
                return song
                
            } else {return nil}
        }
        
        
        
        recentSearches[searchText.removeWhiteSpaces()] = songsToReturn.elements
        return songsToReturn.elements
        
    }
    
    
    
    
    
    
    func getResultsFor(_ searchText: String, completion: @escaping ([Song]) -> Void){
        
        let trimmedSearchText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            
            if let results = self.recentSearches[trimmedSearchText]{
                DispatchQueue.main.sync {
                    completion(results)
                }
                return
            }

            DispatchQueue.main.sync {
                completion(self.loopThrough(self.currentArray, for: trimmedSearchText))
                
            }
        }
    }
    
    
    
    
    
    
    
}

