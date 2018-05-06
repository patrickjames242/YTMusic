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
    
    static func createNew(from downloadItem: DownloadItem, songData: Data, completion: @escaping (Song) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            
            let object = DBManager.createAndSaveNewDBSongObject(from: downloadItem.object, songData: songData)
            let newSong = wrap(object: object)
            DispatchQueue.main.sync {
                 NotificationCenter.default.post(name: NewSongWasCreatedNotification, object: newSong, userInfo: [NewlyCreatedSongObjectKey : newSong])
                completion(newSong)
            }
        }
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
    
    
    fileprivate let object: DBSong
    

    
    private init(DB_Object: DBSong){
        self.image = UIImage(data: DB_Object.image!)!
        self.object = DB_Object
        self.uniqueID = DB_Object.dataIdentifier!
        
    }
    
}












































protocol DownloadItemDelegate{
    func DLStatusDidChangeTo(_ status: DownloadStatus)
}



enum DownloadStatus {
    
    
    
    /// Item can only be paused by the user
    case paused(Data, Date)
    
    /// Item can only be canceled by the user. If it is canceled by the system, the 'failed' case is used.
    case canceled(Date)
    
    /// Item is inactive when the download has not started as yet. A download Item should never be set to inactive.
    case inactive
    
    /// Item is buffering when the urlsession has been triggered, but it has not started downloading as yet.
    case buffering
    
    /// Item is loading when data is currently being downloaded for it.
    case loading(Double)
    
    /// Item is finished when all corresponding data has been downloaded.
    case finished(Song, Date)
    
    /// Item has failed when some error has occured in the app.
    case failed(Date)
    
}







enum DBDownloadItemStatus: String{
    case paused = "PAUSED"
    case cancelled = "CANCELED"
    case failed = "FAILED"
    case finished = "FINISHED"
    case changing = "CHANGING"
}




class DownloadItem: Equatable{
    

    static func ==(lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }


    var delegate: DownloadItemDelegate?
    
    let image: UIImage
    
    fileprivate let object: DBDownloadItem
    
    func delete(){
        
        DBManager.delete(downloadItem: object)
    }
    
    var name: String            { return object.name!}
    var channelName: String     { return object.channelName!}
    var ytVideoID: String       { return object.ytID!}
    var startDate: Date         { return object.dateStarted!}
    var uniqueID: String
    private var _runTimeStatus: DownloadStatus
    
    var runTimeStatus: DownloadStatus{
        return _runTimeStatus
        
    }
    
    var storageStatus: DBDownloadItemStatus{
        return DBDownloadItemStatus.init(rawValue: object.status!)!
    }
    
    var resumeData: Data?{
        return DBManager.getResumeData(for: object)
    }
    
    var endDate: Date?{
        return object.dateFinished
    }
    
    var song: Song? {
        if let song = object.dbSong{
            return Song.wrap(object: song)
        } else { return nil }
    }
    
    
    func isTheWrapperFor(object: DBDownloadItem) -> Bool{
        return self.object == object
        
    }
    
    
    
    
    
    
    private var _songObject: Song? {
        get{
            if let song = object.dbSong{
                return Song.wrap(object: song)
            } else { return nil }
        } set {
            object.dbSong = newValue?.object
            Database.saveContext()
        }
    }
    
    
    
    private var _endDate: Date?{
        get {
            return object.dateFinished
        } set {
            object.dateFinished = newValue
            Database.saveContext()
        }
    }
    
    
    private var _storageStatus: DBDownloadItemStatus{
        get {
            return DBDownloadItemStatus.init(rawValue: object.status!)!
        } set {
            object.status = newValue.rawValue
            Database.saveContext()
        }
    }
    
    
    private var _resumeData: Data?{
        get{
            return DBManager.getResumeData(for: object)
        } set {
            if let value = newValue{
                DBManager.prepareResumeData(for: object, with: value)
                Database.saveContext()
            }
        }
    }
    
    func deleteResumeData(){
        if let dataObject = DBManager.getDBDataObjectFor(downloadItem: object){
            
            Database.context.delete(dataObject)
            Database.saveContext()
            
        }
        
    }
    
    
    
    
    
  
    
    
    

    
    

    
    


    
    
    
    
    
    
    
    
    
    func changeStatusTo(_ newStatus: DownloadStatus){
        switch newStatus{
       
        case .paused(let data, let date):
            
            self._resumeData = data
            
            self._endDate = date
            self._storageStatus = .paused

        case .finished(let song, let date):
            self._songObject = song

            self._endDate = date
            self._storageStatus = .finished

        case .failed(let date):
            
            self._endDate = date
            self._storageStatus = .failed

        case .canceled(let date):
            
            self._endDate = date
            self._storageStatus = .cancelled

        default:
            if self._storageStatus != .changing{
                self._storageStatus = .changing
            }
        }
        
        self._runTimeStatus = newStatus
        delegate?.DLStatusDidChangeTo(newStatus)
        
    }
    
    
    static private var allCurrentInstances = [String: DownloadItem]()
    
    
    
    static func wrap(object: DBDownloadItem) -> DownloadItem? {
        if let previousInstance = allCurrentInstances[object.uniqueID!]{
            return previousInstance
        } else {
            guard let newItem = DownloadItem(DBObject: object) else {return nil}
            allCurrentInstances[newItem.uniqueID] = newItem
            return newItem
        }
    }
    
