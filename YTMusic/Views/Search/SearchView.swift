//
//  SearchView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class YoutubeSearchViewController: StandardAppNavigationController{
    
    
    private let mainController = _YoutubeSearchViewController()
    
    override var mainViewController: UIViewController{
        return mainController
    }
    
    
    
}







fileprivate class _YoutubeSearchViewController: SafeAreaObservantTableViewController, UISearchBarDelegate, SearchSuggestionsCellDelegate, SearchSuggestionsBrainDelegate{
  
 
    private lazy var searchController = UISearchController(searchResultsController: nil)

    private let cellID = "cell id yeahhhhh"

    
   
    
    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        searchController.searchBar.tintColor = color
    }
    
    
    
    //MARK: - VIEW DID LOAD
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = self.searchController
        //        searchController.searchBar.shadowImage = UIImage()
        
       
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = THEME_COLOR(asker: self)
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
        
        
        tableView.separatorColor = .white
        tableView.rowHeight = 60
        navigationItem.title = "Search Youtube"
        navigationItem.largeTitleDisplayMode = .always

        suggestionBrain = SearchSuggestionsBrain(owner: self)
        
        tableView.register(SearchSuggestionsCell.self, forCellReuseIdentifier: cellID)
        
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
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    private var searchSuggestions: (strings: [String], type: SuggestionsType) = ([], .history){
        didSet{
            if searchSuggestions.strings.isEmpty{
                setBackgroundView()
                tableView.isScrollEnabled = false
            } else {
                tableView.backgroundView = nil
                tableView.isScrollEnabled = true
            }
        }
    }
    
    
    
    
    
    
    
    //MARK: - SEARCH BAR STUFF
    
    private var suggestionBrain: SearchSuggestionsBrain!
    
    
    
    func searchSuggestions(didChangeTo suggestions: [String], type: SuggestionsType) {
        
        searchSuggestions = (suggestions, type)
        
       
        
        
        tableView.reloadData()
        
    }
 
    
    
    
    
    
    func userDidFillText(_ text: String) {
        searchController.searchBar.text = text
        suggestionBrain.searchTextDidChangeTo(text: text)
        searchController.searchBar.becomeFirstResponder()
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(with: searchBar.text!)
    }
    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        suggestionBrain.searchTextDidChangeTo(text: nil)
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        suggestionBrain.searchTextDidChangeTo(text: searchText)
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
        
    }
    
    
    

    
    
    func performSearch(with text: String){
        searchController.searchBar.text = text
        suggestionBrain.userDidPressSearch(for: text)
        let newResultsController = SearchResultsTableView()
        newResultsController.setSearchResultsWithText(text)
        navigationController?.pushViewController(newResultsController, animated: true)
        
        
    }
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    //MARK: - TABLE VIEW FUNCTIONS
    
    

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if searchSuggestions.type == .loaded{return UISwipeActionsConfiguration()}

        let handler: UIContextualActionHandler = { (action, view, completion) in
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.suggestionBrain.userDidRemoveEntry(text: self.searchSuggestions.strings[indexPath.row])
            self.searchSuggestions.strings.remove(at: indexPath.row)
            
            tableView.endUpdates()
            
            completion(true)
           
        }
        let action = UIContextualAction(style: UIContextualAction.Style.destructive, title: "REMOVE", handler: handler)
        action.backgroundColor = .red
        
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSuggestions.strings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchSuggestionsCell
        cell.configure(sender: self, type: searchSuggestions.type, text: searchSuggestions.strings[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSearch(with: searchSuggestions.strings[indexPath.row])
        
        
    }
}






















fileprivate protocol SearchSuggestionsCellDelegate{
    
    func userDidFillText(_ text: String)
    
}


//MARK: - TABLE VIEW CELL

fileprivate final class SearchSuggestionsCell: CircleInteractionTableViewCell{
    
    
    //MARK: - INIT, TABLE VIEW CELL
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(fillButtonActivationArea)
        fillButtonActivationArea.addSubview(fillButtonImage)
        addSubview(searchIcon)
        setUpConstraints()
        
        
        
        
    }
    
    
    func configure(sender: SearchSuggestionsCellDelegate, type: SuggestionsType, text: String){
        
        
        self.searchIcon.image = ((type == .loaded) ? #imageLiteral(resourceName: "searchSuggestionsSearchIcon") : #imageLiteral(resourceName: "searchHistory")).withRenderingMode(.alwaysTemplate)
        
        titleLabel.text = text

        fillButtonDelegate = sender
        
    }
    

    
    private var fillButtonDelegate: SearchSuggestionsCellDelegate?
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
