//
//  RecentlyAddedView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import CoreData


//MARK: - NAVIGATION CONTROLLER


class RecentlyAdded_NavCon: UINavigationController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .red
        viewControllers.append(AppManager.shared.recentlyAddedView)
    }
    
    
    
    
}











//MARK: - COLLECTION VIEW CONTROLLER

class RecentlyAddedView: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate{
    
    
    
    
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Recently Added"
        
        collectionView?.contentInset = UIEdgeInsets(top: distanceBetweenColumns - 13, left: 0, bottom: AppManager.currentAppBottomInset, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: distanceBetweenColumns - 13, left: 0, bottom: AppManager.currentAppBottomInset, right: 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        setUpFetchedResultsController()
    }
    
    
    
    func setBottomInset(){
        collectionView?.contentInset.bottom = AppManager.currentAppBottomInset
        collectionView?.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset
    }
    
    
    
    
    
    
    
    
    
    
    private let cellID = "The best cell in existence!!!"
    
    private let distanceBetweenColumns: CGFloat = 20
    
    private var songs = [Song](){
        didSet{
            if songs.isEmpty{
                collectionView?.backgroundView = AppManager.getInterfaceBackgroundViewWith(title: "Your Library Is Empty 😭", message: "Add songs from Youtube to fill your library!")
                collectionView?.isScrollEnabled = false
            } else {
                collectionView?.backgroundView = nil
                collectionView?.isScrollEnabled = true
            }
        }
    }
    
    
    
    
    
    
    private func instantiateSongsArray(with array: [Song]){
        var editableArray = array
        
        while editableArray.count > 50{
            
            editableArray.removeLast()
            
        }
        self.songs = editableArray
        

    }
    
    
    private var fetchedResultsController: NSFetchedResultsController<DBSong>!
    
    
    func scrollToCellOfSong(_ song: Song){
        var x = 0
        for song1 in songs{
            
            if song1 == song{
                let indexPath = IndexPath(item: x, section: 0)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                
                var numberOfTimes = 0
                
                func check(){
                    numberOfTimes += 1
                    if let cell = collectionView?.cellForItem(at: indexPath) as? MyCollectionViewCell{
                        cell.highlight()
                        
                    } else {
                        if numberOfTimes >= 10 { return }
                        
                        // this is done because there may not be a collection view cell at the index path at the point at which the collection view is scrolling to the cell.
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                            check()
                        }
                    }
                }
                
                check()
                return
            }
            
            x += 1
        }
        
    }
    
    
    
    
    
    
    // MARK: - FETCHED RESULTS CONTROLLER SETUP
    
    private func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        
        let sort = NSSortDescriptor.init(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sort]
        fetchedResultsController = NSFetchedResultsController<DBSong>.init(fetchRequest: fetchRequest, managedObjectContext: Database.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        var fetchedObjects = [DBSong]()
        
        do{
            try fetchedResultsController.performFetch()
            fetchedObjects = fetchedResultsController.fetchedObjects!
        } catch {
            print("An error occured in the 'setUpFetchedResultsController' in RecentlyAddedView.swift")
        }
        
        self.instantiateSongsArray(with: Song.wrap(array: fetchedObjects))
        collectionView!.reloadData()
        
    }
    
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let fetchedObjects = fetchedResultsController.fetchedObjects!
        
        self.instantiateSongsArray(with: Song.wrap(array: fetchedObjects))
        collectionView!.reloadData()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    //MARK: - COLLECTION VIEW FUNCTIONS
    
    
   
    

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.shared.setAndPlaySong(songs[indexPath.item])
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MyCollectionViewCell
        cell.setWith(song: songs[indexPath.item])
        
        return cell
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: distanceBetweenColumns,
                            bottom: 0,
                            right: distanceBetweenColumns)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return distanceBetweenColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns = Variations.RecentlyAddedView.numberOfItemColumns
        let numberOfSpacings = numberOfColumns + 1
        let spaceTakenUpByColumns = numberOfSpacings * distanceBetweenColumns
        
        let albumCoverWidth = ((view.frame.width - spaceTakenUpByColumns) / numberOfColumns) - 1
        
        let height = (albumCoverWidth * (9/16)) + 47

        return CGSize(width: albumCoverWidth, height: height)
    }
    
}








