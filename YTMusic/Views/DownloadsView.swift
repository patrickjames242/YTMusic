//
//  DownloadsView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import CoreData



//MARK: - NAVIGATION CONTROLLER

class DownloadHistoryViewController: StandardAppNavigationController{
    private let mainView = _DownloadHistoryViewController()
    
    override var mainViewController: UIViewController{
        
        return mainView
    }
        
    
}











//MARK: - VIEW CONTROLLER


fileprivate class _DownloadHistoryViewController: SafeAreaObservantTableViewController, NSFetchedResultsControllerDelegate {
    
    private let cellID = "the best cell everjalskdjf;kasd"
    
    //MARK: VIEW DID LOAD

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Downloads"
        navigationItem.largeTitleDisplayMode = .always
        tableView.register(DownloadsTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorColor = .clear
        tableView.rowHeight = cellHeight
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(respondToTrashCanButtonPressed))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: pasteButton)
        

        setUpFetchedResultsController()
    }
    
    private lazy var pasteButton: UIImageView = {
        let x = UIImageView(image: #imageLiteral(resourceName: "paste").withRenderingMode(.alwaysTemplate))
        x.contentMode = .scaleAspectFit
        x.pin(size: CGSize(width: 22, height: 22))
        x.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToURLButton))
        x.addGestureRecognizer(gesture)
        
        return x
        
    }()
    

    
    
    
    @objc func respondToURLButton(){
        
        let pasteboardString: String? = UIPasteboard.general.string
        if let theString = pasteboardString {
            if let youtubeID = URLComponents(string: theString)?.queryItems?.first(where: { $0.name == "v" })?.value {

                YTAPIManager.handleDownloadOfVideoWithID(ID: youtubeID)

                return
            }
            if theString.starts(with: "https://youtu.be/"){
                let id = theString.replacingOccurrences(of: "https://youtu.be/", with: "")
                YTAPIManager.handleDownloadOfVideoWithID(ID: id)

                return
            }
        }
        
        
        AppManager.displayErrorMessage(target: self, message: "No valid Youtube video URL's were found on your clipboard.", completion: nil)
        
        
        
        
    }
    

    
    
    @objc func respondToTrashCanButtonPressed(){
        
        if downloads.isEmpty{
            AppManager.displayErrorMessage(target: self, message: "There are no downloads to be deleted 😳😳. ", completion: nil)
            return
        }
        
        let downloadsViewMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let stopAllActive = UIAlertAction(title: "Stop All Active", style: .destructive) { (action) in
            Downloader.main.cancelAllActiveDownloads()
            for download in self.downloads{
                
                switch download.runTimeStatus{
                case .paused:
                    download.deleteResumeData()
                    download.changeStatusTo(.canceled(Date()))
                default: break
                }
            }
        }
        
        let removeAll = UIAlertAction(title: "Remove All", style: .destructive) { (action) in
            for download in self.downloads{
                Downloader.main.cancelDownloadOf(item: download)
                download.delete()
            }
        }
        
        let removeAllInactive = UIAlertAction(title: "Remove All Inactive", style: .destructive) { (action) in
            for download in self.downloads{
                switch download.runTimeStatus{
                case .finished, .canceled, .failed, .paused:
                    download.delete()
                default: break
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        
        var actionsToInclude = (stopAllActive: false, removeAll: true, removeAllInactive: false)
        
        
        for download in downloads{
            
            switch download.runTimeStatus{
            case .finished, .canceled, .failed:
                actionsToInclude.removeAllInactive = true
            case .inactive, .buffering, .loading, .paused:
                actionsToInclude.stopAllActive = true
            }
            
        }
        
        if actionsToInclude.removeAll && actionsToInclude.removeAllInactive && !actionsToInclude.stopAllActive{
            downloadsViewMenu.addAction(removeAll)
        } else {
            
            if actionsToInclude.stopAllActive {downloadsViewMenu.addAction(stopAllActive)}
            if actionsToInclude.removeAllInactive {downloadsViewMenu.addAction(removeAllInactive)}
            if actionsToInclude.removeAll {downloadsViewMenu.addAction(removeAll)}
        }
        
        downloadsViewMenu.addAction(cancelAction)
        
        self.present(downloadsViewMenu, animated: true, completion: nil)
    }
    
    
    
  
    
    
    var downloads = [DownloadItem](){
        didSet{
            if downloads.isEmpty{
                tableView.backgroundView = ScrollableContentBackgroundView(title: "No Recent Downloads", message: "Search Youtube to start a download!")
                tableView.isScrollEnabled = false
            } else {
                tableView.backgroundView = nil
                tableView.isScrollEnabled = true
            }
        }
    }
    
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private var fetchedResultsController = NSFetchedResultsController<DBDownloadItem>()
    
    
    
    func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<DBDownloadItem> = DBDownloadItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "dateStarted", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Database.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try fetchedResultsController.performFetch()
        } catch {
            
            print("there was an error in the 'setUpFetchedResultsController' function in DownloadsView.swift: \(error)")
        }
        
        
        let downloadItems = DownloadItem.wrap(array: fetchedResultsController.fetchedObjects!)
        self.downloads = downloadItems
        tableView.reloadData()
        
        fetchedResultsController.delegate = self

    }
    
    

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        
        self.downloads = DownloadItem.wrap(array: controller.fetchedObjects! as! [DBDownloadItem])
        switch type{
            
        case .delete:
            if let oldIndexPath = indexPath{
                tableView.deleteRows(at: [oldIndexPath], with: .right)

            }
        case .insert:
            if let newIndexPath = newIndexPath{
                tableView.insertRows(at: [newIndexPath], with: .left)

            }
        case .move:
            if let oldindexpath = indexPath, let newIndexPath = newIndexPath{
                tableView.moveRow(at: oldindexpath, to: newIndexPath)

            }
        case .update:
            if let oldIndexPath = indexPath{
                tableView.reloadRows(at: [oldIndexPath], with: .fade)

            }
        }

    }

    
    
    
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    
    
    



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DownloadsTableViewCell
        cell.setWithDownloadItem(downloads[indexPath.row])
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloads.count
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppManager.shared.userSelectedDownloadItem(downloads[indexPath.row])
    
    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "REMOVE") { (action, indexPath2) in
            self.downloads[indexPath2.row].delete()
        }
        
        
        return [deleteAction]
    }
    
    
    
    
    
}














