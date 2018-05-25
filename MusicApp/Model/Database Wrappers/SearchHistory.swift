//
//  SearchHistoryEntry.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation





protocol SearchHistoryDelegate{
    
    func allSongsWereRemovedFromSearchHistory()
    
}



class DBHistory{
    
    
    private static let searchHistoryKey = "SEARCH HISTORY KEY"
    
    
    static var searchHistoryDelegate: SearchHistoryDelegate?
    
    private static func deleteAllHistory(){
        
        UserDefaults.standard.removeObject(forKey: searchHistoryKey)
        
    }
    
    
    static var searchHistory: [String]{
        
        initialize_searchHistory_ifNeeded()
        
        return _searchHistory!.entryList
        
    }
    
    
    private static var _searchHistory: SearchHistoryList?
    
    
    
    static func addItemToSearchHistory(_ text: String){
        
        initialize_searchHistory_ifNeeded()
        
        _searchHistory!.insert(newEntry: text)
        
        saveHistory()
    }
    
    
    static func removeItemFromSearchHistory(_ text: String){
        initialize_searchHistory_ifNeeded()
        
        _searchHistory!.remove(entry: text)
        
        saveHistory()
    }
    
    static func removeAllItemsFromSearchHistory(){
        initialize_searchHistory_ifNeeded()
        
        _searchHistory!.removeAll()
        
        saveHistory()
        
        searchHistoryDelegate?.allSongsWereRemovedFromSearchHistory()
    }
    
    
    
    private static func saveHistory(){
        
        UserDefaults.standard.set(_searchHistory!.data!, forKey: searchHistoryKey)
        
    }
    
    
    
    
    private static func initialize_searchHistory_ifNeeded(){
        if _searchHistory != nil{return}
        if let data = UserDefaults.standard.value(forKey: searchHistoryKey) as? Data,
            let history = SearchHistoryList(data: data){
            
            self._searchHistory = history
            
        } else {
            
            let newHistoryList = SearchHistoryList()
            UserDefaults.standard.set(newHistoryList.data!, forKey: searchHistoryKey)
            _searchHistory = newHistoryList
        }
    }
    
    
    
}


