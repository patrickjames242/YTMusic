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
        navigationBar.tintColor = THEME_COLOR(asker: self)
        viewControllers.append(mainView)
    }
    
    private let mainView = MusicSettings()
    
    override func interfaceColorDidChange(to color: UIColor) {
        navigationBar.tintColor = color
    }
    
    
}






class MusicSettings: SafeAreaObservantTableViewController, MFMailComposeViewControllerDelegate{
    
    
    init(){
        super.init(style: .grouped)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Settings"
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
            
            SettingsCell(text: "General", type: SettingsCellIconType.general),
            
            SettingsCell(text: "Configure Audio Panning", type: SettingsCellIconType.panning),
            
            SettingsCell(text: "Configure App Theme Color", type: SettingsCellIconType.color),
            
            SettingsCell(text: "Allow Notifications", type: SettingsCellIconType.notifications)
        ],
        
        // NEW SECTION
        
        [
            SettingsCell(text: "Report a Bug", type: SettingsCellIconType.bug),
            
            SettingsCell(text: "Give Feedback", type: SettingsCellIconType.feedback),
            
            ],
        
        [
            
            SettingsCell(text: "Share This App", type: SettingsCellIconType.share)
            
            
        ]
        
    ]
    
    var tableViewCellHeaderStrings = [
        nil,
        "app settings",
        "support",
        "spread the word"
    ]
    
    
    
    var cellFooterStrings = [
        nil,
        nil,
        
        "I'd really appreciate your constructive feedback 😇!",
        "Why not tell your friends and family! It's a great app after all!"
    ]
    

    
    
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
        return cellFooterStrings[section]
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: 0){
            return 130
        }
        
        return 50
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath{
        
        
            
            
        case IndexPath(item: 0, section: 1):
            
            navigationController?.pushViewController(AppInfoTableView(), animated: true)
            
        case IndexPath(item: 1, section: 1):
            
            navigationController?.pushViewController(AudioPanningTableView(), animated: true)
        
        case IndexPath(item: 2, section: 1):
            
            navigationController?.pushViewController(ColorPicker(), animated: true)
            
        case IndexPath(item: 3, section: 1):
            AppManager.displayErrorMessage(message: "Sorry, this feature is not available.", completion: nil)
            
        case IndexPath(item: 0, section: 2), IndexPath(item: 1, section: 2):
            
            
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
        case IndexPath(item: 0, section: 3):
            AppManager.displayErrorMessage(message: "Sorry, this feature is not available.", completion: nil)
            
        
        default: break
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
    
    
    
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil{ AppManager.displayErrorMessage(target: self, message: error!.localizedDescription, completion: nil); return}
        
        controller.dismiss(animated: true, completion: nil)
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}



private enum SettingsCellIconType: String{ case general, panning, color, notifications, bug, feedback, share }



fileprivate class SettingsCell: UITableViewCell{
    
    init(text: String, type: SettingsCellIconType){
        super.init(style: .default, reuseIdentifier: "ya ma")
        accessoryType = .disclosureIndicator
        label.text = text
        iconImageView.image = iconImageFor(type: type)
    
        setUpViews()
        
    }
    
    
    
    
    
  
    
    private func iconImageFor(type: SettingsCellIconType) -> UIImage{
        
        switch type{
        case .bug: return #imageLiteral(resourceName: "errorTriangle")
        case .color: return #imageLiteral(resourceName: "fillBucket")
        case .feedback: return #imageLiteral(resourceName: "feedback")
        case .general: return #imageLiteral(resourceName: "infoIcon")
        case .notifications: return #imageLiteral(resourceName: "bell")
        case .panning: return #imageLiteral(resourceName: "equalizer")
        case .share: return #imageLiteral(resourceName: "shareIcon")
        }
        
        
    }
    
    
    private lazy var label: UILabel = {
        let x = UILabel()
        
        return x
        
    }()
    
    private lazy var iconImageView: UIImageView = {
        let x = UIImageView()
        x.contentMode = .scaleAspectFit
        return x
        
        
    }()
    
    
    
    private func setUpViews(){
        
        addSubview(label)
        addSubview(iconImageView)
        
        let ICON_SIZE: CGFloat = 35
        
        iconImageView.pin(left: leftAnchor, centerY: centerYAnchor, size: CGSize(width: ICON_SIZE, height: ICON_SIZE), insets: UIEdgeInsets(left: 15))
        
        label.pin(left: iconImageView.rightAnchor, centerY: centerYAnchor, insets: UIEdgeInsets(left: 15))
        
        
    }
    
    
    
    
    
    
    
    
    
 
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}












