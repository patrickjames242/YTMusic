//
//  AudioPanning.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation


class DBPanning{
    
    private static let audioPanningPositionKey = "audio Panning position"
    private static let audioPanningToggleKey = "audio panning toggle"
    
    /// This is the value that is used for the AVAudioPlayer's pan variable
    static var audioPanningPositionToUse: Float{
        if !audioPanningIsOn{return 0}
        return currentAudioPanningPosition
    }
    
    
    /// This variable is set in Settings when the user changes the pan position
    static var currentAudioPanningPosition: Float{
        get{
            
            if !audioPanningIsOn{return 0}
            
            let defaults = UserDefaults.standard
            
            
            if defaults.value(forKey: audioPanningPositionKey) == nil{
                change_AudioPanningPositionTo(0)
            }
            return defaults.value(forKey: audioPanningPositionKey) as! Float
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
        let key = audioPanningPositionKey
        
        let position1 = max(-1 , min( position, 1))
        
        defaults.set(position1, forKey: key)
        NotificationCenter.default.post(name: AudioPanningStateDidChangeNotification, object: self)
    }
}




let AudioPanningStateDidChangeNotification = Notification.Name("AudioPanningDidChangeNotification")

