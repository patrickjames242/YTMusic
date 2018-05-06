//
//  ViewController.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreData






//MARK: - NAVIGATION CONTROLLER

class SongListView_NavCon: UINavigationController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .red
        viewControllers.append(AppManager.shared.songListView)
        navigationBar.shadowImage = UIImage()

        
        
    }
    
    
    
    
    
    
}









//MARK: - SONG LIST VIEW

class SongListView: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate{
    
    let cellID = "The Best cell everrrrr!!!!!"
    let headerID = "the Best HEADER EVERRRR!!!!! 😁😁"
    
    
    
    
    
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dealWithFetchedResultsController()
        setUpSearchBar()
        setUpTableView()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Songs"
        
        
        setBottomInset()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPressGesture(gesture:)))
        view.addGestureRecognizer(longPressGesture)
        
    }
    
 
    
    
    
    
    
    private func setUpTableView(){
        
        tableView.tintColor = .black
        tableView.tableFooterView = UIView()
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerID)
        tableView.sectionIndexColor = .red
        
        tableView.rowHeight = 58
        tableView.separatorInset.left = CellConstants.separatorLeftInset
        
        
        
        
    }
    
    
    
    private func setUpSearchBar(){
        
        
        
        navigationItem.searchController = self.searchController
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .red
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        
        
        
        
        tableView.keyboardDismissMode = .onDrag
        let searchBar = searchController.searchBar
        
        let coverView = UIView()
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = .white
        searchBar.addSubview(coverView)
        coverView.leftAnchor.constraint(equalTo: searchBar.leftAnchor).isActive = true
        coverView.rightAnchor.constraint(equalTo: searchBar.rightAnchor).isActive = true
        coverView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 1).isActive = true
        coverView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        
        searchController.searchBar.addSubview(coverView)
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - MODEL
    
    
    enum SongListType{ case all, search}
    
    var officialSongsTuple = (songs: [[Song]](), sectionNames: [String](), type: SongListType.all){
        didSet{
            if officialSongsTuple.songs.isEmpty && officialSongsTuple.type == .all{
                tableView?.backgroundView = AppManager.getInterfaceBackgroundViewWith(title: "Your Library Is Empty 😭", message: "Add songs from Youtube to fill your library!")
                tableView?.isScrollEnabled = false
                navigationItem.searchController = nil
            } else {
                navigationItem.searchController = searchController
                tableView?.backgroundView = nil
                tableView?.isScrollEnabled = true
            }
        }
    }
    
    var searchSongsTuple = ([[Song]](), [String]()){
        didSet{
            if officialSongsTuple.type == .all{return}
            officialSongsTuple = (searchSongsTuple.0, searchSongsTuple.1, .search)
        }
    }
    
    
    var dbSongsTuple = ([[Song]](), [String]()){
        didSet{
            
            if officialSongsTuple.type == .all{
                officialSongsTuple.songs = dbSongsTuple.0
                officialSongsTuple.sectionNames = dbSongsTuple.1
            
            }
        }
    }
    
    
    
    let searchController = UISearchController(searchResultsController: nil)

    

    
    
    private let searcher = Searcher()
    
    
    
    
    
    
    

    
    
    
    
    
    
  
    
    
    
    @objc func respondToLongPressGesture(gesture: UILongPressGestureRecognizer){
        if searcher.searchIsActive{return}
        if gesture.state == .began{
            
            let location = gesture.location(in: view)
            if let index = tableView.indexPathForRow(at: location){
                let song = officialSongsTuple.songs[index.section][index.row]
                AppManager.shared.displayActionMenuFor(song: song)

                
            }
        }
        
        
        
    }
    
    


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SEARCH BAR STUFF
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            
            officialSongsTuple.sectionNames = dbSongsTuple.1
            officialSongsTuple.songs = dbSongsTuple.0
            tableView.reloadData()
            return
            
        }
        
        searcher.getResultsFor(searchText) { (songArray) in
            if searchText != searchBar.text {return}
            
            let returnTuple = songArray.alphabetizeSongs()
            
            self.searchSongsTuple = (returnTuple.songs, returnTuple.letters)
            self.tableView.reloadData()
            
        }
        
    }
    
    var userIsSearching = false
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
        userIsSearching = true
        
        self.officialSongsTuple.type = .search
        
        searcher.beginSearchSessionWith(dbSongsTuple.0)
        
    }
    
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
        userIsSearching = false
        
        searcher.cancelCurrentSearchSession()
        
        
        officialSongsTuple = (dbSongsTuple.0, dbSongsTuple.1, .all)
        searchSongsTuple = ([[]], [])
        
        self.tableView.reloadData()
        
        
        
    }
    
    
    
    
    
    
    
    
    
    //MARK: -
    
    

    func setBottomInset(){
        
        self.tableView.contentInset.bottom = AppManager.currentAppBottomInset
        self.tableView.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset
        
    }
    
    private func getIndexPathOf(song: Song) -> IndexPath?{
        var songIndexPath: IndexPath?
        var s = 0
        for songSection in officialSongsTuple.songs{
            
            var r = 0
            for song1 in songSection{
                if song == song1{
                    songIndexPath = IndexPath(row: r, section: s)
                }
                r += 1
            }
            s += 1
        }
        return songIndexPath
    }
    
    func scrollToCellOfSong(_ song: Song){
        let songIndexPath = self.getIndexPathOf(song: song)
        
        if songIndexPath == nil { return }
        tableView.selectRow(at: songIndexPath!, animated: true, scrollPosition: .middle)
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (timer) in
            self.tableView.deselectRow(at: songIndexPath!, animated: true)
        }
    }
    
    
    
