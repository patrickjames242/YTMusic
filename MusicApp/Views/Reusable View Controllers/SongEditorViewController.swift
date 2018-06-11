//
//  SongEditorViewController.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




class SongEditorView: PortraitNavigationController{
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func interfaceColorDidChange(to color: UIColor) {
        navigationBar.tintColor = color
    }
    
    init(song: Song){
        super.init(rootViewController: SongEditorViewController(song: song))
        navigationBar.tintColor = THEME_COLOR(asker: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Why are you using this init for SongEditorView")
    }
    
}











fileprivate class SongEditorViewController: UITableViewController, UITextFieldDelegate{
    
    private var currentSong: Song
    
    init(song: Song){
        self.currentSong = song
        super.init(style: .grouped)
        navigationItem.title = "Edit Song"
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !rightBarButtonItem.isEnabled {return false}
        
        respondToSaveButton()
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset.left = 0
        tableView.rowHeight = 50
        navigationItem.title = "Edit Song"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(respondToCancelButton))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
   
    
    
    private func createCell(completion: (UITableViewCell) -> Void) -> UITableViewCell{
        let newCell = UITableViewCell(style: .default, reuseIdentifier: "heloooooooo")
        completion(newCell)
        return newCell
    }
    
    
    let rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(respondToSaveButton))
    
    @objc func respondToSaveButton(){
        currentSong.changeNamesTo(title: textField1.text!, artist: textField2.text!)
        [textField1, textField2].forEach{ $0.resignFirstResponder() }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func respondToCancelButton(){
        [textField1, textField2].forEach{ $0.resignFirstResponder()}

        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    @objc func respondToTextFieldDidChangeTextNotification(notification: NSNotification){
        
        guard let textField = notification.object as? UITextField else { return }
        guard let text = textField.text else {

            self.rightBarButtonItem.isEnabled = false
            return

        }

        if text.removeWhiteSpaces().isEmpty{
            self.rightBarButtonItem.isEnabled = false
        } else {
            self.rightBarButtonItem.isEnabled = true
        }
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        textField1.tintColor = color
        textField2.tintColor = color
    }
    
    
    
    private lazy var textField1: UITextField = {
        let x = UITextField()
        x.text = currentSong.name
        x.placeholder = "Song Name"
        x.clearButtonMode = .always
        x.tintColor = THEME_COLOR(asker: self)
        x.delegate = self
        x.autocapitalizationType = UITextAutocapitalizationType.words
        x.translatesAutoresizingMaskIntoConstraints = false
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextFieldDidChangeTextNotification(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: x)
        return x
    }()
    
    
    
    private lazy var textField2: UITextField = {
        let x = UITextField()
         x.text = currentSong.artistName
        x.placeholder = "Song Artist"
        x.clearButtonMode = .always
        x.tintColor = THEME_COLOR(asker: self)
        x.delegate = self
        x.autocapitalizationType = UITextAutocapitalizationType.words
        x.translatesAutoresizingMaskIntoConstraints = false
        NotificationCenter.default.addObserver(self, selector: #selector(respondToTextFieldDidChangeTextNotification(notification:)), name: NSNotification.Name.UITextFieldTextDidChange, object: x)
        return x
    }()
    
    let textFieldInsets: CGFloat = 20
    
    lazy var cells = [
    
        self.createCell { (cell) in
            
            cell.addSubview(textField1)
            
            textField1.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: textFieldInsets).isActive = true
            textField1.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -textFieldInsets).isActive = true
            textField1.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            textField1.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            cell.layoutIfNeeded()
            textField1.becomeFirstResponder()
        },
        
        
        
        self.createCell { (cell) in
            
            cell.addSubview(textField2)
            
            textField2.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: textFieldInsets).isActive = true
            textField2.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -textFieldInsets).isActive = true
            textField2.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            textField2.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        }
    
    ]
    
    
    
    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Why in the living hell are you calling this init fool")
    }
}


















