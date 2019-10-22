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






struct YoutubeSearchResponse{
    
    let videos: [YoutubeVideo]
    let moreResultsCode: String?
    let searchText: String
    
}


class YTAPIManager{
    
    

    private static let apiKey = "AIzaSyDvO-B0N8F6yG_Yh2_7PiEpp1r9dTHiiaE"
    
    static func getURLFor(string: String) -> URL?{
        return URL(string: (string as NSString).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
    }
    
    static func getSearchResultsFor(searchText: String, numberOfResults: Int = 20, pageToken: String? = nil, completion: @escaping (CompletionResult<YoutubeSearchResponse>) -> ()){
        let numberOfResults = max(min(numberOfResults, 50), 1)
        
        var urlString = "https://www.googleapis.com/youtube/v3/search?key=\(self.apiKey)&part=snippet&maxResults=\(numberOfResults)&q=\(searchText)&type=video"
        if let pageToken = pageToken{
            urlString += "&pageToken=" + pageToken
        }
        
        

        fetchJSON(url: getURLFor(string: urlString)!) { result in
            switch result{
            case .success(let data):
                do{
                    let (ids, nextPageToken) = try getVideoIdsAndNextPageTokenFrom(ytJsonResponse: data)
                    
                    fetchVideosForVideoIDs(ids: ids, completion: { result1 in
                        completion(result1.map{
                            YoutubeSearchResponse(videos: $0, moreResultsCode: nextPageToken, searchText: searchText)
                        })
                    })
                    
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    
    static func getRecommendedVideosForVideoWith(videoID: String, numberOfResults: Int = 20, completion: @escaping (CompletionResult<[YoutubeVideo]>) -> ()){
        let numberOfResults = max(min(numberOfResults, 50), 1)
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?key=\(self.apiKey)&part=snippet&maxResults=\(numberOfResults)&type=video&relatedToVideoId=\(videoID)"
        
        
        fetchJSON(url: getURLFor(string: urlString)!) { result in
            switch result{
            case .success(let data):
                do{
                    let (ids, _) = try getVideoIdsAndNextPageTokenFrom(ytJsonResponse: data)
                    
                    fetchVideosForVideoIDs(ids: ids, completion: completion)
                    
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    static func handleDownloadOfVideoWithID(ID: String){
        getVideoFor(videoId: ID) { result in
            switch result{
            case .success(let video):
                Downloader.main.beginDownloadOf(video)
            case .failure:
                AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "A problem occured when attempting to download the video from your clipboard", completion: nil)
            }
            
        }
            
    }
    
    static func getVideoFor(videoId: String, completion: @escaping (CompletionResult<YoutubeVideo>) -> ()){
        fetchVideosForVideoIDs(ids: [videoId]) { result in
            completion(result.flatMap{
                if let video = $0.first{
                    return .success(video)
                } else {return .failure(GenericError.unknownError)}
            })
        }
    }
    
    
    private static func getVideoIdsAndNextPageTokenFrom(ytJsonResponse: Data) throws -> (ids: [String], nextPageToken: String?){
        guard let dictionary = try JSONSerialization.jsonObject(with: ytJsonResponse, options: []) as? NSDictionary,
        let items = dictionary["items"] as? Array<NSDictionary>
        else {throw GenericError.unknownError}
        
        let nextPageToken = dictionary["nextPageToken"] as? String
        let videoIDs = items.compactMap({($0["id"] as? NSDictionary)?["videoId"] as? String})
        
        return (videoIDs, nextPageToken)
    }
    
    static func fetchVideosForVideoIDs(ids: [String], completion: @escaping (CompletionResult<[YoutubeVideo]>) -> ()){
        let joinedIDs = ids.joined(separator: ",")
        let url = URL(string: "https://www.googleapis.com/youtube/v3/videos?key=\(self.apiKey)&part=snippet,contentDetails,statistics&id=\(joinedIDs)")!
        
        fetchJSON(url: url) { callback in
            
            completion(callback.flatMap({ data in
                return CompletionResult(catching: {
                    return try YoutubeResponseParser.parseVideoList(JSON_Response_Data: data)
                })
            }))
        
        }
    }
    
    
    static func fetchJSON(url: URL, completion: @escaping (CompletionResult<Data>) -> ()){
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async{
                if let data = data{
                    completion(.success(data))
                } else {
                    completion(.failure(error ?? GenericError.unknownError))
                }
            }
            
        }.resume()
    }
    
    
}
