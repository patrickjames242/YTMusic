//
//  Downloader.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import AVFoundation







fileprivate let sharedDownloaderInstance = Downloader()

class Downloader: NSObject, URLSessionDownloadDelegate{
    
    static var main: Downloader{
        return sharedDownloaderInstance
    }
    
    
    //MARK: - DOWNLOAD TASK DELEGATE METHODS
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.sync {
            let decimal = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * Double(100)
            self.downloadTaskDict[downloadTask]?.changeStatusTo(.loading(decimal))
            
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        DispatchQueue.main.sync {
            let decimal = Double(fileOffset) / Double(expectedTotalBytes) * Double(100)
            self.downloadTaskDict[downloadTask]?.changeStatusTo(.loading(decimal))
            
        }
        
        
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        dataTaskDidFinishWithError(error: error, task: task)
       
        
    }
    
    
    private func dataTaskDidFinishWithError(error: Error?, task: URLSessionTask){
        
        DispatchQueue.main.sync {
            if error == nil{return}
            
            if let downloadItem = self.downloadTaskDict[task as! URLSessionDownloadTask]{
                downloadItem.changeStatusTo(.failed(Date()))
                self.downloadTaskDict[task as! URLSessionDownloadTask] = nil
            }
            
        }
        
    }
    

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        var data: Data
        do {
            data = try Data(contentsOf: location)
            let downloadItem = self.downloadTaskDict[downloadTask]!
            print(data)
            do{
                let _ = try AVAudioPlayer(data: data)
            } catch {
                
                dataTaskDidFinishWithError(error: error, task: downloadTask)
                DispatchQueue.main.sync {
                    AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "Sorry, recently, because of issues out of the developer's controll, many Youtube Videos are unable to be downloaded, such as this one. Please try downloading a VEVO music video published before June 2018!", completion: nil)
                }
                
                return
            }
            
            DispatchQueue.main.sync {
                Song.createNew(from: downloadItem, songData: data){(song) in
                    self.displayDownloadFinishedNotification()
                    
                    downloadItem.changeStatusTo(.finished(song, Date()))
                    self.downloadTaskDict[downloadTask] = nil
                }
            }
            
            
        } catch {
        
            print("An error occured in the 'didFinishDownloadingTo' delegate function in Downloader.swift: \(error)")
            DispatchQueue.main.sync {
                self.downloadTaskDict[downloadTask]?.changeStatusTo(.failed(Date()))
                self.downloadTaskDict[downloadTask] = nil
                AppManager.displayErrorMessage(target: AppManager.shared.screen, message: "Sorry, an error occured when trying to download a video", completion: nil)
                return
            }
        }
    }
    
    
    
    
    
    
    
    
    var downloadTaskDict = [URLSessionDownloadTask : DownloadItem](){
        didSet{
            DispatchQueue.main.async {
                AppManager.shared.setDownloadCountTo(self.downloadTaskDict.count)

            }
        }
    }
    
    
    private func displayDownloadFinishedNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Download Complete"
        content.body = "Now you can listen to your new song!!😆"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "downloadCompleteRequest", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    func continueDownloadOf(item: DownloadItem){
        guard let resumeData = item.resumeData else {return}
        
        
        let task = session.downloadTask(withResumeData: resumeData)
        
        task.resume()
        
        downloadTaskDict[task] = item
        
        item.deleteResumeData()
        item.changeStatusTo(.buffering)
        
        
        
    }
    
    
    private func getTaskForItem(_ item: DownloadItem) -> URLSessionDownloadTask?{
        var downloadTask: URLSessionDownloadTask?
        for (task, downloadItem) in downloadTaskDict{
            
            if downloadItem != item {continue}
            
            downloadTask = task
            
        }
        
        return downloadTask
    }
    
    
    
    func pauseDownloadOf(item: DownloadItem){
      
        guard let task = getTaskForItem(item) else {return}
        
        task.cancel { (data) in
            
            DispatchQueue.main.sync {
                if data == nil{
                    item.changeStatusTo(.canceled(Date()))
                    return
                }

                item.changeStatusTo(.paused(data!, Date()))
            }
            
        }
        
        downloadTaskDict[task] = nil
        
        
        
    }
    
    /// This stops the download of the DownloadItem without changing its status to canceled.
    func stopDownloadOf(item: DownloadItem){
        guard let task = getTaskForItem(item) else {return}
        
        task.cancel()
        downloadTaskDict[task] = nil

    }
    
    /// This stops the download of the DownloadItem and changes its status to canceled.
    func cancelDownloadOf(item: DownloadItem){
        
        stopDownloadOf(item: item)
        item.changeStatusTo(.canceled(Date()))
        
    }
    
    
    
    func appWillTerminate(){
        
        downloadTaskDict.forEach { (task, downloadItem) in
 
            downloadItem.changeStatusTo(.failed(Date()))
        }
    }
    
    
    func cancelAllActiveDownloads(){
        
        downloadTaskDict.forEach { (task, downloadItem) in
            task.cancel()
            downloadItem.changeStatusTo(.canceled(Date()))
            downloadTaskDict[task] = nil
        }
    }
    
    
    
    
    
    
    
    
    private var session: URLSession{
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    
    
    
    
    
    //MARK: - GET MP3 FILE
    
    
    func retryDownloadOf(item: DownloadItem){
        
        
        let title = "Song_Downloaded_With_Patricks_App"
        
        let url = URL(string: "https://cdn.mixload.co/get.php?id=\(item.ytVideoID)&name=\(title)")!
        
        
        
        let task = session.downloadTask(with: url)
        
        self.downloadTaskDict[task] = item
        
        task.resume()
        item.changeStatusTo(.buffering)
        item.deleteResumeData()
    }
    
    
    
    
    func beginDownloadOf(_ video: YoutubeVideo){
        print("The Video ID of this video is: " + video.videoID)
        let title = "Song_Downloaded_With_Patricks_App"
        
        let url = URL(string: "https://cdn.mixload.co/get.php?id=\(video.videoID)&name=\(title)")!
        
        
        
        let task = session.downloadTask(with: url)
        
        URLSession.shared.dataTask(with: video.thumbnailLink_highQuality) { (data, response, error) in
            if error != nil{
                print("There was an error in the 'beginDownloadOf' function in Downloader.swift: \(error!)")
                return
            }
            DispatchQueue.main.sync {
                
                let newDownloadItem = DownloadItem.createNew(from: video, imageData: data!)
                
                
                self.downloadTaskDict[task] = newDownloadItem
                
                task.resume()
                
                newDownloadItem.changeStatusTo(DownloadStatus.buffering)
                
            }
            
            
            }.resume()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

