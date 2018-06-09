//
//  Ugly_YoutubeVideo_JSONParsing.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit




extension YoutubeVideo{
    
    
    static func getAppropriateURLForInit(from videoID: String, APIKey: String) -> URL?{
        
        let urlStr = "https://www.googleapis.com/youtube/v3/videos?id=\(videoID as NSString)&part=snippet,contentDetails,statistics&key=\(APIKey)" as NSString
        
        guard let urlStr2 = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {return nil}
        
        return URL(string: urlStr2)
     }
    
    
    
    
    convenience init?(data: Data){
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
            
            guard let thumbnailInfo = snippet["thumbnails"] as? NSDictionary else {return nil}

            
            let highQuality_thumbnailString: String! = {
            
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
            
            if highQuality_thumbnailString == nil{return nil}
            
            guard let thumbnailDict = thumbnailInfo["high"] as? NSDictionary,
                let lowQuality_thumbnailString = thumbnailDict["url"] as? String else { return nil }
            
            guard let title = snippet["title"] as? String else {return nil}
            guard let channelTitle = snippet["channelTitle"] as? String else {return nil}
            guard let contentDetails = info["contentDetails"] as? NSDictionary else {return nil}
            guard let durationString = contentDetails["duration"] as? String else {return nil}
            guard let statistics = info["statistics"] as? NSDictionary else {return nil}
            
            guard let viewCount = statistics["viewCount"] as? String else {return nil}
            
            
            let formattedViewsString = getYTFormattedViewsFrom(numberOfViews: viewCount)
            
            let formattedTimeString = getYoutubeFormattedDurationFrom(string: durationString)
            
            guard let highQualUrl = URL(string: highQuality_thumbnailString) else {return nil}
            guard let lowQualURL = URL(string: lowQuality_thumbnailString) else {return nil}
            
            
            
            guard let date = getYTFormattedPublishedAtDateString(from: dateString) else {return nil}
            
            
            
            self.init(name: title, videoID: id, channel: channelTitle, thumbnailLink_highQuality: highQualUrl, thumbnailLink_lowQuality: lowQualURL, duration: formattedTimeString, views: formattedViewsString, date: date)
            
            
        } catch {
            return nil
        }
    }
}














fileprivate func getYTFormattedPublishedAtDateString(from string: String) -> String?{
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


fileprivate func getYTFormattedViewsFrom(numberOfViews: String) -> String{
    
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

fileprivate func getYoutubeFormattedDurationFrom(string: String) -> String {
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














