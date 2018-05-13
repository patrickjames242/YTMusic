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




let SongNameDidChangeNotification = Notification.Name("SongNameDidChange")
let SongWasDeletedNotification = Notification.Name("SongWasDeleted")
let DeletedSongObjectKey = "DeletedSong"

let NewSongWasCreatedNotification = Notification.Name("NewSongWasCreated")
let NewlyCreatedSongObjectKey = "NewSong"

let UserDidPressPlaySongNext = Notification.Name("UserWantsToPlaySongNext")
let SelectedUpNextSongKey = "UpNextSong"





enum SongPlayingStatus{ case playing, paused, inactive }



protocol SongObserver: NSObjectProtocol {
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus)
}






class Song: NSObject {
    
    private static var allSongs = [String: Song]()
    
    static func createNew(from downloadItem: DownloadItem, songData: Data) -> Song{
        
        
        let object = DBManager.createAndSaveNewDBSongObject(from: downloadItem.object, songData: songData)
        
        let newSong = wrap(object: object)
        
        
        
        NotificationCenter.default.post(name: NewSongWasCreatedNotification, object: newSong, userInfo: [NewlyCreatedSongObjectKey : newSong])
        
        
        
        return newSong
        
        
    }
    
    
    var theDuration: TimeInterval{
        
        return object.duration
        
    }
    
    static func deleteAll(completion: (() -> Void)? = nil){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            
            for song in getAll(){
                allSongs[song.uniqueID] = nil
                DBManager.delete(song: song.object)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SongWasDeletedNotification, object: song, userInfo: [DeletedSongObjectKey : song])
                    
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
    
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
    
    
    func playNext(){
        NotificationCenter.default.post(name: UserDidPressPlaySongNext, object: self, userInfo: [SelectedUpNextSongKey : self])
        
        
    }
    
    
    
    func delete(){
        Song.allSongs[self.uniqueID] = nil
        DBManager.delete(song: object)
        
        NotificationCenter.default.post(name: SongWasDeletedNotification, object: self, userInfo: [DeletedSongObjectKey : self])
    }
    
    func changeNamesToDefaults(){
        DBManager.changeDBSongNamesToDefaults(object: object)
        NotificationCenter.default.post(name: SongNameDidChangeNotification, object: self)
    }
    
    func changeNamesTo(title: String, artist: String){
        
        DBManager.changeDBSongNames(object: object, name: title, artist: artist)
        NotificationCenter.default.post(name: SongNameDidChangeNotification, object: self)
    }
    
    
    
    
    
    private var myObservers = [SongObserver]()
    
    func addObserver(_ sender: SongObserver){
        
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
    
    deinit {
        print("A song oject was deinitted")
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
    
    

    var youtubeID: String?{
        return object.ytID
        
    }
    
    /// This is not used outside of the Song and DownloadItem classes
    let object: DBSong
    

    
    private init(DB_Object: DBSong){
        self.image = UIImage(data: DB_Object.image!)!
        self.object = DB_Object
        self.uniqueID = DB_Object.dataIdentifier!
        
    }
    
}



































































//MARK: - CORE DATA CONVENIENCE FUNCTIONS

fileprivate final class DBManager{
    
    private static let context = Database.context
    private static func saveContext() { Database.saveContext() }
    
    
    
    
    
    
    
    
    static func createAndSaveNewDBSongObject(from downloadItem: DBDownloadItem, songData: Data) -> DBSong{
        
        let identifier = NSUUID().uuidString
        
        let newDBSong = DBSong(context: context)
        newDBSong.dataIdentifier = identifier
        newDBSong.name = downloadItem.name
        newDBSong.image = downloadItem.image
        newDBSong.artistName = downloadItem.channelName
        newDBSong.date = Date()
        newDBSong.ytID = downloadItem.ytID
        newDBSong.defaultName = downloadItem.name!
        newDBSong.defaultArtistName = downloadItem.channelName!
        
        
        let newDBDAta = DBData(context: DBManager.context)
        newDBDAta.data = songData
        newDBDAta.identifier = identifier
        
        
        saveContext()
        return newDBSong
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







































extension Song{
    
    
    static func fixDatabaseMistakes(){
        
        return
        
        let durationSetKey = "DURATION_SET"
        
        if UserDefaults.standard.bool(forKey: durationSetKey) == true { return }
        
        for song in Song.getAll(){
            
            do{
                
                let player = try AVAudioPlayer(data: song.data)
                
                song.object.duration = player.duration
                Database.saveContext()
                
            } catch {
                
                song.delete()
                print("There was an error when trying to extract the duration from a song: \(song.name)")
                continue
                
            }
            
            
        }
        
        UserDefaults.standard.set(true, forKey: durationSetKey)
    }
    
    
    
}











