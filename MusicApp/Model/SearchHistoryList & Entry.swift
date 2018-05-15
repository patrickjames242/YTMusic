//
//  SearchHistoryEntry.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation


fileprivate struct SearchHistoryEntry: Codable, Equatable{
    
    var text: String
    var date: Date
}







class SearchHistoryList: Codable{
    
    
    
    private var objectDeletionThreshold = 40
    
    
    private var list: [SearchHistoryEntry]
    

    
    var entryList: [String]{
        sortList()
        return list.map{$0.text}
    }
    
    private func sortList(){
        
        list.sort { $0.date > $1.date }

    }
    
    
    func insert(newEntry: String){
        let text = newEntry.removeWhiteSpaces()
        
        list = list.filter{$0.text != text}
        
        
        let newHistoryEntry = SearchHistoryEntry(text: text, date: Date())
        list.append(newHistoryEntry)
        sortList()
        while list.count > objectDeletionThreshold{
            list.removeLast()
        }
        
        
    }
    
    func remove(entry: String){
        
        list = list.filter{$0.text != entry}
        sortList()
        
    }
    
    
    func removeAll(){
        list.removeAll()
    }
    
    
    
    
    
    
    var data: Data? {
        
        do {
            let data = try PropertyListEncoder().encode(self)
            return data
            
        } catch {
            print("an error occured when converting a SearchHistoryKey object to data: \(error)")
            return nil
        }
    }
    
    
    init() {
        self.list = []
    }
    
    
    init?(data: Data){
        
        do{
            let fetchedList = try PropertyListDecoder().decode(SearchHistoryList.self, from: data)
            self.list = fetchedList.list
        }
        catch {
            print("error in the init for SearchHistoryEntry: \(error)")
            return nil
        }
        
    }
    
    
    
    
    
    
}























