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
    
    
    func getRelatedVidoesTo(vidID: String, completion: @escaping ([YoutubeVideo]) -> Void){
        
        
        
        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=\(vidID)&type=video&key=\(APIKey)" as NSString
        
        
        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)!
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                print(error!)
                return
            }
        
            self.parseJSONFromYoutubeSearchResults(data: data!, completion: { (videoArray) in
                
                DispatchQueue.main.sync {
                    completion(videoArray)
                }
            })
          
        }
        
        task.resume()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func handleDownloadOfVideoWithID(ID: String){
        
        getVideosFromYT_IDs([ID]) { (videoArray) in
            if videoArray.isEmpty{
                DispatchQueue.main.sync {

                AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "A problem occured when attempting to download the video from your clipboard", completion: nil); return
                }
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
            let urlStr = "https://www.googleapis.com/youtube/v3/videos?id=\(ID as NSString)&part=snippet,contentDetails,statistics&key=\(APIKey)" as NSString
            
            let urlStr2 = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let url = URL(string: urlStr2)!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                    videosToReturn.append((nil, y))
                    return
                }
                if data == nil{videosToReturn.append((nil, y)); return}
            
                let newVideo = self.constructYoutubeVideoFrom(data: data!)
                
                videosToReturn.append((newVideo, y))
                
            }
            
            task.resume()
            x += 1
        }
    }
    
    
    
    
    private func constructYoutubeVideoFrom(data: Data) -> YoutubeVideo? {
        do{
            
            guard let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {return nil}
            
            guard let items = result["items"] as? Array<NSDictionary> else {return nil}
            
            if items.isEmpty{return nil}
            let info = items[0]
            guard let id = info["id"] as? String else {return nil}
            guard let snippet = info["snippet"] as? NSDictionary else {return nil}
            guard let dateString = snippet["publishedAt"] as? String else {return nil}
            
            
            guard let liveBroadcastContent = snippet["liveBroadcastContent"] as? String else {return nil}
            if liveBroadcastContent == "live" {return nil}
            
            
            let thumbnailURL: String! = {
                
                guard let thumbnailInfo = snippet["thumbnails"] as? NSDictionary else {return nil}
                
                
                if let thumbnailDict = thumbnailInfo["maxres"] as? NSDictionary,
                    let url = thumbnailDict["url"] as? String{
                        return url
                }
                if let thumbnailDict = thumbnailInfo["standard"] as? NSDictionary,
                    let url = thumbnailDict["url"] as? String{
                    return url
                }
                if let thumbnailDict = thumbnailInfo["high"] as? NSDictionary,
                    let url = thumbnailDict["url"] as? String{
                    return url
                }
                return nil
            }()
            
            if thumbnailURL == nil{return nil}
            
            guard let title = snippet["title"] as? String else {return nil}
            guard let channelTitle = snippet["channelTitle"] as? String else {return nil}
            guard let contentDetails = info["contentDetails"] as? NSDictionary else {return nil}
            guard let durationString = contentDetails["duration"] as? String else {return nil}
            guard let statistics = info["statistics"] as? NSDictionary else {return nil}
            
            guard let viewCount = statistics["viewCount"] as? String else {return nil}
            
            
            let formattedViewsString = getYTFormattedViewsFrom(numberOfViews: viewCount)
            
            let formattedTimeString = getYoutubeFormattedDurationFrom(string: durationString)
            
            guard let url = URL(string: thumbnailURL) else {return nil}
            
            
            
           
            guard let date = getYTFormattedPublishedAtDateString(from: dateString) else {return nil}
            
            
            
            
            let videoToReturn = YoutubeVideo(name: title, videoID: id, channel: channelTitle, thumbnailLink: url , duration: formattedTimeString, views: formattedViewsString, date: date)
            
            return videoToReturn
        } catch{
            return nil
        }
    }
    
    
    
    
    
    
    
    
    
    private func getYTFormattedPublishedAtDateString(from string: String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"

        guard let date = dateFormatter.date(from: string) else {return nil}
        
        let seconds = -date.timeIntervalSinceNow
        let minutes = seconds / 60.0
        let hours = minutes / 60.0
        let days =  hours / 24.0
        let weeks = days / 7.0
        let months = days / 30
        let years = days / 365.0
        
        
        if seconds < 60{
            
            let seconds1 = Int(seconds.rounded())
            return "\(seconds1) \(seconds1 == 1 ? "second" : "seconds") ago"
        
        } else if minutes < 60 {
            
            let minutes1 = Int(minutes.rounded())
            return "\(minutes1) \(minutes1 == 1 ? "minute" : "minutes") ago"
        
        } else if hours < 24 {
        
            let hours1 = Int(hours.rounded())
            return "\(hours1) \( hours1 == 1 ? "hour" : "hours") ago"
        
        } else if days < 7 {
            
            let days1 = Int(days.rounded())
            return "\(days1) \( days1  == 1 ? "day" : "days") ago"
        
        } else if days < 30 {
            
            let weeks1 = Int(weeks.rounded())
            return "\(weeks1) \(weeks1 == 1 ? "week" : "weeks") ago"
        
        } else if days < 365 {
        
            let months1 = Int(months.rounded())
            return "\(months1) \(months1 == 1 ? "month" : "months") ago"
    
        } else {
            
            let years1 = Int(years.rounded())
            return "\(years1) \(years1 == 1 ? "year" : "years") ago"
        
        }
    
    }
    
    
    
    // MARK: - FORMAT THE NUMBER OF VIEWS
    private func getYTFormattedViewsFrom(numberOfViews: String) -> String{
        
        guard let viewsInt = Double(numberOfViews) else { return "000"}
        var stringToReturn = " "
        
        // BILLIONS
        if viewsInt >= 1000000000{
            let x = viewsInt / 1000000000
            stringToReturn = String(format: "%.1f", x).replacingOccurrences(of: ".0", with: "") + "B views"
            
        // MILLIONS
        } else if viewsInt >= 1000000{
            let x = viewsInt / 1000000.0
            stringToReturn = ((x >= 10) ? String(Int(x.rounded())) : String(format: "%.1f", x)).replacingOccurrences(of: ".0", with: "") + "M views"
        
        // THOUSANDS
        } else if viewsInt >= 1000{
            let x = viewsInt / 1000.0
            stringToReturn = String(Int(x.rounded())) + "K views"
        
        // HUNREDS
        } else {stringToReturn = String(Int(viewsInt.rounded())) + " views"}

        return stringToReturn
    }
    
    
    // MARK: - DEAL WITH YOUTUBE'S RETARDED DURATION STRING
    
    private func getYoutubeFormattedDurationFrom(string: String) -> String {
        var currentComponent: Character?
        var currentNumber = ""
        
        var componentsDict = [Character : String]()
        
        for x in string.reversed(){
            if x.isLetter{
                if currentComponent == nil{
                    currentComponent = x
                    continue
                }
                if currentNumber != "" && currentComponent != nil{
                    componentsDict[currentComponent!] = String(currentNumber)
                }
                currentComponent = x
                currentNumber = ""
            }
            if x.isNumber{ currentNumber = String(x) + currentNumber }
        }
        let D = componentsDict["D"]
        let H = componentsDict["H"]
        let M = componentsDict["M"]
        let S = componentsDict["S"]
        
        var tempArray = [String]()
        [D, H, M, S].forEach{ tempArray.append($0 ?? "00") }
        
        var y = 0
        for x in tempArray{
            if y == 0 && x == "00" && tempArray.count != 2{
                tempArray.remove(at: y)
                y -= 1
            }
            if x.count == 1 && y != 0 {tempArray[y] = "0" + tempArray[y]}
            if tempArray[0] == "00" {tempArray[0] = "0"}
            
            y += 1
        }
        if D != nil {
            let newHours = (Int(D!)! * 24) + Int(H ?? "0")!
            tempArray.remove(at: 0)
            tempArray[0] = String(newHours)
        }
        let stringToReturn = tempArray.joined(separator: ":")
        return stringToReturn
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - GET AUTO COMPLETE SUGGESTIONS
    
    func getAutoCompleteSuggestionsFrom(searchText: String, completion: @escaping ([String]) -> Void){
        
        let urlString: NSString = "https://suggestqueries.google.com/complete/search?hl=en&ds=yt&q=\(searchText as NSString)&client=firefox" as NSString
        
        let urlString2 = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let url = URL(string: urlString2)!
        

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.sync {
                let resultingStrings = self.parseJSONForSuggestionsFrom(data: data!)
                completion(resultingStrings)
            }
        }
        task.resume()
    }
    
    
    private func parseJSONForSuggestionsFrom(data: Data) -> [String]{
        var arrayToReturn = [String]()
        do{
            let resultsArray1 = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
            
            let resultsArray = resultsArray1[1] as! Array<String>
            
            arrayToReturn = resultsArray
            
        } catch{ print(error)}
        
        return arrayToReturn
    }
    
    
    
    
    
    
    
    
}





























