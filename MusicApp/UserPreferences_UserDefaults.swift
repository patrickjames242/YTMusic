//
//  UserPreferences_UserDefaults.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit






final class UserPreferences{
    
    private static func deleteAllHistory(){
        
        UserDefaults.standard.removeObject(forKey: searchHistoryKey)
        
    }
    
    // DONT MESS WITH THESE STRINGS!!!!!!! YOUR GONNA FUCK SOME SHIT UP!!!!!
    
    
    private static let audioPanningPositionKey = "audio Panning position"
    private static let searchHistoryKey = "SEARCH HISTORY KEY"
    
    
    
    
    // MARK: - SEARCH HISTORY
    static var searchHistory: [String]{

        initialize_searchHistory_ifNeeded()
        
        return _searchHistory!.entryList

    }
    
    
    private static var _searchHistory: SearchHistoryList?
    
    

    static func addItemToSearchHistory(_ text: String){
        
        initialize_searchHistory_ifNeeded()
        _searchHistory!.insert(newEntry: text)
        
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - AUDIO CHANNEL PANNING
    static var audioPanningPosition: Float{
        get{
            let defaults = UserDefaults.standard
            if defaults.value(forKey: audioPanningPositionKey) == nil{
                change_AudioPanningPositionTo(0)
            }
            return defaults.value(forKey: UserPreferences.audioPanningPositionKey) as! Float
        } set {
            UserPreferences.change_AudioPanningPositionTo(newValue)
        }
    }
    
    
    
    
    
    
    
    
    
    private static func change_AudioPanningPositionTo(_ position: Float){
        
        let defaults = UserDefaults.standard
        let key = UserPreferences.audioPanningPositionKey
        
        let position1 = max(-1 , min( position, 1))
        
        defaults.set(position1, forKey: key)
        AppManager.shared.audioPanningPositionWasSetTo(position)
        
    }
}



