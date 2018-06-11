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
        navigationBar.tintColor = THEME_COLOR(asker: self)
        viewControllers.append(mainViewController)
    }
    
    func scrollToCellOf(song: Song){
        mainViewController.scrollToCellOfSong(song)
    }
    
    private let mainViewController = RecentlyAddedView(collectionViewLayout: UICollectionViewFlowLayout())
    
    override func interfaceColorDidChange(to color: UIColor) {
        navigationBar.tintColor = color
    }
    
    
    
    
}











//MARK: - COLLECTION VIEW CONTROLLER

class RecentlyAddedView: SafeAreaObservantCollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate{
    
    
    
    
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Recently Added"
        
        collectionView?.contentInset = UIEdgeInsets(top: distanceBetweenColumns - 13, left: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: distanceBetweenColumns - 13, left: 0,right: 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        setUpFetchedResultsController()
    }
    
    

    
    
    
    
    
    
    
    
    private let cellID = "The best cell in existence!!!"
    
    private let distanceBetweenColumns: CGFloat = 20
    
    private var songs = [Song](){
        didSet{
            if songs.isEmpty{
                collectionView?.backgroundView = ScrollableContentBackgroundView(title: "Your Library Is Empty 😭", message: "Add songs from Youtube to fill your library!")
                
                
                collectionView?.isScrollEnabled = false
            } else {
                collectionView?.backgroundView = nil
                collectionView?.isScrollEnabled = true
            }
        }
    }
    
    
    
    
    

    
    