//MARK: - COLLECTION VIEW CELL

class MyCollectionViewCell: UICollectionViewCell, SongObserver{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(highlightedView)
        addSubview(albumCover)
        addSubview(nowPlayingAnimator)
        addSubview(labelsStackView)
        
        
        
        setUpAllConstraints()
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongTap(gesture:)))
        addGestureRecognizer(longTap)
    }
    
    @objc func respondToLongTap(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began{
            AppManager.shared.displayActionMenuFor(song: currentSong!)
        }
    }
    
    
    func setWith(song: Song){
        self.currentSong?.removeObserver(self)
        self.albumCover.image = song.image
        self.albumName.text = song.name
        self.albumArtist.text = song.artistName
        song.addObserver(self)
        currentSong = song
        changeCellNowPlayingStateTo(state: song.nowPlayingStatus)
    }
    
    
    private var currentSong: Song?
    
    
    private func changeCellNowPlayingStateTo(state: SongPlayingStatus){
        
        
        
        switch state {
        case .inactive:
            nowPlayingAnimator.stopAnimating()
            albumName.textColor = .black
            albumName.font = UIFont.systemFont(ofSize: 15)
            albumArtist.textColor = .lightGray
            
        case .paused:
            nowPlayingAnimator.stopAnimating()
            albumArtist.textColor = .red
            albumName.font = UIFont.boldSystemFont(ofSize: 15)
            albumName.textColor = .red
            
        case .playing:
            nowPlayingAnimator.startAnimating()
            albumArtist.textColor = .red
            albumName.font = UIFont.boldSystemFont(ofSize: 15)
            albumName.textColor = .red
        }
    }
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus) {
        changeCellNowPlayingStateTo(state: status)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - CONSTRAINTS, COLLECTION VIEW CELL
    
    
    private func setUpAllConstraints(){
        albumCover.topAnchor.constraint(equalTo: topAnchor).isActive = true
        albumCover.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        albumCover.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        albumCover.heightAnchor.constraint(equalTo: albumCover.widthAnchor, multiplier: 9/16).isActive = true
        
        labelsStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        labelsStackView.topAnchor.constraint(equalTo: albumCover.bottomAnchor, constant: 5).isActive = true
        labelsStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        highlightedView.topAnchor.constraint(equalTo: topAnchor, constant: -5).isActive = true
        highlightedView.leftAnchor.constraint(equalTo: leftAnchor, constant: -5).isActive = true
        highlightedView.rightAnchor.constraint(equalTo: rightAnchor, constant: 5).isActive = true
        highlightedView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - OBJECTS, COLLECTION VIEW CELL
    
    
    private lazy var nowPlayingAnimator: NVActivityIndicatorView = {
        
        let albumWidth = self.frame.width
        let albumHeight = albumWidth * (9/16)
        
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: 25,
                               height: 25)
        let x = NVActivityIndicatorView(frame: viewFrame, type: .audioEqualizer, color: .red, padding: nil)
        
        x.bottomSide = albumHeight - 7
        x.rightSide = albumWidth - 7
        
        return x
        
    }()
    
    private lazy var albumCover: UIImageView = {
        let x = UIImageView()
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.contentMode = .scaleAspectFill
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [albumName,albumArtist])
        x.axis = .vertical
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    private lazy var albumName: UILabel = {
        let x = UILabel()
        x.text = "TESTING TESTING 123"
        x.font = UIFont.systemFont(ofSize: 15)
        x.textAlignment = .left
        return x
    }()
    
    
    private lazy var albumArtist: UILabel = {
        let x = UILabel()
        x.text = "TESTING TESTING 123"
        x.textAlignment = .left
        x.textColor = .lightGray
        x.font = UIFont.systemFont(ofSize: 13)
        return x
    }()
    
    private lazy var highlightedView: UIView = {
        let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = UIColor.lightGray
        x.alpha = 0
        x.layer.cornerRadius = 8
        x.layer.masksToBounds = true
        x.isUserInteractionEnabled = false
        return x
    }()
    
    
    
    func highlight(){
        UIView.animate(withDuration: 0.2, animations: {
            self.highlightedView.alpha = 0.5
        }) { (success) in
            
            
            UIView.animate(withDuration: 1.5, animations: {
                self.highlightedView.alpha = 0
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}














