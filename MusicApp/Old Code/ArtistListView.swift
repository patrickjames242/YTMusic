////
////  ArtistListView.swift
////  MusicApp
////
////  Created by Patrick Hanna on 2/26/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import UIKit
//
//
//
//class ArtistListView_NavCon: UINavigationController{
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        navigationBar.prefersLargeTitles = true
//        viewControllers.append(AppManager.shared.artistListView)
//        
//    }
//    
//}
//
//
//
//class ArtistListView: UITableViewController{
//    
//    var artists = [Artist]()
//    let cellID = "My artist cell id"
//    private func initializeArtists(){
//        let tempArtists = MediaStorage.shared.allArtists
//        
//        artists = tempArtists.sorted{ $0.name < $1.name }
//        tableView.reloadData()
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.title = "Artists"
//        navigationItem.largeTitleDisplayMode = .always
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
//        
//        initializeArtists()
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return artists.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
//        cell.textLabel!.text = artists[indexPath.row].name
//        return cell
//    }
//    
//    
//    
//}
//
//private final class CellConstants{
//    
//    static var leftImageInset: CGFloat = 20
//    static var rightImageInset: CGFloat = 20
//    static var imageSize: CGFloat = 40
//    
//    
//}
//
//
//fileprivate final class MyArtistTableViewCell: UITableViewCell{
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
//
//
//
//
//
//
//
//
//
