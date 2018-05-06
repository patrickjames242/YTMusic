//
//  YoutubeVideo.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



protocol YoutubeVideoDelegate: class {
    
    func imageDidFinishDownloading(video: YoutubeVideo, image: UIImage)
    
}


class YoutubeVideo: NSObject {
    
    let name: String
    let videoID: String
    let channel: String
    let thumbnailLink: URL
    let duration: String
    let views: String
    let date: String
    
    var image: UIImage?
    
    weak var delegate:YoutubeVideoDelegate?
    
    init(name: String, videoID: String, channel: String, thumbnailLink: URL, duration: String, views: String, date: String) {
        self.name = name
        self.videoID = videoID
        self.channel = channel
        self.thumbnailLink = thumbnailLink
        self.duration = duration
        self.views = views
        self.date = date
        
        super.init()
        
        
        
    }
    
    
    
    

    private var imageDownloadHasStarted = false
    
    func initiateImageDownloadIfNeeded(){
        
        
        if imageDownloadHasStarted{return}
        
        imageDownloadHasStarted = true
        
        let task = URLSession.shared.dataTask(with: thumbnailLink) { (data, response, error) in
            if let error = error{
                print("there was an error in the 'initiateImageDownload' function in a YoutubeVideoObject: name:\(self.name), error: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data){
                DispatchQueue.main.async {
                    self.image = image
                    self.delegate?.imageDidFinishDownloading(video: self, image: image)
                }
                
            
                
            } else {
                print("Something went wrong in the 'initiateImageDownload' function in a YoutubeVideo object name: \(self.name)")
            }
            
        }
        
        task.resume()
        
    }
    
    
    
}






