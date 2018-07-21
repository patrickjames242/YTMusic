//
//  TabBarController_MAIN.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/24/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MediaPlayer
import Foundation


class Screen: CustomTabBarController {

    
    
    override init(){
        super.init()
        setItems(items: [songItem, searchItem, downloadsItem, settingsItem])
        
        
    }
    
    //MARK: - CHILD VIEW CONTROLLERS
    
    
    let libraryVC = LibraryViewController()
    let settingsVC = SettingsViewController()
    let downloadsVC = DownloadHistoryViewController()
    let searchVC = YoutubeSearchViewController()

    lazy var songItem = CustomTabBarItem(tag: 1, image: #imageLiteral(resourceName: "note"), viewController: libraryVC)
    lazy var searchItem = CustomTabBarItem(tag: 2, image: #imageLiteral(resourceName: "search"), viewController: searchVC)
    lazy var downloadsItem = CustomTabBarItem(tag: 3, image: #imageLiteral(resourceName: "downloadIcon"), viewController: downloadsVC, imagePadding: UIEdgeInsets(top: 6))
    lazy var settingsItem = CustomTabBarItem(tag: 4, image: #imageLiteral(resourceName: "settingsIcon"), viewController: settingsVC)
    
    
    lazy var nowPlayingVC = NowPlayingViewController()
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addChildViewController(nowPlayingVC)
        
        view.addSubview(nowPlayingVC.view)
        nowPlayingVC.setAllConstraintsToParent()


        view.backgroundColor = .black
        
        view.bringSubview(toFront: tabBar)
        
        delegate_Stuff_To_Be_Done_In_ViewDidLoad()
        
        
    }
    
    
    // MARK: - SHOW / HIDE THE TAB BAR
    
    
    
    func showTabBar(){
        UIView.animate(withDuration: 0.3) {
            self.tabBar.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
            
        }
    }
    
    func dismissTabBar(){
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: self.tabBar.frame.height)
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    var desiredStatusBarStyle: UIStatusBarStyle = .default

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return desiredStatusBarStyle
    }
    
    
    
    
    
    
    
    
    
    // MARK: - OBJECTS
    
    
    var snapshotView: UIView!

    
    
    
    
    
  
    var preferredCornerRadius: CGFloat = 13
    
    
    
    //MARK: - SWITCHING BETWEEN TAB BAR ITEMS
    
  
    override func itemTappedSameAsCurrentlyDisplayedItem(item: CustomTabBarItem) {
        super.itemTappedSameAsCurrentlyDisplayedItem(item: item)
        let itemView = item.view
        if itemView === searchVC.view{
            searchVC.popToRootViewController(animated: true)
        } else if itemView === settingsVC.view{
            settingsVC.popToRootViewController(animated: true)
        } else if itemView === libraryVC.view{
            libraryVC.page()
        }
        
        
    }
    
    

    
    
    

    
    
    
    
   
    
    
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }

 
    
}

