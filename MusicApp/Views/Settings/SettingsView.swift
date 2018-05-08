//
//  SettingsView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MessageUI

class MusicSettings_NavCon: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = false
    
        viewControllers.append(AppManager.shared.musicSettings)
    }
    
    
}






class MusicSettings: UITableViewController, MFMailComposeViewControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Settings"
        setBottomInset()
    }
    
    func create(completion: (UITableViewCell) -> Void) -> UITableViewCell{
        let newCell = UITableViewCell(style: .default, reuseIdentifier: "blah blah blah")
        completion(newCell)
        
        return newCell
    }
    
    
    lazy var tableViewCells = [
        
        // NEW SECTION
        
        [
            self.create(completion: { (cell) in
                let aboutMe = AboutMeView()
                cell.addSubview(aboutMe)
                cell.selectionStyle = .none
                let INSET: CGFloat = 15
                
                aboutMe.pin(left: cell.leftAnchor, right: cell.rightAnchor, top: cell.topAnchor, bottom: cell.bottomAnchor, insets: UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET))
                
            })
            
        ],
        

        
        // NEW SECTION
        
        [
            self.create { (cell) in
                cell.textLabel?.text = "App Info"
                cell.accessoryType = .disclosureIndicator
            },
            
            self.create { (cell) in
                cell.textLabel?.text = "Configure Audio Channels"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            },
            
            self.create(completion: { (cell) in
                cell.textLabel?.text = "Change App Theme Color"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }),
            
            self.create(completion: { (cell) in
                cell.textLabel?.text = "Allow Notifications"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

            })
        ],
        
        // NEW SECTION
        
        [
            self.create{ (cell) in
                cell.textLabel?.text = "Report a Bug or Give Feedback"
                cell.accessoryType = .disclosureIndicator
                
            }
            
        ],
        
        // NEW SECTION
        
        [
            self.create(completion: { (cell) in
                let deleteLabel = UILabel()
                deleteLabel.translatesAutoresizingMaskIntoConstraints = false
                deleteLabel.text = "Delete All Songs"
                deleteLabel.textColor = .red
                
                cell.addSubview(deleteLabel)
                
                deleteLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                deleteLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            })
        
        ]
    
    ]
    
    var tableViewCellHeaderStrings = [
    nil,
    "app settings",
    "support",
    nil,

    
    
    ]
    
    var tableViewCellFooterStrings = [
        nil,
        nil,
        "Tell me what you think of the app! 🙃😇",
        
        "Deletes all songs in the library. Note: deleted songs cannot be recovered!"
    ]
    
    
    func setBottomInset(){
        self.tableView.contentInset.bottom = AppManager.currentAppBottomInset
        self.tableView.scrollIndicatorInsets.bottom = AppManager.currentAppBottomInset
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCells[indexPath.section][indexPath.row]
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCells[section].count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCells.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewCellHeaderStrings[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewCellFooterStrings[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: 0){
            return 130
        }
        
        return 50
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == IndexPath(item: 0, section: 2){
            
            
            if MFMailComposeViewController.canSendMail(){
                let newController = MFMailComposeViewController()
                newController.setSubject("Music App Feedback")
                newController.setToRecipients(["patrickjh1998@hotmail.com"])
                newController.setMessageBody("Hey Patrick, your app is awesome!", isHTML: false)
                newController.mailComposeDelegate = self
                self.present(newController, animated: true, completion: nil)
            } else {
                AppManager.displayErrorMessage(target: self, message: "For some reason, iOS is now allowing this app to send emails. Check your email settings.", completion: nil)
            }
            
            
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
    
    
    
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil{ AppManager.displayErrorMessage(target: self, message: error!.localizedDescription, completion: nil); return}
        
        controller.dismiss(animated: true, completion: nil)
        
        
        
        
    }
    
    
    
    
    
    
    
    
    //MARK: - INITIALIZING BULLSHIT
    
    override init(style: UITableViewStyle) { super.init(style: .grouped) }
    
    init(){ fatalError("Don't use the 'init()' initializer to initialize a Music Settings View Controller!!!!") }; required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}












