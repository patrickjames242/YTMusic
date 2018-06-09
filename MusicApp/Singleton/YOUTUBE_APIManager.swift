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


func checkForDoubleVideo(videos: [YoutubeVideo], functionName: String){
    
//    for video in videos{
//        let filteredVids = videos.filter{$0.videoID == video.videoID}
//        
//        if filteredVids.count > 1{
//            print(functionName + " has attempted to return \(filteredVids.count) repeated videos. Here is the video that was repeated: \(video.name)")
//        }
//    }
    
    
}


// Learned how to do this from https://www.spaceotechnologies.com/fetch-youtube-videos-integrate-youtube-api-ios-app/

// Great JSON viewing site https://jsonformatter.curiousconcept.com


// Youtube suggestion site https://shreyaschand.com/blog/2013/01/03/google-autocomplete-api/





struct YoutubeSearchResponse{
    
    let videos: [YoutubeVideo]
    let moreResultsCode: String?
    let error: Error?
    let searchText: String?
    
}



class YTAPIManager: NSObject {
    static var main = YTAPIManager()
    
    
    private let APIKey: NSString = "AIzaSyDXn6ZJ1Zi01Zlp8irQY0g_Z-WBgR7UDdc"
    
    
    

    
    
    
    // MARK: - GET RELATED VIDEOS
    
    
    func getRelatedVidoesTo(vidID: String, completion: @escaping (YoutubeSearchResponse) -> Void){
        
        
        
        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=\(vidID)&type=video&key=\(APIKey)" as NSString
        
        
        
        guard let urlString = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed), let url = URL(string: urlString) else {
            completion(YoutubeSearchResponse(videos: [], moreResultsCode: nil, error: nil, searchText: nil))
            return
        }
        
        
        
        activateYoutubeSearchDataTask(with: url, searchText: nil, completion: {completion($0)})
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func handleDownloadOfVideoWithID(ID: String){
        
        getVideosFromYT_IDs([ID]) { (videoArray) in
            if videoArray.isEmpty{
                DispatchQueue.main.async {

                AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "A problem occured when attempting to download the video from your clipboard", completion: nil)
                }
                return
            }
            
            checkForDoubleVideo(videos: videoArray, functionName: #function)
            
            
            Downloader.main.beginDownloadOf(videoArray.first!)
            
        }
        
    }
    
    
    
    
    //MARK: - GET YOUTUBE SEARCH RESULTS
    
    
    
    
    
    
    
    func getNextPageOfYoutubeSearchResults(using previousResponse: YoutubeSearchResponse, amount: Int, completion: @escaping (YoutubeSearchResponse) -> Void){
        
        guard let searchText = previousResponse.searchText, let pageToken = previousResponse.moreResultsCode else {
            completion(YoutubeSearchResponse(videos: [], moreResultsCode: previousResponse.moreResultsCode, error: nil, searchText: previousResponse.searchText))
            return
        }
        
        
        let url = prepareVideoSearchURLWith(amount: amount, searchText: searchText, previousNextPageToken: pageToken)
        
        activateYoutubeSearchDataTask(with: url, searchText: searchText, completion: {completion($0)})
        
        
    }
    
    
    
    
    
    
    
    func getYoutubeSearchResultsWith(searchText: String, amount: Int, completion: @escaping (YoutubeSearchResponse) -> Void){
        
        let url = prepareVideoSearchURLWith(amount: amount, searchText: searchText)
        
        activateYoutubeSearchDataTask(with: url, searchText: searchText, completion: {completion($0)})
        
        
    }
    
    
    private func activateYoutubeSearchDataTask(with url: URL, searchText: String?, completion: @escaping (YoutubeSearchResponse) -> Void){
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            
            if error != nil{
                DispatchQueue.main.sync {
                    completion(YoutubeSearchResponse(videos: [], moreResultsCode: nil, error: error, searchText: searchText))
                    
                }
                return
            }
            
            
            if let data = data {
                self.parseJSONFromYoutubeSearchResults(data: data, completion: { (videos, nextPageToken)  in
                    
                    DispatchQueue.main.sync {
                        checkForDoubleVideo(videos: videos, functionName: #function)
                        completion(YoutubeSearchResponse(videos: videos, moreResultsCode: nextPageToken, error: nil, searchText: searchText))
                    }
                })
            } else {
                DispatchQueue.main.sync {
                    
                    completion(YoutubeSearchResponse(videos: [], moreResultsCode: nil, error: nil, searchText: searchText))}
            }
            
            }.resume()
    }
    
    
    
    
    private func prepareVideoSearchURLWith(amount: Int, searchText: String, previousNextPageToken: String? = nil) -> URL{
        
        func countryCode() -> NSString{
            let local = NSLocale.current as NSLocale
            return local.object(forKey: NSLocale.Key.countryCode) as! NSString
        }
        
        
        let searchText = NSString(string: searchText)
        
        

        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=\(amount)&order=Relevance&q=\(searchText)&regionCode=\(countryCode())&type=video&key=\(APIKey)\((previousNextPageToken != nil) ? "&pageToken=\(previousNextPageToken!)" : "" )" as NSString


        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!
        let url = URL(string: urlString)!
        return url
    }
    
    
    
    
    private func parseJSONFromYoutubeSearchResults(data: Data, completion: @escaping ([YoutubeVideo], _ moreResultsCode: String?) -> Void) {
        
        
        
        
        do{
            guard let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {completion([], nil); return}
            guard let info = result["items"] as? Array<NSDictionary> else {completion([], nil); return}
            let nextPageToken = result["nextPageToken"] as? String
            let youtubeIDs = EArray<String>()
            
            youtubeIDs.irateThrough(array: info) { (item) -> String? in
                guard let idDict = item["id"] as? NSDictionary else {return nil}
                guard let id = idDict["videoId"] as? String else {return nil}
                
                return id
            }
            
            
            
            getVideosFromYT_IDs(youtubeIDs.elements) { (videos) in
                checkForDoubleVideo(videos: videos, functionName: #function)
                completion(videos, nextPageToken)
            }
            
        } catch {

            completion([], nil)
        }
    }





    
    // MARK: - GET INFO FROM EACH VIDEO

    
    private func getVideosFromYT_IDs(_ IDs: [String], completion: @escaping ([YoutubeVideo]) -> Void){
        
        var videosToReturn = [(YoutubeVideo?, Int)](){
            didSet{
                if videosToReturn.count >= IDs.count{
                    
                    let videos = videosToReturn.sorted { $0.1 < $1.1}.filter{$0.0 != nil}.map{$0.0!}
                    
                    checkForDoubleVideo(videos: videos, functionName: #function)
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
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}





























