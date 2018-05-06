////
////  AlbumSongListView.swift
////  MusicApp
////
////  Created by Patrick Hanna on 2/26/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import UIKit
//
//class AlbumSongListView: UITableViewController{
//    
//    
//    static var currentView: AlbumSongListView?
//    
//    
//    func reloadSongsIfNeeded(){
//        
//        if currentAlbum.isDownloadedAlbum{
//            tableView.reloadData()
//            currentAlbum.reloadSongs()
//        }
//        
//    }
//    
//
//    
//    init() {
//        fatalError("You MUST provide an album when instantiating 'Album List View!!!!'")
//    }
//    
//    
//    
//    
//    init(album: Album){
//        self.currentAlbum = album
//        super.init(style: .plain)
//        AlbumSongListView.currentView = self
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private var currentAlbum: Album
//    let cellID = "a;lskdjfal;ksdjfl;k"
//    
//    private lazy var tableHeaderView = AlbumSongListHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0), album: currentAlbum)
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        navigationItem.largeTitleDisplayMode = .never
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
//        tableView.tableFooterView = UIView()
//        tableView.tableHeaderView = tableHeaderView
//        tableView.contentInset.bottom = 49 + 70
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentAlbum.songs.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
//        cell.textLabel?.text = currentAlbum.songs[indexPath.row].name
//        return cell
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedSong = currentAlbum.songs[indexPath.row]
//        
//        AppManager.shared.setAndPlaySong(selectedSong)
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
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
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//fileprivate final class AlbumSongListHeaderView: UIView{
//
//    
//    private var albumCoverSize: CGFloat = 140
//    private var insets: CGFloat = 15
//    
//    init(frame: CGRect, album: Album){
//        
//        super.init(frame: CGRect(x: 0,
//                                 y: 0,
//                                 width: frame.width,
//                                 height: albumCoverSize + insets + 80))
//        
//        self.currentAlbum = album
//        addSubview(albumCover)
//        addSubview(labelsStackView)
//        addSubview(topLine_play_shuffleView)
//        addSubview(play_shuffleView)
//        setUpViews()
//    }
//    
//    var currentAlbum: Album!
//    
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    
//    private func setUpViews(){
//        albumCover.leftAnchor.constraint(equalTo: leftAnchor, constant: insets).isActive = true
//        albumCover.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        albumCover.widthAnchor.constraint(equalToConstant: albumCoverSize).isActive = true
//        albumCover.heightAnchor.constraint(equalToConstant: albumCoverSize).isActive = true
//        
//        labelsStackView.leftAnchor.constraint(equalTo: albumCover.rightAnchor, constant:insets).isActive = true
//        labelsStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        labelsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets).isActive = true
//        
//        topLine_play_shuffleView.leftAnchor.constraint(equalTo: albumCover.leftAnchor).isActive = true
//        topLine_play_shuffleView.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
//        topLine_play_shuffleView.topAnchor.constraint(equalTo: albumCover.bottomAnchor, constant: insets).isActive = true
//        topLine_play_shuffleView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        
//        
//    }
//    
//    lazy var albumCover: UIImageView = {
//        let x = UIImageView(image: currentAlbum.cover)
//        x.layer.cornerRadius = 5
//        x.layer.masksToBounds = true
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//    
//    lazy var labelsStackView: UIStackView = {
//        let x = UIStackView(arrangedSubviews: [albumName, albumArtist, extraInfo])
//        x.axis = .vertical
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//    
//    
//    lazy var albumName: UILabel = {
//        let x = UILabel()
//        x.text = currentAlbum.name
//        x.font = UIFont.boldSystemFont(ofSize: 17)
//        x.textAlignment = .left
//        return x
//    }()
//    
//    
//    lazy var albumArtist: UILabel = {
//        let x = UILabel()
//        x.text = currentAlbum.artist.name
//        x.textAlignment = .left
//        x.textColor = .red
//        x.font = UIFont.systemFont(ofSize: 17)
//        return x
//    }()
//    
//    lazy var extraInfo: UILabel = {
//        let x = UILabel()
//        x.text = "Pop • 2018"
//        x.textAlignment = .left
//        x.textColor = .lightGray
//        x.font = UIFont.systemFont(ofSize: 17)
//        return x
//    }()
//    
//    lazy var topLine_play_shuffleView: UIView = {
//        let x = UIView()
//        x.backgroundColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1)
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//        
//    }()
//
//    lazy var play_shuffleView: Play_ShuffleView = {
//        let x = Play_ShuffleView(frame: CGRect(x: 0,
//                                               y: albumCoverSize + insets,
//                                               width: frame.width,
//                                               height: 0))
//        x.rightInset = 0
//        x.backgroundColor = .clear
//        return x
//    }()
//
//
//}
//
//
//
//
//
//
