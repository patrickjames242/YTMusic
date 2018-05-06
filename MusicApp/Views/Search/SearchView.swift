//
//  SearchView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class SearchTableView_NavCon: UINavigationController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .red
        viewControllers.append(AppManager.shared.searchView)
        
        
    }
    
    
    
    
    
}







class SearchTableView: UITableViewController, UISearchBarDelegate, SearchSuggestionsCellProtocol{
 
    private lazy var searchController = UISearchController(searchResultsController: nil)

    private let cellID = "cell id yeahhhhh"

    
    
    //MARK: - VIEW DID LOAD
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = self.searchController
        //        searchController.searchBar.shadowImage = UIImage()
        
        if suggestionStrings.0.isEmpty{
            setBackgroundView()
        }
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .red
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = false
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Tap here to search"
        let coverView = UIView()
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = .white
        searchBar.addSubview(coverView)
        coverView.leftAnchor.constraint(equalTo: searchBar.leftAnchor).isActive = true
        coverView.rightAnchor.constraint(equalTo: searchBar.rightAnchor).isActive = true
        coverView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 1).isActive = true
        coverView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        tableView.contentInset.top = -10
        tableView.separatorColor = .white
        tableView.rowHeight = 60
        navigationItem.title = "Search Youtube"
        navigationItem.largeTitleDisplayMode = .always

        
        
        tableView.register(SearchSuggestionsCell.self, forCellReuseIdentifier: cellID)
        setBottomInsets()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToKeyboardChangeFrameNotification(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    
    
    
    private func setBackgroundView(){
        
        let topLabel = UILabel()
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.text = "No search suggestions 😨"
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center
        topLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        let backgroundView = UIView()
        tableView.backgroundView = backgroundView
        
        backgroundView.addSubview(topLabel)
        
        
        topLabel.pin(top: backgroundView.topAnchor, centerX: backgroundView.centerXAnchor, size: CGSize(width: 250), insets: UIEdgeInsets(top: 25))
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    enum SuggestionType{ case history, loaded}
    
    
    
    private var suggestionStrings: (stringArray: [String], type: SuggestionType) = (UserPreferences.searchHistory,  .history){
        didSet{
        if suggestionStrings.0.isEmpty{
            setBackgroundView()
        } else {
            tableView.backgroundView = nil
            }
        }
    }
    
    
    private var localSuggestionStrings = UserPreferences.searchHistory{
        didSet{
            if suggestionStrings.1 == .loaded{return}
            suggestionStrings = (localSuggestionStrings, .history)
        }
    }
    
    private var loadedSuggestionStrings = [String](){
        
        didSet{
            
            suggestionStrings = (loadedSuggestionStrings, .loaded)
            
        }
        
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SEARCH BAR STUFF
    
    
    func userDidFillText(_ text: String) {
        self.searchController.searchBar.text = text
        self.searchBar(searchController.searchBar, textDidChange: text)
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    func performSearch(){
        guard let text = self.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        if text.isEmpty{ return }
        let searchResultsView = SearchResultsTableView()
        searchResultsView.setSearchResultsWithText(text)
        
        navigationController?.pushViewController(searchResultsView, animated: true)
        
        UserPreferences.addItemToSearchHistory(text)
        localSuggestionStrings = UserPreferences.searchHistory
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        self.tableView.reloadData()
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.suggestionStrings.1 = .history
        self.localSuggestionStrings = UserPreferences.searchHistory
        self.tableView.reloadData()
    }
    
    
    
   

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            self.suggestionStrings.1 = .history
            self.localSuggestionStrings = UserPreferences.searchHistory
            self.tableView.reloadData()
            return
        }
        
        YTAPIManager.main.getAutoCompleteSuggestionsFrom(searchText: searchText) { (stringArray) in
            if searchText != searchBar.text {return}
            self.suggestionStrings = (stringArray, .loaded)
            self.tableView.reloadData()
        }
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - KEYBOARD STUFF

    
    
    
    
    
    

    private var bottomViewInset: CGFloat = 49
    
    
    private var keyboardIsVisible = false
    
    @objc func respondToKeyboardChangeFrameNotification(notification: NSNotification){
       let keyboardFrame = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        
        
        if keyboardFrame.minY >= view.frame.height{
            keyboardIsVisible = false
            setBottomInsets()
        } else {
            keyboardIsVisible = true
            tableView.contentInset.bottom = 0
            tableView.scrollIndicatorInsets.bottom = 0
        }
    }
    func setBottomInsets(){
        self.tableView.contentInset.bottom = AppManager.currentAppBottomInset + 10
        self.tableView.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset
    }

    
    

    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionStrings.0.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchSuggestionsCell
        cell.fillButtonDelegate = self
        cell.setTypeTo(suggestionStrings.1)
        cell.setLabelTextTo(suggestionStrings.0[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenString = suggestionStrings.0[indexPath.row]
        searchController.searchBar.text = chosenString
        performSearch()
        suggestionStrings = (localSuggestionStrings, .history)
        tableView.reloadData()
        
    }
}






















fileprivate protocol SearchSuggestionsCellProtocol{
    
    func userDidFillText(_ text: String)
    
}


//MARK: - TABLE VIEW CELL

fileprivate final class SearchSuggestionsCell: CircleInteractionResponseCell{
    
    
    //MARK: - INIT, TABLE VIEW CELL
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(fillButtonActivationArea)
        fillButtonActivationArea.addSubview(fillButtonImage)
        addSubview(searchIcon)
        setUpConstraints()
        
        
        
        
    }
    
    func setTypeTo(_ type: SearchTableView.SuggestionType){
        
        self.searchIcon.image = ((type == .loaded) ? #imageLiteral(resourceName: "searchSuggestionsSearchIcon") : #imageLiteral(resourceName: "searchHistory")).withRenderingMode(.alwaysTemplate)
        
    }

    
    func setLabelTextTo(_ text: String){
        titleLabel.text = text
    }
    
    var fillButtonDelegate: SearchSuggestionsCellProtocol?
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - OBJECTS, TABLE VIEW CELL
    
    
    private lazy var titleLabel: UILabel = {
      let x = UILabel()
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    private lazy var fillButtonImage: UIImageView = {
       let x = UIImageView(image: #imageLiteral(resourceName: "searchSuggestionsArrow").withRenderingMode(.alwaysTemplate))
        x.tintColor = .lightGray
        x.translatesAutoresizingMaskIntoConstraints = false
        
        return x
    }()
    
    private lazy var fillButtonActivationArea: UIView = {
       let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(respondToFillButtonTapped))
        x.addGestureRecognizer(recognizer)
        return x
    }()
    
    @objc private func respondToFillButtonTapped(){
        if titleLabel.text == nil{return}
        fillButtonDelegate?.userDidFillText(titleLabel.text!)
    }
    
    private lazy var searchIcon: UIImageView = {
       let x = UIImageView(image: #imageLiteral(resourceName: "searchSuggestionsSearchIcon").withRenderingMode(.alwaysTemplate))
        x.tintColor = .lightGray
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
        
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - CONSTRAINTS
    
    private func setUpConstraints(){
        
        searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        searchIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        searchIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        searchIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        fillButtonActivationArea.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        fillButtonActivationArea.topAnchor.constraint(equalTo: topAnchor).isActive = true
        fillButtonActivationArea.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        fillButtonActivationArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        fillButtonImage.centerXAnchor.constraint(equalTo: fillButtonActivationArea.centerXAnchor).isActive = true
        fillButtonImage.centerYAnchor.constraint(equalTo: fillButtonActivationArea.centerYAnchor).isActive = true
        
        
        fillButtonImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        fillButtonImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fillButtonImage.transform = CGAffineTransform(rotationAngle:
            (90 + 45 + 90).degreesToRadians)

        
        titleLabel.leftAnchor.constraint(equalTo: searchIcon.rightAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: searchIcon.centerYAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: fillButtonActivationArea.leftAnchor, constant: -10).isActive = true
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}


































