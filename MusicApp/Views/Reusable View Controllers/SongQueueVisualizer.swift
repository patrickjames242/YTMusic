//
//  SongQueueVisualizer.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
enum SongQueueVisualizerType { case history, upNext}


class SongQueueVisualizer: UITableViewController{
    
    private let cellID = "The song queue visualizer cell"
    
    
    private var songs: [Song]{
        
        didSet{
            if songs.isEmpty{
                setBackgroundView()
            } else {
                tableView.backgroundView = nil
            }
        }
    }
    
    
    
    private let type: SongQueueVisualizerType
    private weak var reorderingDelegate: SongReorderingObserver?
    
    init(songs: [Song], type: SongQueueVisualizerType, reorderingDelegate: SongReorderingObserver){
        self.reorderingDelegate = reorderingDelegate
        self.type = type
        self.songs = songs
        super.init(style: .plain)
        
        
    }
    
    private func setBackgroundView(){

        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.text = "There are no songs in your \(type == .history ? "history" : "up next") queue 😱."
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center
        topLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        let backgroundView = UIView()
        tableView.backgroundView = backgroundView
        
        backgroundView.addSubview(topLabel)
        
        
        topLabel.pin(top: backgroundView.topAnchor, centerX: backgroundView.centerXAnchor, size: CGSize.init(width: 250), insets: UIEdgeInsets(top: 170))

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if songs.isEmpty{setBackgroundView()}
        
        tableView.register(SongQueueCell.self, forCellReuseIdentifier: cellID)

        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = CellConstants.cellHeight
        tableView.separatorInset.left = CellConstants.separatorLeftInset
        let inset = (CellConstants.imageLeftInset / 2) + 3
        tableView.contentInset = UIEdgeInsets(top:inset, bottom: inset)
        tableView.setEditing(type == .upNext, animated: false)
        tableView.allowsSelectionDuringEditing = true
        tableView.reloadData()
        
        if songs.isEmpty{return}
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)

        
    }
    
 
    
 
    
    func songQueueDidChange(type: SongQueueChangeType, at indexPaths: [IndexPath], newArray: [Song]){

        

        
       tableView.beginUpdates()
        
        switch type{
        case .fill:
            
            tableView.insertRows(at: indexPaths, with: .fade)
        case .insert:
            tableView.insertRows(at: indexPaths, with: .fade)
        case .delete:
            
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
        songs = newArray
        
        tableView.endUpdates()
        
        
        
        guard let selectedIndexes = tableView.indexPathsForSelectedRows else {return}
        
        for index in selectedIndexes{

            tableView.deselectRow(at: index, animated: true)

        }
    }

    
    
    @objc private  func respondtoDismissButtonTapped(){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SongQueueCell
        cell.setWith(song: songs[indexPath.row], type: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

        return type == .upNext
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        songs.insert(songs.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        
        reorderingDelegate?.songWasReordered(song: songs[destinationIndexPath.row], oldIndexPath: sourceIndexPath, newIndexPath: destinationIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.setAndPlaySong(songs[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Why are you using the coder init for SongQueue Visualizer")
    }
    
    
    
}






















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
    
    static var cellRightInset: CGFloat = 15
}









class SongQueueCell: CircleInteractionTableViewCell {
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(albumImageView)
        addSubview(textStackView)
        
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
        cellRightInset = textStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: showsReorderControl ? -50 : -15)
        cellRightInset.isActive = true
        
    }
    
    private var cellRightInset: NSLayoutConstraint!
    
   
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    func setWith(song: Song, type: SongQueueVisualizerType){
        
        
        self.albumImageView.image = song.image
        self.topLabel.text = song.name
        self.bottomLabel.text = song.artistName
        
        cellRightInset.constant = (type == .upNext) ? -50 : -15
        
    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
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
        
        let fontName = x.font.familyName
      
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











