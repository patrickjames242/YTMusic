//
//  Templates.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/23/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
import UIKit
import Foundation
import CoreData
import AVFoundation








enum SongPlayingStatus{ case playing, paused, inactive }



protocol SongObserver: NSObjectProtocol {
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus)
}






class Song: NSObject {
    
    private static var allSongs = [String: Song]()
    
    static func createNew(from downloadItem: DownloadItem, songData: Data, completion: @escaping (Song) -> Void){
       
        DBManager.createAndSaveNewDBSongObject(from: downloadItem.object, songData: songData){ (dbSong) in
            let newSong = wrap(object: dbSong)
            completion(newSong)
            MNotifications.sendNewSongWasCreatedNotification(for: newSong)
        }
    }
    
    static func createNew(from tempSong: TempDBSong, completion: ((Song) -> Void)? = nil){
        DBManager.createAndSaveDBObject(from: tempSong) { (dbSong) in
            let newSong = wrap(object: dbSong)
            completion?(newSong)
            MNotifications.sendNewSongWasCreatedNotification(for: newSong)
        }
        
    }
    

    func isTheWrapperFor(DBObject: DBSong) -> Bool{
        return object == DBObject
    }
    
    static func isDownloaded(youtubeID: String) -> Bool{
        for song in allSongs.values where song.youtubeID == youtubeID{
            return true
        }
        return false
    }

    
    static func deleteAll(completion: (() -> Void)? = nil){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            
            for song in getAll(){
                allSongs[song.uniqueID] = nil
                DBManager.delete(song: song.object)
                DispatchQueue.main.async {
                    MNotifications.sendSongWasDeletedNotification(for: song)
                    
                }
            }
            DispatchQueue.main.sync{
                if let completion = completion{
                    completion()
                }
            }
        }
    }
    
    
    
    static func count() -> Int{
        
        return DBManager.countSongObjects()
        
    }
    
    
    static func getAll() -> [Song]{
        let objects = DBManager.getAllSongs()
        return wrap(array: objects)
    }
    
    static func wrap(object: DBSong) -> Song{
        if let song = allSongs[object.dataIdentifier!]{
            return song
        } else {
            let newSong = Song(DB_Object: object)
            allSongs[object.dataIdentifier!] = newSong
            return newSong
        }
    }
    
    
    
    static func wrap(array: [DBSong]) -> [Song]{
        let collectionToReturn = EArray<Song>()
        
        collectionToReturn.irateThrough(array: array) { wrap(object: $0) }
        
        return collectionToReturn.elements
    }
    

    
    
    func playNext(){
        MNotifications.sendUserDidPressPlaySongNextNotification(for: self)
        
        
    }
    
    
    
    func delete(){
        downloadItem?.delete()
        Song.allSongs[self.uniqueID] = nil
        DBManager.delete(song: object)
        
        MNotifications.sendSongWasDeletedNotification(for: self)
    }
    
    func changeNamesToDefaults(){
        DBManager.changeDBSongNamesToDefaults(object: object)
        MNotifications.sendSongNameDidChangeNotification(for: self)
    }

    func changeNamesTo(title: String, artist: String){

        DBManager.changeDBSongNames(object: object, name: title, artist: artist)
        MNotifications.sendSongNameDidChangeNotification(for: self)
    }



    
    
    private var myObservers = [SongObserver]()
    
    func addObserver(_ sender: SongObserver){
        
        for observer in myObservers where observer === sender{
            return
        }
        
        self.myObservers.append(sender)
        
        
        
    }
    
    func removeObserver(_ sender: SongObserver){
        var x = 0
        for observer in myObservers{
            
            if sender === observer{
                myObservers.remove(at: x)
                x -= 1
            }
            x += 1
        }
    }

    private var _currentNowPlayingStatus = SongPlayingStatus.inactive
    
    var nowPlayingStatus: SongPlayingStatus{
        return _currentNowPlayingStatus
    }
    
    func changeNowPlayingStatusTo(_ status: SongPlayingStatus){
        
        self._currentNowPlayingStatus = status
        
        for observer in myObservers{
            observer.songPlayingStatusDidChangeTo(status)
        }
        
    }
    

    
    
    
    
    static func getNumberOfBytes(completion: @escaping (Int) -> Void){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async{
            
            
            let numberOfBytes = Song.getAll().map{$0.data.count}.reduce(0) {$0 + $1}
            
            DispatchQueue.main.sync {
                completion(numberOfBytes)
                
            }
            
            
            
        }
    }
    
    
    

    
    var data: Data{
        return DBManager.getDataForDBSongObject(object)
    }
    
    var name: String{
        return object.name!
    }
    var artistName: String{
        return object.artistName!
    }
    
    var uniqueID: String
    let image: UIImage
    var duration: TimeInterval = 0
    
    
    
    var downloadItem: DownloadItem?{
        
        if let item = object.dbDownloadItem{
            return DownloadItem.wrap(object: item)
        }
        return nil
    }

    let youtubeID: String?
    
    
    /// This is not used outside of the Song and DownloadItem classes
    let object: DBSong
    

    
    private init(DB_Object: DBSong){
        self.image = UIImage(data: DB_Object.image!)!
        self.object = DB_Object
        self.uniqueID = DB_Object.dataIdentifier!
        self.youtubeID = DB_Object.ytID
        
    }
    
}































































