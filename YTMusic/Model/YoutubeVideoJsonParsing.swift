//
//  YoutubeVideoJsonParsing.swift
//  YTMusic
//
//  Created by Patrick Hanna on 10/20/19.
//  Copyright © 2019 Patrick Hanna. All rights reserved.
//

import UIKit



private struct YoutubeVideosResponse: Codable{
    
    struct Item: Codable{
        struct ContentDetails: Codable{
            let duration: String
        }
        struct Snippet: Codable{
            
            struct Thumbnails: Codable{
                struct Thumbnail: Codable{
                    let url: String
                }
                let `default`: Thumbnail?
                let maxres: Thumbnail?
                let high: Thumbnail?
                let medium: Thumbnail?
                let standard: Thumbnail?
            }
            let channelTitle: String
            let publishedAt: String
            let thumbnails: Thumbnails
            let title: String
        }
        struct Statistics: Codable{
            let viewCount: String
        }
        
        let id: String
        let contentDetails: ContentDetails
        let snippet: Snippet
        let statistics: Statistics
        
        
        
    }
    
    let items: [Item]
    
    
}





class YoutubeResponseParser{
    
 
    static func parseVideoList(JSON_Response_Data: Data) throws -> [YoutubeVideo]{
        let responseObj = try JSONDecoder().decode(YoutubeVideosResponse.self, from: JSON_Response_Data)
        return responseObj.items.compactMap{getYoutubeVideoObject(from: $0)}
    }
    
    
    private static func getYoutubeVideoObject(from ytVideoResponse: YoutubeVideosResponse.Item) -> YoutubeVideo?{
        
        let snippet = ytVideoResponse.snippet
        let contentDetails = ytVideoResponse.contentDetails
        let statistics = ytVideoResponse.statistics
        let thumbnails = ytVideoResponse.snippet.thumbnails
        
        guard let hqThumbnailLink = (thumbnails.maxres?.url ?? thumbnails.high?.url ?? thumbnails.medium?.url).flatMap({URL(string: $0)}),
            let lqThumbnailLink = (thumbnails.standard?.url ?? thumbnails.medium?.url).flatMap({URL(string: $0)}),

            let durationInSeconds = getSecondsFrom(durationString: contentDetails.duration),
            let durationString = getDurationStringFrom(numberOfSeconds: durationInSeconds),
        
            let dateString = getPublishedAtDateString(from: snippet.publishedAt),
            let viewCount = Int(statistics.viewCount)
            
            else {return nil}
        
        let viewCountString = getNumberOfViewsString(numberOfViews: viewCount)
        
        return YoutubeVideo(name: snippet.title,
                            videoID: ytVideoResponse.id,
                            channel: snippet.channelTitle,
                            thumbnailLink_highQuality: hqThumbnailLink,
                            thumbnailLink_lowQuality: lqThumbnailLink,
                            duration: durationString,
                            views: viewCountString,
                            date: dateString)
        
    }
    
    private static func getNumberOfViewsString(numberOfViews: Int) -> String{
        
        return {() -> String in
            
            if numberOfViews < 1000{
                return String(numberOfViews)
            }
                    
            func round(_ number: Double) -> Double{
                return number > 10 ? number.roundedTo(numberOfDecimalPlaces: 0) : number.roundedTo(numberOfDecimalPlaces: 1)
            }
            
            func stringify(_ number: Double) -> String{
                return number.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(number)) : String(number)
            }
            
            let numOfThousands = round(Double(numberOfViews) / 1000)
            let numOfMillions = round(Double(numberOfViews) / 1000000)
            let numOfBillions = round(Double(numberOfViews) / 1000000000)
            
            if numOfThousands < 1000 {
                return stringify(numOfThousands) + "K";
            } else if numOfMillions < 1000 {
                return stringify(numOfMillions) + "M";
            } else {
                return stringify(numOfBillions) + "B";
            }
        }() + " views"
        
    }
    
    
    private static func getSecondsFrom(durationString: String) -> TimeInterval?{
        
        struct DurationComponent{
            enum Unit: String{
                case day = "D", hour = "H", minute = "M", second = "S"
                var amountOfSeconds: Int{
                    switch self{
                    case .day: return 60 * 60 * 24
                    case .hour: return 60 * 60
                    case .minute: return 60
                    case .second: return 1
                    }
                }
            }
            let unit: Unit
            let amount: Int
            
            var expressedInSeconds: Int{
                return unit.amountOfSeconds * amount
            }
        }
        
        let durationComponentsParser = Parser { input -> (DurationComponent, String)? in
            guard let integerParsingResult = Parsers.integer.parse(input),
                let wordParsingResult = Parsers.word.parse(integerParsingResult.1),
                let unit = DurationComponent.Unit(rawValue: wordParsingResult.0)
                else {return nil}
            return (DurationComponent(unit: unit, amount: integerParsingResult.0), wordParsingResult.1)
        }.ignoreSpaces.many.firstOccurance
        
        guard let components = durationComponentsParser.parse(durationString)?.0 else {return nil}
        
        return Double(components.reduce(0, { $0 + $1.expressedInSeconds}))
        
    }
    
    
    private static let durationStringFormatter: DateComponentsFormatter = {
        let x = DateComponentsFormatter()
        x.calendar = Calendar(identifier: .gregorian)
        return x
    }()
    
    
    private static func getDurationStringFrom(numberOfSeconds: TimeInterval) -> String?{
        if numberOfSeconds < 60{
            durationStringFormatter.zeroFormattingBehavior = .pad
            durationStringFormatter.allowedUnits = [.minute, .second]
        } else {
            durationStringFormatter.zeroFormattingBehavior = .dropLeading
            durationStringFormatter.allowedUnits = [.hour, .minute, .second]
        }
        return durationStringFormatter.string(from: numberOfSeconds)
    }
    
    
    private static let publishedDateStringFormatter: DateFormatter = {
        let x = DateFormatter()
        x.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        return x
    }()
    
    private static func getPublishedAtDateString(from string: String) -> String?{
        guard let date = publishedDateStringFormatter.date(from: string) else {return nil}
        
        let seconds = Date().timeIntervalSince(date)
        
        if (-61...59).contains(Int(seconds.rounded())){
            return "just now"
        }
        
        typealias Unit = (text: String, amount: Double, threshold: Int)
        let units: [Unit] = [("minute", seconds/60, 60),
                             ("hour", seconds/60/60, 24),
                             ("day", seconds/60/60/24, 7),
                             ("week", seconds/60/60/24/7, 5),
                             ("month", seconds/60/60/24/30, 12),
                             ("year", seconds/60/60/24/375, -1)
        ]
        for unit in units {
            let intVal = Int(unit.amount.rounded())
            if intVal < unit.threshold || unit == units.last!{
                return String(intVal) + " " + unit.text + (intVal == 1 ? "" : "s") + " ago"
            }
        }
        fatalError("Should return before it breaks out of the forloop. Check the logic.")
    }
    
    
}