fileprivate let cellHeight: CGFloat = Variations.DownloadsView.cellHeight
fileprivate let separationInset: CGFloat = 11








// TABLE VIEW CELL PROTOCOL


fileprivate protocol DownloadCellDelegate: class{
    
    func userDidPressThreeDotButtonOn(_ video: DownloadItem)
    
}












// MARK: - TABLE VIEW CELL

fileprivate class DownloadsTableViewCell: CircleInteractionTableViewCell, DownloadItemDelegate{
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(myImageView)
        addSubview(textStackView)
        
        addSubview(threeDotButton_ActivationArea)
        threeDotButton_ActivationArea.addSubview(threeDotButton)
        setUpContraints()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPressGesture(gesture:)))
        addGestureRecognizer(longPressGesture)
    }
    
    
    @objc func respondToLongPressGesture(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{return}
        AppManager.shared.displayActionMenuFor(downloadItem: currentDownloadItem!)
        
    }
    
    
    
    func DLStatusDidChangeTo(_ status: DownloadStatus) {
        changeDownloadStateTo(status)
    }
    
    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        threeDotButton.tintColor = color
        if let currentItem = currentDownloadItem{
            
            switch currentItem.runTimeStatus{
            case .inactive, .buffering, .paused, .canceled, .loading:
                progressLabel.textColor = color
                threeDotButton.tintColor = color
            default: break
            }
            
        }
    }
    
    
    
    private func changeDownloadStateTo(_ status: DownloadStatus){
        progressLabel.textColor = THEME_COLOR(asker: self)
        progressLabel.font = UIFont.boldSystemFont(ofSize: 15)

        progressBar.alpha = 1
        switch status{
        case .inactive:
            
            progressLabel.text = "buffering..."
            progressBar.changeProgressTo(0)
            
            
        case .buffering:
            
            progressLabel.text = "buffering..."
            progressBar.changeProgressTo(0)
            
        case .loading(let percentage):
            
            progressLabel.text = String(Int(percentage)) + "%"
            progressBar.changeProgressTo(percentage / 100.0)
        case .finished(_, let date):
        
            progressLabel.font = UIFont.systemFont(ofSize: 12.7)
            let timeString = getTimeStringFrom(date: date)
            progressLabel.text = "finished • \(timeString)"
            progressLabel.textColor = .gray
            
            progressBar.alpha = 0
        case .paused(_, let date):
        
            let timeString = getTimeStringFrom(date: date)
            progressLabel.text = "paused • \(timeString)"
            
            progressBar.changeProgressTo(0)
            progressBar.alpha = 0
        case .failed(let date):
    
            let timeString = getTimeStringFrom(date: date)
            progressLabel.text = "failed • \(timeString)"
            progressLabel.textColor = UIColor.orange

            progressBar.alpha = 0

        case .canceled(let date):
            let timeString = getTimeStringFrom(date: date)
            progressLabel.text = "canceled • \(timeString)"
            
            progressBar.changeProgressTo(0)
            progressBar.alpha = 0
        }
    }
    
    
    
    private func getTimeStringFrom(date: Date) -> String{
        
        let seconds = Int(-date.timeIntervalSinceNow)
        let minutes = Int(seconds / 60)
        let hours = Int((Double(minutes) / 60.0).rounded())
        let days = Int((Double(hours) / 24.0).rounded())
        
        if seconds < 60{
            return "just now"
        } else if minutes < 60{
            return "\(minutes) \(minutes > 1 ? "minutes" : "minute") ago"
        } else if hours < 24{
            return "\(hours) \(hours > 1 ? "hours" : "hour") ago"
        } else {
            return "\(days) \(days > 1 ? "days" : "day") ago"
        }
        
    }
 
    
    
    private weak var currentDownloadItem: DownloadItem?{
        didSet{ if currentDownloadItem == nil{ timer.invalidate() }}
    }
    
    weak var threeButtonDelegate: DownloadCellDelegate?
    
    private var timer = Timer()
    
    func setWithDownloadItem(_ item: DownloadItem){
        
        if currentDownloadItem?.delegate === self{
            currentDownloadItem?.delegate = nil
        }
        currentDownloadItem = nil
        item.delegate = self
        currentDownloadItem = item
        
        myImageView.image = item.image
        topTextLabel.text = item.name
        middleTextLabel.text = item.channelName
        
        changeDownloadStateTo(item.runTimeStatus)
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            if self.currentDownloadItem != nil{
                DispatchQueue.main.async {
                    self.changeDownloadStateTo(self.currentDownloadItem!.runTimeStatus)
                }
                
            }
        })
        
    }
    

    
    // MARK: - TABLE VIEW CELL OBJECTS
    
    
    private lazy var progressBar: ProgressIndicator = {
        let x = ProgressIndicator()
        return x
    }()
    
    private lazy var myImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.clipsToBounds = true
        x.translatesAutoresizingMaskIntoConstraints = false
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.backgroundColor = .lightGray
        
        
        x.addSubview(progressBar)
        progressBar.pin(left: x.leftAnchor, right: x.rightAnchor, bottom: x.bottomAnchor, size: CGSize(height: 3))
        
        return x
    }()
    

    private lazy var textStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [topTextLabel, middleTextLabel, progressLabel])
        x.axis = .vertical
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    
    private lazy var topTextLabel: UILabel = {
        let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.numberOfLines = Variations.DownloadsView.topTextLabelNumberOfLines
        x.font = UIFont.systemFont(ofSize: 16)
        return x
        
    }()
    
    
    private lazy var middleTextLabel: UILabel = {
        let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.font = UIFont.systemFont(ofSize: 12.7)
        x.textColor = .gray
        return x
        
    }()
    
    
    private lazy var progressLabel: UILabel = {
        let x = UILabel()
        x.font = UIFont.boldSystemFont(ofSize: 15)
        x.textColor = THEME_COLOR(asker: self)
        return x
    }()
    
    
    private lazy var threeDotButton: UIImageView = {
        let x = UIImageView(image: UIImage(cgImage: #imageLiteral(resourceName: "icons8-more-filled-100").cgImage!, scale: 1, orientation: UIImageOrientation.left).withRenderingMode(.alwaysTemplate))
        x.tintColor = THEME_COLOR(asker: self)
        x.translatesAutoresizingMaskIntoConstraints = false
        x.contentMode = .scaleAspectFit
        return x
        
    }()
    
    private lazy var threeDotButton_ActivationArea: UIView = {
        let x = UIView()
        
        x.translatesAutoresizingMaskIntoConstraints = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToThreeDotButtonTapped))
        x.addGestureRecognizer(gesture)
        
        return x
    }()
    
    
    
    @objc private func respondToThreeDotButtonTapped(){
        
        
        AppManager.shared.displayActionMenuFor(downloadItem: currentDownloadItem!)
        
    }
    
    
    
   
    
    
    
    
    
    
    
    
    
    private let stackViewSideInset: CGFloat = 10
    
    
    
    //MARK: - TABLE VIEW CELL CONSTRAINTS
    
    
    private func setUpContraints(){
        
        
        
        myImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: separationInset).isActive = true
        myImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(separationInset / 2)).isActive = true
        myImageView.topAnchor.constraint(equalTo: topAnchor, constant: (separationInset / 2)).isActive = true
        
        let imageViewHeight = cellHeight - (separationInset)
        let estimatedImageViewWidth = imageViewHeight * (16 / 9)
        
        
        myImageView.widthAnchor.constraint(equalToConstant: estimatedImageViewWidth).isActive = true
        

        
        textStackView.leftAnchor.constraint(equalTo: myImageView.rightAnchor, constant: stackViewSideInset).isActive = true
        textStackView.topAnchor.constraint(equalTo: myImageView.topAnchor).isActive = true
        textStackView.rightAnchor.constraint(equalTo: threeDotButton_ActivationArea.leftAnchor).isActive = true
        
        
        textStackView.bottomAnchor.constraint(equalTo: textStackView.bottomAnchor).isActive = true

        
        threeDotButton_ActivationArea.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        threeDotButton_ActivationArea.topAnchor.constraint(equalTo: topAnchor).isActive = true
        threeDotButton_ActivationArea.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        threeDotButton_ActivationArea.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        threeDotButton.centerYAnchor.constraint(equalTo: threeDotButton_ActivationArea.centerYAnchor).isActive = true
        threeDotButton.centerXAnchor.constraint(equalTo: threeDotButton_ActivationArea.centerXAnchor).isActive = true
        threeDotButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        threeDotButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