struct TempDBSong{
    let name: String
    let image: UIImage
    let artistName: String
    let youtubeID: String
    let audioData: Data
    
    init(name: String, image: UIImage, artistName: String, youtubeID: String, audioData: Data){
        self.name = name
        self.image = image
        self.artistName = artistName
        self.youtubeID = youtubeID
        self.audioData = audioData
    }
}



//MARK: - CORE DATA CONVENIENCE FUNCTIONS

fileprivate final class DBManager{
    
    private static let context = Database.context
    private static func saveContext() { Database.saveContext() }
    
    
    
    
    static func createAndSaveDBObject(from tempSong: TempDBSong, completion: ((DBSong) -> ())? = nil){
            let identifier = NSUUID().uuidString
            
            let newDBSong = DBSong(context: context)
            
            newDBSong.name = tempSong.name
            newDBSong.dataIdentifier = identifier
            
            newDBSong.image = UIImageJPEGRepresentation(tempSong.image, 1)!
            
            newDBSong.artistName = tempSong.artistName
            newDBSong.date = Date()
            newDBSong.ytID = tempSong.youtubeID
            newDBSong.defaultName = tempSong.name
            newDBSong.defaultArtistName = tempSong.artistName
            
            
            let newDBDAta = DBData(context: DBManager.context)
            newDBDAta.data = tempSong.audioData
            newDBDAta.identifier = identifier
                saveContext()
                completion?(newDBSong)

            

    }
    
    
    
    static func createAndSaveNewDBSongObject(from downloadItem: DBDownloadItem, songData: Data, completion: @escaping (DBSong) -> Void){
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            let identifier = NSUUID().uuidString
            
            let newDBSong = DBSong(context: context)
            
            newDBSong.name = downloadItem.name!
            newDBSong.dataIdentifier = identifier
            
            newDBSong.image = downloadItem.image!
            newDBSong.artistName = downloadItem.channelName!
            newDBSong.date = Date()
            newDBSong.ytID = downloadItem.ytID!
            newDBSong.defaultName = downloadItem.name!
            newDBSong.defaultArtistName = downloadItem.channelName!
            
            
            let newDBDAta = DBData(context: DBManager.context)
            newDBDAta.data = songData
            newDBDAta.identifier = identifier
            DispatchQueue.main.async {
                saveContext()
                completion(newDBSong)
            }
            
        }
    }
    

    static func countSongObjects() -> Int{
        
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        
        do{
            
            return try context.count(for: fetchRequest)

            
        } catch {
            print("there was an error in the 'countSongObjects' function in Song & DownloadItem.swift \n \(error) ")
            return 0
        }
        
        
        
        
    }
    
    
    static func getDataForDBSongObject(_ song: DBSong) -> Data{
        
        return getDBDataObjectFor(song: song).data!
        
    }
    

    
    static func changeDBSongNames(object: DBSong, name: String, artist: String){
        
        object.name = name
        object.artistName = artist
        
        saveContext()
    }
    
    static func changeDBSongNamesToDefaults(object: DBSong){
        object.name = object.defaultName!
        object.artistName = object.defaultArtistName!
        saveContext()
    }
    
    

    
    
    static func delete(song: DBSong){
        let dbdata = getDBDataObjectFor(song: song)
        context.delete(dbdata)
        context.delete(song)
        saveContext()
    }
    
    
    

    
    
    private static func getDBDataObjectFor(song: DBSong) -> DBData{
        
        let fetchRequest: NSFetchRequest<DBData> = DBData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", song.dataIdentifier!)
        var dataObjects = [DBData]()
        
        do{
            dataObjects = try context.fetch(fetchRequest)
        } catch{
            print(error)
        }
        return dataObjects[0]
    }
    
    
    
    
    
    static func getAllSongs() -> [DBSong]{
        var fetchedSongs = [DBSong]()
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        do{
            fetchedSongs = try context.fetch(fetchRequest)
        } catch {
            
            print("there was an error in the 'getAllSongs' function in DBManager.swift: \(error)")
            
        }
        
        return fetchedSongs
    }
    
}