    static func wrap(array: [DBDownloadItem]) -> [DownloadItem]{
        let collectionToReturn = EArray<DownloadItem>()
        collectionToReturn.irateThrough(array: array) { wrap(object: $0) }
        return collectionToReturn.elements
    }
    
    static func createNew(from video: YoutubeVideo, imageData: Data) -> DownloadItem{
        let newObject = DBManager.createAndSaveNewDBDownloadItem(from: video, imageData: imageData)
        return wrap(object: newObject)!
    }
    
    static func getAll() -> [DownloadItem]{
        let gottenObjects = DBManager.getAllDownloadItems()
        return wrap(array: gottenObjects)
    }
    
    
    
    
    
    private static func filterObject(DBObject: DBDownloadItem) -> DBDownloadItem? {
        guard let status = DBObject.status, let storageStatus = DBDownloadItemStatus(rawValue: status) else {
            DBManager.delete(downloadItem: DBObject)
            return nil
        }
    
        if storageStatus == .paused{return DBObject}
        
        
        if -DBObject.dateStarted!.timeIntervalSinceNow >= (60 * 60 * 24){
            DBManager.delete(downloadItem: DBObject)
            return nil
        }
        return DBObject
        
        
    }
    
    private func startFilterTimer(){
        Timer.scheduledTimer(withTimeInterval: 20 * 60, repeats: true) { [weak weakSelf = self](timer) in
            if weakSelf == nil{timer.invalidate(); return}
            
            
            if DownloadItem.filterObject(DBObject: weakSelf!.object) == nil{
                timer.invalidate()
            }
            
            
            
        }
    }
    
    
    
    private init?(DBObject: DBDownloadItem) {
        
        if DownloadItem.filterObject(DBObject: DBObject) == nil{return nil}
        
        self.image = UIImage(data: DBObject.image!)!
        self.object = DBObject
        self.uniqueID = DBObject.uniqueID!
        let status = DBDownloadItemStatus.init(rawValue: DBObject.status!)!
        
        switch status{
        case .changing:
            
            DBObject.dateFinished = DBObject.dateStarted!
            DBObject.status = DBDownloadItemStatus.failed.rawValue
            self._runTimeStatus = DownloadStatus.failed(DBObject.dateFinished!)
        
        case .failed:
            self._runTimeStatus = DownloadStatus.failed(DBObject.dateFinished!)
        
        case .finished:
            self._runTimeStatus = DownloadStatus.finished(Song.wrap(object: DBObject.dbSong!), DBObject.dateFinished!)
        
        case .paused:
            let resumeData1 = DBManager.getResumeData(for: DBObject)
            self._runTimeStatus = DownloadStatus.paused(resumeData1!, DBObject.dateFinished!)
        
        case .cancelled:
            self._runTimeStatus = DownloadStatus.canceled(DBObject.dateFinished!)
        }
        
        startFilterTimer()
    }
    
    
    
    
    
    
    
    
    
    
}

































//MARK: - CORE DATA CONVENIENCE FUNCTIONS

fileprivate final class DBManager{
    
    private static let context = Database.context
    private static func saveContext() { Database.saveContext() }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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

    
    static func delete(downloadItem: DBDownloadItem){
        if let itemData = self.getDBDataObjectFor(downloadItem: downloadItem){
            context.delete(itemData)
        }
        context.delete(downloadItem)
        saveContext()
    }
    

    static func createAndSaveNewDBDownloadItem(from youtubeVideo: YoutubeVideo, imageData: Data) -> DBDownloadItem{
        
        let newObject = DBDownloadItem(context: context)
        newObject.uniqueID = NSUUID().uuidString
        newObject.channelName = youtubeVideo.channel
        newObject.dateStarted = Date()
        newObject.image = imageData
        newObject.name = youtubeVideo.name
        newObject.ytID = youtubeVideo.videoID
        newObject.status = DBDownloadItemStatus.changing.rawValue
        saveContext()
        return newObject
        
    }
    
    
    
    static func getAllDownloadItems() -> [DBDownloadItem]{
        
        let fetchRequest: NSFetchRequest<DBDownloadItem> = DBDownloadItem.fetchRequest()
        var fetchedResults = [DBDownloadItem]()
        do{
            fetchedResults = try context.fetch(fetchRequest)
            
        } catch{
            print("error in the getAllDownloadItems function in Database.swift: \(error)")
        }
        
        return fetchedResults
    }
    
    
    
    
    
    static func getResumeData(for downloadItem: DBDownloadItem) -> Data?{
        
        return getDBDataObjectFor(downloadItem: downloadItem)?.data
        
    }
    
    static func getDBDataObjectFor(downloadItem: DBDownloadItem) -> DBData?{
        
        let fetchRequest: NSFetchRequest<DBData> = DBData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", downloadItem.uniqueID!)
        var fetchedObject = [DBData]()
        do{
            fetchedObject = try context.fetch(fetchRequest)
        } catch {
            print("There was an error in the 'getResumeData' function, for \(downloadItem.name!), in Database.swift: \(error)")
        }
        if fetchedObject.isEmpty {return nil} else {return fetchedObject[0]}
    }
    
    
    
    static func prepareResumeData(for object: DBDownloadItem, with data: Data){
        
        let dbdata = DBData(context: context)
        dbdata.data = data
        dbdata.identifier = object.uniqueID!
        
        saveContext()
    }
}






























