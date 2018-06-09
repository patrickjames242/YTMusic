//
//  SearchResultsView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MediaPlayer





class SearchResultsTableView: SafeAreaObservantTableViewController, SearchResultsTableViewCellDelegate {

    private let searchResultsAmount = 50

    
    //MARK: - VIEW CONTROLLER LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.backgroundView = UIView()
        
        tableView.backgroundView!.addSubview(progressAnimator)
        

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.action
        tableView.rowHeight = cellHeight
        tableView.separatorColor = .clear
        tableView.contentInset.top = -3
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: cellID)
        
        additionalSafeAreaInsets.bottom = AppManager.currentAppBottomInset + (separationInset / 2)
        
    }
    
    
    
    private func setUpBottomLoader(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        progressAnimator.startAnimating()
        
    }
    
    
 
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - INITS
    
    
    init() {
        super.init(style: .plain)
    }
    



    
    
    
    

 

    
    
    private let cellID = "cell id yeahhhhh"
    
    private var videos = [YoutubeVideo]()
    
    


    
    private func removeProgressAnimator(){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.progressAnimator.alpha = 0
        }) { (bool) in
            self.progressAnimator.stopAnimating()
            self.progressAnimator.removeFromSuperview()
        }
        
        
        
    }
    
    
    
    func userWantsMenuPresented(for video: YoutubeVideo, sourceView: UIView) {
        displayActionMenuFor(video: video, sourceView: sourceView)
    }
    
    
    
    
    private func displayActionMenuFor(video: YoutubeVideo, sourceView: UIView) {
        
        let controller = UIAlertController(title: "Video Options", message: video.name, preferredStyle: .actionSheet)
        
        let downloadAction = UIAlertAction(title: "Download Audio", style: .default) { (action) in
            
            Downloader.main.beginDownloadOf(video)
            
        }
        
        let relatedVideosAction = UIAlertAction(title: "See Related Videos", style: .default){ (action) in
            
            let newResultsView = SearchResultsTableView()
            newResultsView.setRelatedVideosTo(vidID: video.videoID)
            newResultsView.navigationItem.title = "Related To: " + video.name
            self.navigationController?.pushViewController(newResultsView, animated: true)

        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        controller.addAction(relatedVideosAction)
        controller.addAction(downloadAction)
        controller.addAction(cancelAction)
        
        if let popper = controller.popoverPresentationController{
            popper.sourceView = sourceView
            popper.permittedArrowDirections = .up
        }
        
        AppManager.shared.screen.present(controller, animated: true, completion: nil)
        
        
    }
    
    
    
    func setSearchResultsWithText(_ text: String){
        navigationItem.title = text

        YTAPIManager.main.getYoutubeSearchResultsWith(searchText: text, amount: searchResultsAmount) { [weak weakSelf = self] (youtubeResponse) in
            if let weakSelf = weakSelf {
                weakSelf.dealWithYoutubeVideoQueryResults(response: youtubeResponse)
            }
            
            
        }
        
    }
    
    
    
    
    
    //MARK: YOUTUBE API STUFF
    
    private var currentResponse: YoutubeSearchResponse?
    
    
    private func getAdditionalResults(){
        guard let currentResponse = self.currentResponse else {return}
        
        YTAPIManager.main.getNextPageOfYoutubeSearchResults(using: currentResponse, amount: searchResultsAmount, completion: {self.dealWithYoutubeVideoQueryResults(response: $0, isAdditionalResults: true)})
        
    }
    
    
    func setRelatedVideosTo(vidID: String){
        
        YTAPIManager.main.getRelatedVidoesTo(vidID: vidID) { [weak weakSelf = self] (youtubeResponse)  in
            guard let weakSelf = weakSelf else {return}
            weakSelf.dealWithYoutubeVideoQueryResults(response: youtubeResponse)
        }
    }
    
    
    
    private func dealWithYoutubeVideoQueryResults(response: YoutubeSearchResponse, isAdditionalResults: Bool = false){
        removeProgressAnimator()
        
        if response.error != nil{
            if isAdditionalResults{return}
            AppManager.displayErrorMessage(target: self, message: response.error!.localizedDescription){
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        checkForDoubleVideo(videos: response.videos, functionName: #function)
    
        if response.videos.isEmpty {
            if isAdditionalResults{return}
            AppManager.displayErrorMessage(target: self, message: "There are no videos to display."){
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        
        
        
        currentResponse = response

        
        if isAdditionalResults{
            videos.append(contentsOf: response.videos)
            let offset = tableView.contentOffset
            tableView.reloadData()
            tableView.contentOffset = offset
        } else {
            tableView.beginUpdates()

            videos = response.videos
            let newIndices = Array<Int>(videos.indices)
            tableView.insertRows(at: newIndices.map{IndexPath.init(row: $0, section: 0)}, with: .fade)
            tableView.endUpdates()

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - PROGRESS ANIMATOR
    
   lazy var progressAnimator: NVActivityIndicatorView = {
        let size: CGFloat = 70
        let progressAnimatorFrame = CGRect(x: (tableView.frame.width / 2) - (size / 2)  ,
                                           y: tableView.backgroundView!.centerInBounds.y - 200,
                                           width: size,
                                           height: size)
        
        
        let progressAnimator = NVActivityIndicatorView(frame: progressAnimatorFrame,
                                                       type: NVActivityIndicatorType.ballRotateChase,
                                                       color: THEME_COLOR(asker: self),
                                                       padding: nil)
        return progressAnimator
    }()
 
  
 

    
    
    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        
        progressAnimator.color = color
        
        if progressAnimator.isAnimating{
            progressAnimator.stopAnimating()
            progressAnimator.startAnimating()
        }
        
    }
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchResultsTableViewCell
        
        cell.setCellWith(video: videos[indexPath.row], delegate: self)
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenVideo = videos[indexPath.row]

        
        
        if let controller = AppManager.prepareYoutubeVideo(videoID: chosenVideo.videoID){
            AppManager.shared.screen.present(controller, animated: true, completion: nil)
        }

    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let handler: UIContextualActionHandler = { (action, view, completion) in
            
            Downloader.main.beginDownloadOf(self.videos[indexPath.row])
            completion(true)
        }
        let action = UIContextualAction(style: UIContextualAction.Style.normal, title: "DOWNLOAD", handler: handler)
        action.backgroundColor = THEME_COLOR(asker: self)
        
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == videos.lastItemIndex!{
            self.getAdditionalResults()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}










































fileprivate let cellHeight: CGFloat = Variations.SearchResultsView.cellHeight
fileprivate let separationInset: CGFloat = 15





fileprivate protocol SearchResultsTableViewCellDelegate{
    
    func userWantsMenuPresented(for video: YoutubeVideo, sourceView: UIView)
}




//MARK: - TABLE VIEW CELL


fileprivate class SearchResultsTableViewCell: CircleInteractionTableViewCell, YoutubeVideoDelegate{
    
    

    
    //MARK: - INIT, TABLE VIEW CELL
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        
        setUpViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToSongDeletedNotification(notification:)), name: MNotifications.SongWasDeletedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToSongCreatedNotification(notification:)), name: MNotifications.NewSongWasCreatedNotification, object: nil)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPress))
        addGestureRecognizer(longPressGesture)
    }
    
    
    @objc func respondToSongCreatedNotification(notification: Notification){
        guard let currentVideo = currentVideo else {return}
        if let song = notification.userInfo?[MNotifications.NewlyCreatedSongObjectKey] as? Song{
            
            if song.youtubeID! == currentVideo.videoID{
                UIView.animate(withDuration: 0.3) {
                    self.downloadedIndicator.alpha = 1
                    self.downloadedIndicator_holderView.alpha = 1
                }
            }
        }
    }
    
    
    @objc func respondToSongDeletedNotification(notification: Notification){
        guard let currentVideo = currentVideo else {return}
        
        let song = notification.userInfo![MNotifications.DeletedSongObjectKey]! as! Song
        
        if song.youtubeID == currentVideo.videoID{
            UIView.animate(withDuration: 0.3) {
                self.downloadedIndicator.alpha = 0
                self.downloadedIndicator_holderView.alpha = 0
            }
            
        }
        
        
    }
    
    
    @objc private func respondToLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{return}
        resultsCellDelegate?.userWantsMenuPresented(for: currentVideo!, sourceView: self)
    }
    
    
    

    
    
    
    private var currentVideo: YoutubeVideo?
    
    
    
    lazy var imageReceivedClosure = { (wasDownloaded: Bool, sender: YoutubeVideo, image: UIImage) in
        
        guard let currentVideo = self.currentVideo else {return}
        
        if !wasDownloaded{self.setImageViewWith(image: image, animated: false); return}
        if sender === currentVideo { self.setImageViewWith(image: image, animated: true) }
        
    }

    
    
    
    
    
    
    var resultsCellDelegate: SearchResultsTableViewCellDelegate?
    

    func setCellWith(video: YoutubeVideo, delegate: SearchResultsTableViewCellDelegate){
        

        myImageView.image = nil
        currentVideo?.resignAsDelegate(self)
        currentVideo = video
        video.registerAsDelegate(self)
        resultsCellDelegate = delegate
    

        
        
        topTextLabel.text = video.name
        middleTextLabel.text = video.channel
        bottomTextLabel.text = video.views + " • " + video.date
        timeStamp.text = video.duration
        
        
        
        
        if Song.isDownloaded(youtubeID: video.videoID){
            downloadedIndicator_holderView.alpha = 1
            downloadedIndicator.alpha = 1
        } else {
            downloadedIndicator_holderView.alpha = 0
            downloadedIndicator.alpha = 0
        }

    }
    
    
    
    private func setImageViewWith(image: UIImage, animated: Bool){
        
        myImageView.stopAnimations()
        
        
        
        myImageView.alpha = 0
        myImageView.image = image
        
        
        if animated{
            UIView.animate(withDuration: 0.3) {
                self.myImageView.alpha = 1

                
            }
        } else {
            self.myImageView.alpha = 1
        }
    }
    
    

    
    
    
    
    
    
    
    // MARK: - OBJECTS, TABLE VIEW CELL
    

    private lazy var imageHolderView: UIView = {
       let x = UIView()
        x.clipsToBounds = true
        x.translatesAutoresizingMaskIntoConstraints = false
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        return x
    }()
    
    private lazy var myImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.translatesAutoresizingMaskIntoConstraints = false
        x.alpha = 0
        return x
    }()
    
    
    private lazy var downloadedIndicator_holderView: UIView = {
        let y = UIView()
        
        y.backgroundColor = THEME_COLOR(asker: self)
        y.layer.cornerRadius = 5
        y.layer.masksToBounds = true
        y.alpha = 0
        return y
    }()
    
    private lazy var downloadedIndicator: UILabel = {
        
        let x = UILabel()
        x.text = "Downloaded"
        x.textColor = .white
        
        x.font = UIFont.boldSystemFont(ofSize: 13)
        x.alpha = 0
        return x
        
    }()

    
    private lazy var timeStamp: UILabel = {
       let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.textColor = .white
        x.font = UIFont.systemFont(ofSize: 13)
        x.text = "3:22"
        return x
    }()
    
    private lazy var timeStampHolder: UIView = {
        let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = .black
        x.alpha = 0.9
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        x.addSubview(timeStamp)
        return x
    }()
    
    
    private lazy var textStackView: UIStackView = {
       let x = UIStackView(arrangedSubviews: [topTextLabel, middleTextLabel, bottomTextLabel])
        x.axis = .vertical
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    
    private lazy var topTextLabel: UILabel = {
       let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.numberOfLines = Variations.SearchResultsView.topTextLabel_NumberOfLines
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
    
    
    private lazy var bottomTextLabel: UILabel = {
        let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.font = UIFont.systemFont(ofSize: 12.7)
        x.textColor = .gray
        return x
        
    }()
    
    
    private lazy var threeDotButton: UIImageView = {
       let x = UIImageView(image: UIImage(cgImage: #imageLiteral(resourceName: "icons8-more-filled-100").cgImage!, scale: 1, orientation: UIImageOrientation.left).withRenderingMode(.alwaysTemplate))
        x.tintColor = THEME_COLOR(asker: self)
        x.translatesAutoresizingMaskIntoConstraints = false
        x.contentMode = .scaleAspectFit
        return x
        
    }()
    
    override func interfaceColorDidChange(to color: UIColor) {
        threeDotButton.tintColor = color
        
        downloadedIndicator_holderView.backgroundColor = color
        
    }
    
    private lazy var threeDotButton_ActivationArea: UIView = {
       let x = UIView()
        
        x.translatesAutoresizingMaskIntoConstraints = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(respondToThreeDotButtonTapped))
        x.addGestureRecognizer(gesture)
        
        return x
    }()
    

    
    @objc private func respondToThreeDotButtonTapped(){
        
            resultsCellDelegate?.userWantsMenuPresented(for: currentVideo!, sourceView: self)
    }
    
    
    
    private let stackViewSideInset: CGFloat = 10
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - CONSTRAINTS
    
    
    private func setUpViews(){
        
        
        addSubview(imageHolderView)
        imageHolderView.addSubview(myImageView)
        addSubview(textStackView)
        addSubview(timeStampHolder)
        addSubview(timeStamp)
        addSubview(threeDotButton_ActivationArea)
        
        addSubview(downloadedIndicator_holderView)
        addSubview(downloadedIndicator)
        threeDotButton_ActivationArea.addSubview(threeDotButton)
        
        
        
        downloadedIndicator_holderView.pinAllSidesTo(downloadedIndicator, insets: UIEdgeInsets(allInsets: -3))
        
        
        downloadedIndicator.pin(left: imageHolderView.leftAnchor, top: imageHolderView.topAnchor, insets: UIEdgeInsets(top: 8, left: 8))
        
        
        
        imageHolderView.leftAnchor.constraint(equalTo: leftAnchor, constant: separationInset).isActive = true
        imageHolderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(separationInset / 2)).isActive = true
        imageHolderView.topAnchor.constraint(equalTo: topAnchor, constant: (separationInset / 2)).isActive = true
        
        let imageViewHeight = cellHeight - (separationInset)
        let estimatedImageViewWidth = imageViewHeight * (16 / 9)

        
        imageHolderView.widthAnchor.constraint(equalToConstant: estimatedImageViewWidth).isActive = true
        
        
        myImageView.pinAllSidesTo(imageHolderView)
        
        
        
        
        timeStamp.bottomAnchor.constraint(equalTo: imageHolderView.bottomAnchor, constant: -9).isActive = true
        timeStamp.rightAnchor.constraint(equalTo: imageHolderView.rightAnchor, constant: -9).isActive = true
        
        let timeStampHolderOutset: CGFloat = 3
        
        timeStampHolder.topAnchor.constraint(equalTo: timeStamp.topAnchor, constant: -timeStampHolderOutset).isActive = true
        timeStampHolder.bottomAnchor.constraint(equalTo: timeStamp.bottomAnchor, constant: timeStampHolderOutset).isActive = true
        timeStampHolder.leftAnchor.constraint(equalTo: timeStamp.leftAnchor, constant: -timeStampHolderOutset).isActive = true
        timeStampHolder.rightAnchor.constraint(equalTo: timeStamp.rightAnchor, constant: timeStampHolderOutset).isActive = true
        
        
        
        textStackView.leftAnchor.constraint(equalTo: imageHolderView.rightAnchor, constant: stackViewSideInset).isActive = true
        textStackView.topAnchor.constraint(equalTo: imageHolderView.topAnchor).isActive = true
        textStackView.rightAnchor.constraint(equalTo: threeDotButton_ActivationArea.leftAnchor).isActive = true
    
        
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



