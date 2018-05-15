//
//  YOUTUBE_APIManager.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import UserNotifications



// Learned how to do this from https://www.spaceotechnologies.com/fetch-youtube-videos-integrate-youtube-api-ios-app/

// Great JSON viewing site https://jsonformatter.curiousconcept.com


// Youtube suggestion site https://shreyaschand.com/blog/2013/01/03/google-autocomplete-api/




class YTAPIManager: NSObject {
    static var main = YTAPIManager()
    
    
    private let APIKey: NSString = "AIzaSyDXn6ZJ1Zi01Zlp8irQY0g_Z-WBgR7UDdc"
    
    
    
    
    
    // MARK: - GET RELATED VIDEOS
    
    
    func getRelatedVidoesTo(vidID: String, completion: @escaping ([YoutubeVideo]?, Error?) -> Void){
        
        
        
        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=\(vidID)&type=video&key=\(APIKey)" as NSString
        
        
        
        guard let urlString = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed), let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                print("There was an error in the 'getRelatedVidoesTo' function in the Youtube api manager class. \(error!)")
                completion(nil, error!)
                return
            }
        
            self.parseJSONFromYoutubeSearchResults(data: data!, completion: { (videoArray) in
                
                DispatchQueue.main.sync {
                    
                    
                    completion(videoArray, nil)
                }
            })
          
        }
        
        task.resume()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func handleDownloadOfVideoWithID(ID: String){
        
        getVideosFromYT_IDs([ID]) { (videoArray) in
            if videoArray.isEmpty{
                DispatchQueue.main.async {

                AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "A problem occured when attempting to download the video from your clipboard", completion: nil)
                }
                return
            }
            
            
            Downloader.main.beginDownloadOf(videoArray.first!)
            
        }
        
    }
    
    
    
    
    //MARK: - GET YOUTUBE SEARCH RESULTS
    
    func getYoutubeSearchResultsWith(searchText: String, amount: Int, completion: @escaping ([YoutubeVideo]?, Error?) -> Void){
        
        let url = prepareVideoSearchURLWith(amount: amount, searchText: searchText)
        
        
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            
            if error != nil{
                DispatchQueue.main.sync {
                    completion(nil, error)
                    
                }
                return
            }
            
            
            if let data = data {
                self.parseJSONFromYoutubeSearchResults(data: data, completion: { (videos) in
                    
                    DispatchQueue.main.sync {
                        
                        if videos.isEmpty{
                            
                            completion(nil, nil)
                        } else {
                            completion(videos, nil)
                        }
                    }
                })
            } else {
                DispatchQueue.main.sync {
                    
                    completion(nil, nil)}
                }
            
            }.resume()
    }
    
    
    
    
    private func prepareVideoSearchURLWith(amount: Int, searchText: String) -> URL{
        
        func countryCode() -> NSString{
            let local = NSLocale.current as NSLocale
            return local.object(forKey: NSLocale.Key.countryCode) as! NSString
        }
        
        
        let searchText = NSString(string: searchText)
        
        

        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(amount)&order=Relevance&q=\(searchText)&regionCode=\(countryCode())&type=video&key=\(APIKey)" as NSString


        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!
        let url = URL(string: urlString)!
        return url
    }
    
    
    
    enum JSONParsingError: Error{ case couldNotParse}
    
    private func parseJSONFromYoutubeSearchResults(data: Data, completion: @escaping ([YoutubeVideo]) -> Void) {
        
        
        
        
        do{
            guard let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {completion([]); return}
            guard let info = result["items"] as? Array<NSDictionary> else {completion([]); return}
            let youtubeIDs = EArray<String>()
            
            youtubeIDs.irateThrough(array: info) { (item) -> String? in
                guard let idDict = item["id"] as? NSDictionary else {return nil}
                guard let id = idDict["videoId"] as? String else {return nil}
                
                return id
            }
            
            
            
            getVideosFromYT_IDs(youtubeIDs.elements) { (videos) in
                completion(videos)
            }
            
        } catch {

            completion([])
        }
    }





    
    // MARK: - GET INFO FROM EACH VIDEO

    
    private func getVideosFromYT_IDs(_ IDs: [String], completion: @escaping ([YoutubeVideo]) -> Void){
        
        var videosToReturn = [(YoutubeVideo?, Int)](){
            didSet{
                if videosToReturn.count >= IDs.count{
                    
                    let videos = videosToReturn.sorted { $0.1 < $1.1}.filter{$0.0 != nil}.map{$0.0!}
                    
                    
                    completion(videos)
                }
            }
        }

        var x = 1
        for ID in IDs{
            let y = x
            guard let url = YoutubeVideo.getAppropriateURLForInit(from: ID, APIKey: APIKey as String) else { continue }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                    videosToReturn.append((nil, y))
                    return
                }
                if data == nil{videosToReturn.append((nil, y)); return}
            
                let newVideo = YoutubeVideo(data: data!)
                
                videosToReturn.append((newVideo, y))
                
            }
            
            task.resume()
            x += 1
        }
    }
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - GET AUTO COMPLETE SUGGESTIONS
    
    
    
    
    
    
    
    
    
    
}





























