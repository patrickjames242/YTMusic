//
//  SearchSuggestionsBrain.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




protocol SearchSuggestionsBrainDelegate {
    
    func searchSuggestions(didChangeTo suggestions: [String], type: SuggestionsType)

}


enum SuggestionsType{ case loaded, history}




class SearchSuggestionsBrain: SearchHistoryDelegate{
    
    
    
    private let owner: SearchSuggestionsBrainDelegate
    
    private var currentSuggestionsType: SuggestionsType
    
    
    
    init(owner: SearchSuggestionsBrainDelegate){
        
        self.owner = owner
        self.currentSuggestionsType = .history
        owner.searchSuggestions(didChangeTo: DBHistory.searchHistory, type: .history)
        DBHistory.searchHistoryDelegate = self
    }
    
    func allSongsWereRemovedFromSearchHistory() {
        sendUpdatedHistory()
    }
    
    
    
    func searchTextDidChangeTo(text: String?){
        currentTextInSearchBar = text
        guard let text = text, !text.removeWhiteSpaces().isEmpty else { sendUpdatedHistory(); return }
        
        sendUpatedLoadedSuggestions(for: text)
        
    }
    
    
    func userDidPressSearch(for text: String){
        
        DBHistory.addItemToSearchHistory(text)
        
        if currentSuggestionsType == .history{
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                self.sendUpdatedHistory()
                timer.invalidate()
            }
        }
    }
    
    
    
    
    
    private func sendUpdatedHistory(){
        self.currentSuggestionsType = .history
        owner.searchSuggestions(didChangeTo: DBHistory.searchHistory, type: .history)
        
        
    }
    
    private var currentTextInSearchBar: String?
    
    
    private func sendUpatedLoadedSuggestions(for text: String){
        
        getAutoCompleteSuggestionsFrom(searchText: text) { (stringArray) in
            if self.currentTextInSearchBar != text{return}
            
            self.currentSuggestionsType = .loaded
            self.owner.searchSuggestions(didChangeTo: stringArray, type: .loaded)
        }
    }
    
    
    func userDidRemoveEntry(text: String){
        
        DBHistory.removeItemFromSearchHistory(text)
        
        
    }
    
    
    
}






















fileprivate func getAutoCompleteSuggestionsFrom(searchText: String, completion: @escaping ([String]) -> Void){
    
    let urlString: NSString = "https://suggestqueries.google.com/complete/search?hl=en&ds=yt&q=\(searchText as NSString)&client=firefox" as NSString
    
    let urlString2 = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    
    let url = URL(string: urlString2)!
    
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if error != nil{
            print(error!)
            return
        }
        DispatchQueue.main.sync {
            let resultingStrings = parseJSONForSuggestionsFrom(data: data!)
            completion(resultingStrings)
        }
    }
    task.resume()
}




fileprivate func parseJSONForSuggestionsFrom(data: Data) -> [String]{
    var arrayToReturn = [String]()
    do{
        let resultsArray1 = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
        
        let resultsArray = resultsArray1[1] as! Array<String>
        
        arrayToReturn = resultsArray
        
    } catch{ print(error) }
    
    return arrayToReturn
}

















