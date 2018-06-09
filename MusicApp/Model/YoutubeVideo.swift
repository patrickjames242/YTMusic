//
//  YoutubeVideo.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit











protocol YoutubeVideoDelegate: class {
    
    var imageReceivedClosure: (_ wasDownloaded: Bool, YoutubeVideo, UIImage) -> Void { get }

}





class YoutubeVideo {
    
    let name: String
    let videoID: String
    let channel: String
    let duration: String
    let views: String
    let date: String
    
    let thumbnailLink_highQuality: URL
    let thumbnailLink_lowQuality: URL
    
    init(name: String, videoID: String, channel: String, thumbnailLink_highQuality: URL,thumbnailLink_lowQuality: URL, duration: String, views: String, date: String) {
        self.thumbnailLink_highQuality = thumbnailLink_highQuality
        self.thumbnailLink_lowQuality = thumbnailLink_lowQuality
        self.name = name
        self.videoID = videoID
        self.channel = channel
        self.duration = duration
        self.views = views
        self.date = date
        
        
        
        
    }
    
    
    

    private var image: UIImage?
    private weak var delegate:YoutubeVideoDelegate?


    func registerAsDelegate(_ asker: YoutubeVideoDelegate){
        
        if image != nil{ delegate = nil; asker.imageReceivedClosure(false, self, image!); return }
        
        self.delegate = asker
        
        initiateImageDownloadIfNeeded()
        
        
    }
    
    func resignAsDelegate(_ asker: YoutubeVideoDelegate){
        
        self.delegate = nil
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    private var imageDownloadIsInProgress = false
    
    private func initiateImageDownloadIfNeeded() {
        
        
        if imageDownloadIsInProgress { return }
        
        imageDownloadIsInProgress = true
        
        let task = URLSession.shared.dataTask(with: thumbnailLink_lowQuality) { [weak weakSelf = self](data, response, error) in
            guard let weakSelf = weakSelf else {return}
            weakSelf.imageDownloadIsInProgress = false
            
            
            if let error = error {
                print("there was an error in the 'initiateImageDownload' function in a YoutubeVideoObject: name:\(weakSelf.name), error: \(error)")
                weakSelf.initiateImageDownloadIfNeeded()
                return
            }
            
            
            if let data = data, let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    weakSelf.image = image
                    weakSelf.delegate?.imageReceivedClosure(true, self, image)
                }
                
            } else {
                weakSelf.initiateImageDownloadIfNeeded()
                print("Something went wrong in the 'initiateImageDownload' function in a YoutubeVideo object name: \(weakSelf.name)")
            }
            
        }
        
        task.resume()
        
    }
    
    
}
    