    private var fetchedResultsController: NSFetchedResultsController<DBSong>!
    
    
    func scrollToCellOfSong(_ song: Song){
        
        for (x, song1) in songs.enumerated(){
            
            if song1 == song{
                let indexPath = IndexPath(item: x, section: 0)
                collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                
                let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                    guard let collection = self.collectionView?.cellForItem(at: indexPath) as? CircleInteractionCollectionViewCell else { return }
                    collection.highLight()
                    timer.invalidate()
                }
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer2) in
                    timer.invalidate(); timer2.invalidate()
                }
                RunLoop.current.add(timer, forMode: .commonModes)
                return
                
            }
        }
    }
    
    
    
    
    
    
    // MARK: - FETCHED RESULTS CONTROLLER SETUP
    
    private func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        
        let sort = NSSortDescriptor.init(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 50
        fetchedResultsController = NSFetchedResultsController<DBSong>.init(fetchRequest: fetchRequest, managedObjectContext: Database.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        var fetchedObjects = [DBSong]()
        
        do{
            try fetchedResultsController.performFetch()
            fetchedObjects = fetchedResultsController.fetchedObjects!
        } catch {
            print("An error occured in the 'setUpFetchedResultsController' in RecentlyAddedView.swift")
        }
        
        self.songs = Song.wrap(array: fetchedObjects)
        collectionView!.reloadData()
        
    }
    
    func getIndexPath(for song: Song) -> IndexPath?{
        for song1 in songs where song1 === song{
            if let index = songs.index(of: song){
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }
    

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
       
        
        
        
        collectionView?.performBatchUpdates({

            
            let newSongs = Song.wrap(array: controller.fetchedObjects! as! [DBSong])
            
            self.songs = newSongs

            switch type{
            case .delete:
                self.collectionView?.deleteItems(at: [indexPath!])
            case .update:
                self.collectionView?.reloadItems(at: [indexPath!])
            case .insert:
                self.collectionView?.insertItems(at: [newIndexPath!])
            case .move:
                self.collectionView?.moveItem(at: indexPath!, to: newIndexPath!)

            }
        }, completion: nil)
        
        
        
        
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

class MyCollectionViewCell: CircleInteractionCollectionViewCell, SongObserver{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    override var interactionAreaInsets: UIEdgeInsets{
        return UIEdgeInsets(top: -5, left: -5, bottom: 0, right: -5)
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
    
    
    private weak var currentSong: Song?
    
    
    private func changeCellNowPlayingStateTo(state: SongPlayingStatus){
        
        
        
        switch state {
        case .inactive:
            nowPlayingAnimator.stopAnimating()
            albumName.textColor = .black
            albumName.font = UIFont.systemFont(ofSize: 15)
            albumArtist.textColor = .lightGray
            
        case .paused:
            nowPlayingAnimator.stopAnimating()
            albumArtist.textColor = THEME_COLOR(asker: self)
            albumName.font = UIFont.boldSystemFont(ofSize: 15)
            albumName.textColor = THEME_COLOR(asker: self)
            
        case .playing:
            nowPlayingAnimator.startAnimating()
            albumArtist.textColor = THEME_COLOR(asker: self)
            albumName.font = UIFont.boldSystemFont(ofSize: 15)
            albumName.textColor = THEME_COLOR(asker: self)
        }
    }
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus) {
        changeCellNowPlayingStateTo(state: status)
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        nowPlayingAnimator.color = color
        
        if nowPlayingAnimator.isAnimating{
            nowPlayingAnimator.stopAnimating()
            nowPlayingAnimator.startAnimating()
        }
        
        
        if let currentSong = currentSong{
            if currentSong.nowPlayingStatus == .paused || currentSong.nowPlayingStatus == .playing{
                albumArtist.textColor = color
                albumName.textColor = color
            }
        }
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
  
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - OBJECTS, COLLECTION VIEW CELL
    
    
    private lazy var nowPlayingAnimator: NVActivityIndicatorView = {
        
        let albumWidth = self.frame.width
        let albumHeight = albumWidth * (9/16)
        
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: 25,
                               height: 25)
        let x = NVActivityIndicatorView(frame: viewFrame, type: .audioEqualizer, color: THEME_COLOR(asker: self), padding: nil)
        
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
    

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}








//
//
//class CircleInteractionCollectionViewCell: UICollectionViewCell{
//
//
//
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//
//
//
//        addGestureRecognizer(circleInteractionGesture)
//        addSubview(highlightedView)
//        highlightedView.addSubview(interactionCircle)
//
//        highlightedView.pinAllSidesTo(self, insets: UIEdgeInsets(top: -selectedViewOutset, left: -selectedViewOutset, right: -selectedViewOutset))
//
//    }
//
//    private let selectedViewOutset: CGFloat = 5
//
//
//
//    func highlight(){
//        makeHighlightedViewAppear { (success) in
//            self.makeHighlightedViewDisappear()
//        }
//    }
//
//
//    private lazy var highlightedView: UIView = {
//        let x = UIView()
//        x.translatesAutoresizingMaskIntoConstraints = false
//        x.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
//        x.layer.cornerRadius = 8
//        x.layer.masksToBounds = true
//        x.isUserInteractionEnabled = false
//        return x
//    }()
//
//
//
//
//
//
//
//    private lazy var circleInteractionGesture = UITapGestureRecognizer(target: self, action: #selector(respondToUsersTap(gesture:)))
//
//
//
//    @objc private func respondToUsersTap(gesture: UITapGestureRecognizer){
//
//        if gesture.state != .ended {return}
//
//
//        let rawLocation = gesture.location(in: self)
//        let location = convert(rawLocation, to: highlightedView)
//
//        interactionCircle.center = location
//
//        bringSubview(toFront: highlightedView)
//
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
//            self.sendSubview(toBack: self.highlightedView)
//            timer.invalidate()
//        }
//        UIView.animate(withDuration: 0.5, animations: {
//            self.interactionCircle.transform = CGAffineTransform(scaleX: 1000, y: 1000)
//        }, completion: { (success) in
//            UIView.animate(withDuration: 0.4, animations: {
//                self.interactionCircle.alpha = 0
//            }, completion: { (success) in
//
//                self.interactionCircle.alpha = 1
//                self.interactionCircle.transform = CGAffineTransform.identity
//            })
//
//
//
//        })
//
//
//        cellTappedAction()
//
//
//    }
//
//    private func cellTappedAction(){
//
//        if let collectionView = superview as? UICollectionView, let indexPath = collectionView.indexPath(for: self){
//
//            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
//
//
//        }
//
//    }
//
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        makeHighlightedViewAppear()
//
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        makeHighlightedViewDisappear()
//    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        makeHighlightedViewDisappear()
//    }
//
//    private func makeHighlightedViewAppear(completion: ((Bool) -> Void)? = nil){
//
//
//        UIView.animate(withDuration: 0.2, animations: {
//
//            self.highlightedView.backgroundColor = self.highlightedView.backgroundColor?.withAlphaComponent(0.5)
//
//
//        }) { (success) in
//            if let completion = completion{
//                completion(success)
//            }
//        }
//    }
//
//    private func makeHighlightedViewDisappear(){
//
//        UIView.animate(withDuration: 1.5, animations: {
//            self.highlightedView.backgroundColor = self.highlightedView.backgroundColor?.withAlphaComponent(0)
//        })
//
//    }
//
//
//
//
//
//    private lazy var interactionCircle: UIView = {
//        let x = UIView()
//        x.frame.size.width = 0.5
//        x.frame.size.height = 0.5
//        x.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
//        x.layer.cornerRadius = x.frame.size.width / 2
//        x.layer.masksToBounds = true
//        return x
//    }()
//
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//}
//













