//
//  DownloadItem.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//


import CoreData
import UIKit











protocol DownloadItemDelegate : class{
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




class DownloadItem: NSObject{
    
    
    
    
 
    
    weak var delegate: DownloadItemDelegate?
    
    let image: UIImage
    
    
    
    /// This is not used outside of the Song and DownloadItem classes
    
    let object: DBDownloadItem
    


    deinit{

        
        print("A downloadItem has been been deinitialized")
    }

    
    

    
    var name: String{ return object.name!}
    var channelName: String{ return object.channelName!}
    var ytVideoID: String{ return object.ytID!}
    var startDate: Date{ return object.dateStarted!}
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
    
    
    static private var allCurrentInstances = [DBDownloadItem: DownloadItem]()
    
    
    
    static func wrap(object: DBDownloadItem) -> DownloadItem? {
        
        if let previousObject = allCurrentInstances[object]{
            return previousObject
        }
        
        guard let newItem = DownloadItem(DBObject: object) else {return nil}
        allCurrentInstances[object] = newItem
        return newItem
        
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
    
    
    func delete(){
        Downloader.main.stopDownloadOf(item: self)
        DownloadItem.allCurrentInstances[object] = nil
        DBManager.delete(downloadItem: object)
    }
    
    
    
    
    
    private static func objectShouldBeDeleted(object: DBDownloadItem) -> Bool{
        guard let startDate = object.dateStarted else { return true }
        
        if -startDate.timeIntervalSinceNow >= (60 * 60 * 23) { return true }
        
        return false
    }
    
    
    
    
    
    
    
    
    private init?(DBObject: DBDownloadItem) {
        if DBObject.uniqueID == nil{return nil}
        
        if DownloadItem.objectShouldBeDeleted(object: DBObject){
            DBManager.delete(downloadItem: DBObject)
            return nil
        }
        
        
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
        super.init()

        

    }
}

























































fileprivate final class DBManager {
    
    private static let context = Database.context
    private static func saveContext() { Database.saveContext() }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
