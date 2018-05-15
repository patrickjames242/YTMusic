//
//  UserPreferences_UserDefaults.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




protocol SearchHistoryDelegate{
    
    func allSongsWereRemovedFromSearchHistory()
    
}


final class UserPreferences{
    
    private static func deleteAllHistory(){
        
        UserDefaults.standard.removeObject(forKey: searchHistoryKey)
        
    }
    
    // DONT MESS WITH THESE STRINGS!!!!!!! YOUR GONNA MESS SOME STUFF UP!!!!!
    
    private static let audioPanningPositionKey = "audio Panning position"
    private static let audioPanningToggleKey = "audio panning toggle"
    private static let searchHistoryKey = "SEARCH HISTORY KEY"
    private static let appThemeColorKey = "APP THEME COLOR KEY"
    
    
    
    // MARK: - SEARCH HISTORY
    
    
    
    
    static var searchHistoryDelegate: SearchHistoryDelegate?

    
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static var DEFAULT_APP_THEME_COLOR = UIColor.red
    
    
    static var currentAppThemeColor: UIColor{
        
        
        get {
            
            if let color = UserDefaults.standard.color(forKey: appThemeColorKey){
                return color
            }
            let defaultColor = DEFAULT_APP_THEME_COLOR
            UserDefaults.standard.set(defaultColor, forKey: appThemeColorKey)
            return defaultColor
            
        } set {
            
            UserDefaults.standard.set(newValue, forKey: appThemeColorKey)
            
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
            change_AudioPanningPositionTo(newValue)
        }
    }
    
    
    
    
    
    static var audioPanningIsOn: Bool{
        get{
            return UserDefaults.standard.bool(forKey: audioPanningToggleKey)
        }
        
        set{
            
            UserDefaults.standard.set(newValue, forKey: audioPanningToggleKey)
            NotificationCenter.default.post(name: AudioPanningStateDidChangeNotification, object: nil, userInfo: nil)
        }
        
        
    }
    
    
    
    private static func change_AudioPanningPositionTo(_ position: Float){
        
        let defaults = UserDefaults.standard
        let key = UserPreferences.audioPanningPositionKey
        
        let position1 = max(-1 , min( position, 1))
        
        defaults.set(position1, forKey: key)
        NotificationCenter.default.post(name: AudioPanningStateDidChangeNotification, object: self)
    }
}

let AudioPanningStateDidChangeNotification = Notification.Name("AudioPanningDidChangeNotification")