//    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        if userIsSearching {return UISwipeActionsConfiguration()}
//        let handler: UIContextualActionHandler = {(action, view, completion) in
//            let song = self.officialSongsTuple.songs[indexPath.section][indexPath.row]
//            
//            AppManager.shared.handleDeletionOf(song: song)
//            completion(false)
//        }
//        
//        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "DELETE", handler: handler)
//
//        let config = UISwipeActionsConfiguration(actions: [deleteAction])
//        
//        return config
//    }
//    
//    
    
    
    
    

    
    
    
    
    
    
    
    
    
    

        
        
        
    //MARK: - FETCHED RESULTS CONTROLLER STUFF
    
    
  
    var fetchedResultsController = NSFetchedResultsController<DBSong>()
    
    private func dealWithFetchedResultsController(){
        
        
        let fetchRequest: NSFetchRequest<DBSong> = DBSong.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController<DBSong>(fetchRequest: fetchRequest, managedObjectContext: Database.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do{
            try fetchedResultsController.performFetch()
            let fetchedObjects = fetchedResultsController.fetchedObjects!
            
            
            
            let songObjects = Song.wrap(array: fetchedObjects)
            let alphabetizedSongs = songObjects.alphabetizeSongs()
            
            self.dbSongsTuple = (alphabetizedSongs.songs, alphabetizedSongs.letters)
            
            tableView.reloadData()
            
        } catch {
           print(error)
        }
        
    }
    
    
    
    
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let newSong = Song.wrap(object: anObject as! DBSong)

        let oldSongs = dbSongsTuple.0
        
        let formattedOldIndexPath = getIndexPathOf(song: newSong)
        
        let fetchedObjects = fetchedResultsController.fetchedObjects!
        let songObjects = Song.wrap(array: fetchedObjects)
        let newSongs = songObjects.alphabetizeSongs()
        self.dbSongsTuple = (newSongs.songs, newSongs.letters)
        
        if officialSongsTuple.type == .search{return}
        
        
        let formattedNewIndexPath = getIndexPathOf(song: newSong)
        
        
        
        switch type{
        case .insert:
            if newSongs.songs[formattedNewIndexPath!.section].count == 1{
                tableView.insertSections(IndexSet(integer: formattedNewIndexPath!.section), with: .left)
                break
            }
            tableView.insertRows(at: [formattedNewIndexPath!], with: .left)
        case .delete:
            if oldSongs[formattedOldIndexPath!.section].count == 1{
                tableView.deleteSections(IndexSet(integer: formattedOldIndexPath!.section), with: .right)
                break
            }
            tableView.deleteRows(at: [formattedOldIndexPath!], with: .right)
        case .move:
            tableView.moveRow(at: formattedOldIndexPath!, to: formattedNewIndexPath!)
        case .update:
            tableView.reloadRows(at: [formattedOldIndexPath!], with: .fade)
        }
    }
    
   
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return officialSongsTuple.songs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return officialSongsTuple.songs[section].count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return officialSongsTuple.sectionNames
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSong = officialSongsTuple.songs[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MyTableViewCell
        cell.setWith(song: currentSong)
        return cell
    }
    
    
    

    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID)
        let sectionBackgroundView =
            generateSectionHeaderView(sectionTitle: officialSongsTuple.sectionNames[section])
        
        view!.backgroundView = sectionBackgroundView
        sectionBackgroundView.frame = view!.bounds
        return view
    }
    
    
    
    private func generateSectionHeaderView(sectionTitle: String) -> UIView{
        let x = UIView()
        x.backgroundColor = .white
        
        let label = UILabel()
        label.text = sectionTitle
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        x.addSubview(label)
        label.leftAnchor.constraint(equalTo: x.leftAnchor, constant: CellConstants.imageLeftInset).isActive = true
        label.centerYAnchor.constraint(equalTo: x.centerYAnchor).isActive = true
        
        return x
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.setAndPlaySong(officialSongsTuple.songs[indexPath.section][indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

















//MARK: - CELL CONSTANTS



final fileprivate class CellConstants{
    static var imageHeight: CGFloat = 48
    static var cellHeight: CGFloat = 58
    static var imageLeftInset: CGFloat = 17
    static var stackViewLeftInset: CGFloat = 15
   
    static var imageWidth: CGFloat{
        
        return imageHeight * (16 / 9)
    }
    
    static var separatorLeftInset: CGFloat{
        
        return imageLeftInset + stackViewLeftInset + imageWidth
        
    }
    static var stackViewRightInset: CGFloat = -20
    static var cellRightInset: CGFloat = 15
}























//MARK: - TABLE VIEW CELL

class MyTableViewCell: CircleInteractionResponseCell, SongObserver{
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(albumImageView)
        addSubview(textStackView)
        addSubview(nowPlayingAnimator)
      

        setConstraints()
    }
    
    
    
  
    
    
    //MARK: - CONSTRAINTS TABLE VIEW CELL
    
    private func setConstraints(){
        
        albumImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CellConstants.imageLeftInset).isActive = true
        albumImageView.widthAnchor.constraint(equalToConstant: CellConstants.imageWidth).isActive = true
        albumImageView.heightAnchor.constraint(equalToConstant: CellConstants.imageHeight).isActive = true
        albumImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textStackView.leftAnchor.constraint(equalTo: albumImageView.rightAnchor, constant: CellConstants.stackViewLeftInset).isActive = true
        textStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: CellConstants.stackViewRightInset).isActive = true
    
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SONG PLAYING STATUS DID CHANGE STUFF, TABLE VIEW CELL
    
    private var currentSong: Song?
    func setWith(song: Song){
        
        currentSong?.removeObserver(self)
        
        self.albumImageView.image = song.image
        self.topLabel.text = song.name
        self.bottomLabel.text = song.artistName
        self.currentSong = song
        song.addObserver(self)
        
        changeCellNowPlayingStateTo(state: song.nowPlayingStatus)
    
    }
    
    
    
    private func changeCellNowPlayingStateTo(state: SongPlayingStatus){
    
        
        switch state {
        case .inactive:
            nowPlayingAnimator.stopAnimating()
            topLabel.textColor = .black
            topLabel.font = UIFont.systemFont(ofSize: 17)
            bottomLabel.textColor = .gray
            
            
        case .paused:
            nowPlayingAnimator.stopAnimating()
            topLabel.textColor = .red
            bottomLabel.textColor = .red
            topLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        case .playing:
            nowPlayingAnimator.startAnimating()
            topLabel.textColor = .red
            bottomLabel.textColor = .red
            topLabel.font = UIFont.boldSystemFont(ofSize: 17)
            
        }
        
        
    }
    
    func songPlayingStatusDidChangeTo(_ status: SongPlayingStatus) {
        changeCellNowPlayingStateTo(state: status)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - OBJECTS, TABLE VIEW CELL
    
    private lazy var nowPlayingAnimator: NVActivityIndicatorView = {
        let viewFrame = CGRect(x: 0,
                               y: 0,
                               width: 20,
                               height: 20)
        let x = NVActivityIndicatorView(frame: viewFrame, type: .audioEqualizer, color: .red, padding: nil)
        x.bottomSide = 50
        x.rightSide = 100
        return x
        
    }()
    
    
    
    let albumImageView: UIImageView = {
       let x = UIImageView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.contentMode = .scaleAspectFill
        return x
        
    }()
    
    lazy var textStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        x.axis = .vertical
        x.distribution = UIStackViewDistribution.fillEqually
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    lazy var topLabel: UILabel = {
       let x = UILabel()
        x.text = "lalalala"
        x.font = UIFont.systemFont(ofSize: 17)
        x.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return x
    }()
    
    
    lazy var bottomLabel: UILabel = {
        let x = UILabel()
        x.text = "lalalal"
        x.font = UIFont.systemFont(ofSize: 12)
        x.textColor = .gray
        return x
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


















































class CircleInteractionResponseCell: UITableViewCell{
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        
        self.selectedBackgroundView = selectedView
        addGestureRecognizer(circleInteractionGesture)
        addSubview(interactionCircle)
        sendSubview(toBack: interactionCircle)

    }
    
    lazy var circleInteractionGesture = UITapGestureRecognizer(target: self, action: #selector(respondToUsersTap(gesture:)))

 
    
    @objc private func respondToUsersTap(gesture: UITapGestureRecognizer){
        
        
   
        
        let location = gesture.location(in: self)
        interactionCircle.center = location
        
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.interactionCircle.transform = CGAffineTransform(scaleX: 1500, y: 1500)
        }, completion: { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                self.interactionCircle.alpha = 0
            }, completion: { (true) in
                self.interactionCircle.alpha = 1
                self.interactionCircle.transform = CGAffineTransform.identity
            })
            
            
            
        })
        
     
        performCellTappedAction()
       
        
    }
    
    func performCellTappedAction(){
        
        if let table = superview as? UITableView, let indexPath = table.indexPath(for: self){
            
            
            table.delegate?.tableView?(table, didSelectRowAt: indexPath)
            
        }
        
    }
    


    
    private lazy var interactionCircle: UIView = {
       let x = UIView()
        x.frame.size.width = 0.5
        x.frame.size.height = 0.5
        x.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        x.layer.cornerRadius = x.frame.size.width / 2
        x.layer.masksToBounds = true
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}











