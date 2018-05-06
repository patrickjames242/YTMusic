//
//  AlbumListview.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/24/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//
//
//import UIKit
//
//class AlbumListView_NavCon: UINavigationController{
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationBar.prefersLargeTitles = true
//        navigationBar.isTranslucent = false
//        navigationBar.barTintColor = .white
//        navigationBar.shadowImage = UIImage()
//        navigationBar.tintColor = .red
//        viewControllers.append(AppManager.shared.albumListView)
//    
//        
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
//
//class AlbumListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
//    
//    private let cellID = "The fucking best cell in existence!!!"
//    
//    private let distanceBetweenColumns: CGFloat = 20
//    
//    private var albums = [Album]()
//    
//    private func initializeAlbumsArray(){
//        albums = MediaStorage.shared.allAlbums.sorted{ $0.artist.name < $1.artist.name }
//        collectionView?.reloadData()
//    }
//    
//    private var sizeOfAlbumCover: CGFloat{
//        return (self.view.frame.width - (distanceBetweenColumns * 3)) / 2
//    }
//    
//    func nowPlayingViewDidAppear(){
//        collectionView?.scrollIndicatorInsets.bottom = AppManager.nowPlayingViewHeight + 49 + 2
//        collectionView?.contentInset.bottom = AppManager.nowPlayingViewHeight + 49
//    }
//   
//    
//    
//    
//    
//    
//    private lazy var play_shuffleHeader: Play_ShuffleView = {
//       let x = Play_ShuffleView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0))
//        return x
//    }()
//    
//    
//    
//    
//    
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        navigationItem.largeTitleDisplayMode = .always
//        navigationItem.title = "Albums"
//        
//        initializeAlbumsArray()
//        collectionView?.contentInset = UIEdgeInsets(top: distanceBetweenColumns, left: 0, bottom: 49, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: distanceBetweenColumns, left: 0, bottom: 49, right: 0)
//        collectionView?.backgroundColor = .white
//        collectionView?.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedAlbum = albums[indexPath.item]
//        selectedAlbum.reloadSongs()
//        let newController = AlbumSongListView(album: selectedAlbum)
//        
//        navigationController?.pushViewController(newController, animated: true)
//    }
//    
//
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MyCollectionViewCell
//        
//        let selectedAlbum = albums[indexPath.item]
//        cell.albumName.text = selectedAlbum.name
//        cell.albumArtist.text = selectedAlbum.artist.name
//        cell.albumCover.image = selectedAlbum.cover
//        
//        return cell
//        
//    }
//    
//    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return albums.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0,
//                            left: distanceBetweenColumns,
//                            bottom: 0,
//                            right: distanceBetweenColumns)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return distanceBetweenColumns
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    
//        
//        return CGSize(width: sizeOfAlbumCover, height: sizeOfAlbumCover + 50)
//    }
//
//}
//
//
//class MyCollectionViewCell: UICollectionViewCell{
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubview(albumCover)
//        addSubview(labelsStackView)
//        setUpAllConstraints()
//    }
//    
//    private func setUpAllConstraints(){
//        albumCover.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        albumCover.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        albumCover.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        albumCover.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
//        
//        labelsStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        labelsStackView.topAnchor.constraint(equalTo: albumCover.bottomAnchor, constant: 5).isActive = true
//        labelsStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    
//    lazy var albumCover: UIImageView = {
//       let x = UIImageView()
//        x.layer.cornerRadius = 5
//        x.layer.masksToBounds = true
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//    
//    lazy var labelsStackView: UIStackView = {
//        let x = UIStackView(arrangedSubviews: [albumName,albumArtist])
//        x.axis = .vertical
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//    
//    
//    lazy var albumName: UILabel = {
//        let x = UILabel()
//        x.text = "TESTING TESTING 123"
//        x.font = UIFont.systemFont(ofSize: 15)
//        x.textAlignment = .left
//        return x
//    }()
//    
//    
//    lazy var albumArtist: UILabel = {
//        let x = UILabel()
//        x.text = "TESTING TESTING 123"
//        x.textAlignment = .left
//        x.textColor = .lightGray
//        x.font = UIFont.systemFont(ofSize: 15)
//        return x
//    }()
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
