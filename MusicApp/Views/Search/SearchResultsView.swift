//
//  SearchResultsView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/10/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MediaPlayer
//MARK: - TABLE VIEW CONTROLLER





class SearchResultsTableView: UITableViewController, SearchResultsTableViewCellDelegate {

    

    
    //MARK: - VIEW CONTROLLER LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.backgroundView = UIView()
        
        tableView.backgroundView!.addSubview(progressAnimator)
        

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        tableView.rowHeight = cellHeight
        tableView.separatorColor = .clear
        tableView.contentInset.top = -3
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: cellID)
        
        tableView.contentInset.bottom = AppManager.currentAppBottomInset + (separationInset / 2)
        
        tableView.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset + (separationInset / 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        progressAnimator.startAnimating()
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {

        if self.isMovingFromParentViewController{
            let index = SearchResultsTableView.currentViews.index(of: self)
            SearchResultsTableView.currentViews.remove(at: index!)
            self.videos = []
            tableView.reloadData()
        
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - INITS
    
    
    init() {
        super.init(style: .plain)
        SearchResultsTableView.currentViews.append(self)
    }
    



    //MARK: -
    
    
    
    static var currentViews = [SearchResultsTableView]()
    

 

    
    static func setBottomInsets(){
        for x in currentViews{
            x.tableView.contentInset.bottom = AppManager.currentAppBottomInset + (separationInset / 2)
            x.tableView.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset + (separationInset / 2)
        }
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

        YTAPIManager.main.getYoutubeSearchResultsWith(searchText: text, amount: 50) { [weak weakSelf = self] (videos, error) in
            if let weakSelf = weakSelf {
                weakSelf.dealWithYoutubeVideoQueryResults(resultingVideos: videos, error: error)
            }
            
            
        }
        
    }
    
    
    
    
    
    //MARK: YOUTUBE API STUFF
    
    
    func setRelatedVideosTo(vidID: String){
        
        YTAPIManager.main.getRelatedVidoesTo(vidID: vidID) { [weak weakSelf = self] (videoArray, error)  in
            
            guard let weakSelf = weakSelf else {return}
            
            weakSelf.dealWithYoutubeVideoQueryResults(resultingVideos: videoArray, error: error)
        }
        
        
    }
    
    
    
    private func dealWithYoutubeVideoQueryResults(resultingVideos: [YoutubeVideo]?, error: Error?){
        removeProgressAnimator()
        
        if error != nil{
            AppManager.displayErrorMessage(target: self, message: error!.localizedDescription){
        
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        guard let unwrappedVideos = resultingVideos, !unwrappedVideos.isEmpty else {
            
            
            AppManager.displayErrorMessage(target: self, message: "There are no videos to display."){
                
                self.navigationController?.popViewController(animated: true)
                
                
            }
            return
        }
        
        videos = unwrappedVideos
        tableView.reloadData()
        
        
        
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


fileprivate class SearchResultsTableViewCell: CircleInteractionResponseCell, YoutubeVideoDelegate{
    

    
    //MARK: - INIT, TABLE VIEW CELL
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        
        setUpViews()
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(respondToLongPress))
        addGestureRecognizer(longPressGesture)
    }
    
    
    
    @objc private func respondToLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{return}
        resultsCellDelegate?.userWantsMenuPresented(for: currentVideo!, sourceView: self)
    }
    
    
    

    
    
    
    private var currentVideo: YoutubeVideo?
    
    
    
    

    func imageDidFinishDownloading(video: YoutubeVideo, image: UIImage) {
        guard let currentVideo = currentVideo else {return}
        if video == currentVideo{ setImageViewWith(image: image) }
        
    }
    
    
    
    var resultsCellDelegate: SearchResultsTableViewCellDelegate?
    

    func setCellWith(video: YoutubeVideo, delegate: SearchResultsTableViewCellDelegate){
        
        
        
        currentVideo?.delegate = nil
        video.delegate = self
        currentVideo = video
        resultsCellDelegate = delegate
        
        myImageView.image = nil
        topTextLabel.text = video.name
        middleTextLabel.text = video.channel
        bottomTextLabel.text = video.views + " • " + video.date
        timeStamp.text = video.duration
        
        
        
        if let image = video.image{
            myImageView.image = image
        } else {
            video.initiateImageDownloadIfNeeded()
        }
        
        
    }
    
    
    
    func setImageViewWith(image: UIImage){
        if myImageView.isAnimating {
            myImageView.stopAnimating()
        }
        
        
        myImageView.alpha = 0
        myImageView.image = image
        
        UIView.animate(withDuration: 0.3) {
            
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
        
        threeDotButton_ActivationArea.addSubview(threeDotButton)
        
        
        
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







































