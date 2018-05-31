//
//  PlaybackHistoryBrain.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import Foundation




fileprivate class PlaybackHistoryBrain: NSObject{

    private var historyDict = [Date: [Song]]()
    
    
    
 
 
    var orderedHistory: [(date: Date, songArray: [Song])]{
        return historyDict.sorted { $0.key > $1.key } as! [(date: Date, songArray: [Song])]
    }
 
    
    
    
    func orderedHistoryStrings(currentStackDate: Date) -> [String]{
        
        return orderedHistory.map { (arg) -> String in
            
            if currentStackDate == arg.date{
                return "Current"
            } else if Calendar.current.isDateInToday(arg.date){
                return "Earlier Today"
            } else if Calendar.current.isDateInYesterday(arg.date){
                return "Yesterday"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: arg.date)
            }
        }
    }
    
    var nestedHistoryArray: [[Song]]{
        return orderedHistory.map { $0.songArray }
    }
    
    func wrapStackWithHistory(currentStack: [Song], startDate: Date) -> (historyArray:[[Song]], stringArray: [String]){
        
        historyDict[startDate] = currentStack
 
 
        
 
 
        return (nestedHistoryArray, orderedHistoryStrings(currentStackDate: startDate))
 
    }
 
    
 
    
}
 




