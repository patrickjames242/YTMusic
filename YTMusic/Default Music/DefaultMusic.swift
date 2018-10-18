//
//  DefaultMusic.swift
//  MusicApp
//
//  Created by Patrick Hanna on 10/18/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import UIKit
import CoreData





class DefaultMusic{
    
    private static let musicInstalledKey = "HAS DEFAULT MUSIC HAS BEEN INSTALLED?"
    
    
    static func configure(){
        if UserDefaults.standard.bool(forKey: musicInstalledKey) == false{
            for song in getDefaultSongs(){
                if songExists(for: song.youtubeID){continue}
                
                Song.createNew(from: song)
            }
            UserDefaults.standard.set(true, forKey: musicInstalledKey)
        }
    }
    
    
    private static func getDefaultSongs() -> [TempDBSong]{
        let url = Bundle.main.url(forResource: "DefaultMusicInfo", withExtension: "plist")!
        let items = NSDictionary(contentsOf: url)!["items"] as! Array<Dictionary<String, String>>
        
        let tempSongs = items.map { (item) -> TempDBSong in
            let imageURL = Bundle.main.url(forResource: item["name"], withExtension: "jpg")!
            let audioDataURL = Bundle.main.url(forResource: item["name"], withExtension: "mp3")!
            let image = UIImage(data: try! Data(contentsOf: imageURL))!
            let audioData = try! Data(contentsOf: audioDataURL)
            
            return TempDBSong(name: item["name"]!, image: image, artistName: item["artistName"]!, youtubeID: item["youtubeID"]!, audioData: audioData)
        }
        return tempSongs
    }
    
    private static func songExists(for youtubeID: String) -> Bool{
        let request: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        
        request.predicate = NSPredicate(format: "\(#keyPath(DBSong.ytID)) == %@", youtubeID)
        
        if let objects = try? Database.context.fetch(request){
            if objects.isEmpty == false{ return true }
        }
        return false
    }
    
    
}

