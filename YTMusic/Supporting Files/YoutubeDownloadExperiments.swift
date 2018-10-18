////
////  YoutubeDownloadExperiments.swift
////  MusicApp
////
////  Created by Patrick Hanna on 10/18/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import Foundation
//
//
//
//let id = "KsxTYrqHti8"
//
//let url = URL(string: "https://getvideo.p.mashape.com/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D\(id)")!
//
//var request = URLRequest(url: url)
//request.httpMethod = "POST"
//
//request.setValue("1vJyTbOs9fmshXk6oIFREwR41Tp2p1PnngTjsnNtYfMXWua211", forHTTPHeaderField: "X-Mashape-Key")
//request.setValue("text/plain", forHTTPHeaderField: "Accept")
//
//URLSession.shared.dataTask(with: request) { (data, response, error) in
//    print("session finished")
//    if let data = data{
//        let dict = try! JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as! NSDictionary
//        print(dict)
//        let streams = dict["streams"] as! NSArray
//
//
//
//
//
//        let streamToUse = streams[streams.count - 1] as! NSDictionary
//        print("should start playing")
//        let url = URL(string: streamToUse["url"] as! String)!
//        print("will start getting stuff from network")
//        let data = try! Data(contentsOf: url)
//        print("did finish getting stuff from network")
//        self.audioPlayer = try! AVAudioPlayer(data: data)
//
//        self.audioPlayer.prepareToPlay()
//        self.audioPlayer.play()
//        print(self.audioPlayer.settings)
//        //                    let playerItem = AVPlayerItem(url: url)
//        //                    self.player = AVPlayer(playerItem: playerItem)
//        //                    self.player.play()
//
//
//
//    }
//
//    }.resume()
