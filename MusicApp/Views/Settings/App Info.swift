//
//  App Info.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



class AppInfoTableView: UITableViewController{


    init(){
        super.init(style: .grouped)
        
        navigationItem.largeTitleDisplayMode = .never
        
    }




    override func viewDidLoad() {
        super.viewDidLoad()

        initiateStatistics()

    }

    
    private func initiateStatistics(){
        
        countCell.setInfoText(to: String(Song.count()))
        
//        Song.getNumberOfBytes { (int) in
//            print(int)
//            let string = self.convertBytesToString(int: int)
//            self.memoryCell.setInfoText(to: string)
//        }
        
    }
    
    
    private func convertBytesToString(int: Int) -> String{
        
        
        
        if int < 1000000{
            return String(format: "%.1f", int / 1000) + " KB"
        } else if int < 1000000000 {
            return String(format: "%.1f", int / 1000000) + " MB"
        } else {
            return String(format: "%.1f", int / 1000000000 ) + " GB"
        }
        
        
    }
    

    
    

    private let countCell = AppInfoTableViewCell(text: "Number Of Songs")
    
    
    private lazy var cells: [[UITableViewCell]] = [
        [
            self.countCell,
        ],
        
        [
            MiddleTextCell(text: "Remove All Search History")
        ],
        
        [
            MiddleTextCell(text: "Purge Through All Songs")
        ],
        
        [
            MiddleTextCell(text: "Delete All Songs")
        ]
        
    ]
    
    private let cellFooterStrings = [
        nil,
        "This clears all the Youtube search history currently stored on the device",
        "Select multiple songs, and delete them all at the same time.",
        "This deletes ALL songs currently in your library. Be warned that deleted songs cannot be recovered."
    ]
    
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return cellFooterStrings[section]
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cells[indexPath.section][indexPath.row]

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }





    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath{
        
        case IndexPath(row: 0, section: 1):
            respondToDeleteAllHistoryButtonPressed()
            
        case IndexPath(row: 0, section: 2):
            respondToPurgeSongsButtonPressed()
            
        case IndexPath(row: 0, section: 3):
            respondToDeleteAllSongsButtonPressed()
            
        
        default: break
            
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    private func respondToDeleteAllHistoryButtonPressed(){
        let alert = UIAlertController(title: "You're About To Delete All Search History.", message: "Are you sure this is what you want to do?", preferredStyle: .alert)
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            UserPreferences.removeAllItemsFromSearchHistory()

            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    private func respondToPurgeSongsButtonPressed(){
        
        AppManager.displayErrorMessage(target: self, message: "Sorry, this feature is not available yet.", completion: nil)
        
        
    }



    private func respondToDeleteAllSongsButtonPressed(){
        
        let alert = UIAlertController(title: "Are you absolutely sure?", message: "Deleted songs cannot be recovered.", preferredStyle: .alert)
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            let alert2 = UIAlertController(title: "Are you sure sure sure?", message: "I'm just making sure.", preferredStyle: .actionSheet)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                
                Song.deleteAll{
                    
                    self.initiateStatistics()
                    
                }
                
            })
            
            
            let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert2.addAction(cancelAction2)
            alert2.addAction(deleteAction2)
            self.present(alert2, animated: true, completion: nil)
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
        
    }


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}











fileprivate class AppInfoTableViewCell: UITableViewCell{
    
    
    init(text: String){
        super.init(style: .default, reuseIdentifier: "blah blah blah")
        textLabel?.text = text
        selectionStyle = .none
        setUpViews()
        
    }
    
    
    
    
    func setInfoText(to text: String){
        
        self.infoLabel.text = text
        
    }
    
    private lazy var infoLabel: UILabel = {
        let x = UILabel()
        
        x.text = "Calculating..."
        x.textColor = .lightGray
        return x
    }()
    
    
    private func setUpViews(){
        addSubview(infoLabel)
        let INSET: CGFloat = 15
        
        infoLabel.pin(right: rightAnchor,centerY: centerYAnchor, insets: UIEdgeInsets(right: INSET))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
}










class MiddleTextCell: UITableViewCell{
    
    init(text: String){
        
        super.init(style: .default, reuseIdentifier: "alskdfja;sdkj")
        
        middleTextLabel.text = text
        addSubview(middleTextLabel)
        middleTextLabel.pin(centerX: centerXAnchor, centerY: centerYAnchor)
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        middleTextLabel.textColor = color
    }
    
    private lazy var middleTextLabel: UILabel = {
        let x = UILabel()
        
//        x.textColor = UIColor(red: 0, green: 122, blue: 255)
        x.textColor = THEME_COLOR(asker: self)
        return x
        
        
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}



















