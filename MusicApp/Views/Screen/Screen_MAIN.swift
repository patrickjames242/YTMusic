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


class Screen: PortraitViewController, CustomTabBarDelegate{

    
    
    
    
    //MARK: - CHILD VIEW CONTROLLERS
    
    
    let libraryView = LibraryViewController()
    let settingsView = SettingsViewController()
    let downloadsView = DownloadHistoryViewController()
    let searchView = YoutubeSearchViewController()

    lazy var nowPlayingView = NowPlayingViewController()
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addChildViewController(libraryView)
        addChildViewController(searchView)
        addChildViewController(downloadsView)
        addChildViewController(settingsView)
        addChildViewController(nowPlayingView)
        
        
        view.addSubview(holderView)
        view.addSubview(nowPlayingView.view)
        view.addSubview(tabBar)
        holderView.pinAllSidesTo(view)
        
        nowPlayingView.setAllConstraintsToParent()


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

    
    
    
    
    lazy var holderView: UIView = {
       let x = UIView(frame: view.bounds)
        x.layer.masksToBounds = true
        x.backgroundColor = .white
        x.translatesAutoresizingMaskIntoConstraints = false
        
        x.addSubview(settingsView.view)
        x.addSubview(searchView.view)
        x.addSubview(downloadsView.view)
        x.addSubview(shadeView)
        x.addSubview(libraryView.view)
        
        shadeView.pinAllSidesTo(x)
        libraryView.view.pinAllSidesTo(x)
        searchView.view.pinAllSidesTo(x)
        downloadsView.view.pinAllSidesTo(x)
        settingsView.view.pinAllSidesTo(x)
        
        
        return x
        
    }()
    

    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        tabBar.tintColor = color
    }
    

    
    
    
    lazy var songItem = CustomTabBarItem(tag: 1, image: #imageLiteral(resourceName: "note"), viewController: self.libraryView)
    lazy var searchItem = CustomTabBarItem(tag: 2, image: #imageLiteral(resourceName: "search"), viewController: self.searchView)
    lazy var downloadsItem = CustomTabBarItem(tag: 3, image: #imageLiteral(resourceName: "downloadIcon"), viewController: self.downloadsView, imagePadding: UIEdgeInsets(top: 6))
    
    lazy var settingsItem = CustomTabBarItem(tag: 4, image: #imageLiteral(resourceName: "settingsIcon"), viewController: self.settingsView)

    
    
    lazy var tabBar: CustomTabBar = {
        let x = CustomTabBar(items: [songItem, searchItem, downloadsItem, settingsItem], delegate: self)
        x.tintColor = THEME_COLOR(asker: self)
        return x
        
    }()
    

    private lazy var shadeView: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()

    
    
    
    
    
    
   
    
    
    
    var preferredCornerRadius: CGFloat = 13
    
    
    
    
    



    
    
    


    
    
    //MARK: - SWITCHING BETWEEN TAB BAR ITEMS
    
    func customTabBar(tabBar: CustomTabBar, itemWasSelected newItem: CustomTabBarItem, oldItem: CustomTabBarItem?, animationFinishedBlock: @escaping () -> Void) {
        
        let timer = Timer(timeInterval: 0.3, repeats: false) { (timer) in
            animationFinishedBlock()
            timer.invalidate()
        }
        
        RunLoop.current.add(timer, forMode: .commonModes)
        
        let newView = newItem.view
        let oldView = oldItem!.view
        
        if newView === oldView {
            if newView === searchView.view{
                searchView.popToRootViewController(animated: true)
            } else if newView === settingsView.view{
                settingsView.popToRootViewController(animated: true)
            } else if newView === libraryView.view{
                libraryView.page()
            }
            return
        }
        

        let viewShouldEnterFromLeft = newItem.tag < oldItem!.tag
        
        
        holderView.bringSubview(toFront: shadeView)
        holderView.bringSubview(toFront: oldView)
        holderView.bringSubview(toFront: newView)
        newView.alpha = 0
        newView.transform = CGAffineTransform(translationX: (viewShouldEnterFromLeft) ? -170 : 170, y: 0)
        let oldViewEndingXPosition: CGFloat = (viewShouldEnterFromLeft) ? 170 : -170
        
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            oldView.alpha = 0
            oldView.transform = CGAffineTransform(translationX: oldViewEndingXPosition, y: 0)
            
            newView.transform = CGAffineTransform.identity
            newView.alpha = 1
            
            
        }, completion: { (success) in
            
            oldView.alpha = 1
            oldView.transform = CGAffineTransform.identity
            self.holderView.bringSubview(toFront: self.shadeView)
            self.holderView.bringSubview(toFront: newView)
            animationFinishedBlock()
            
        })
        
        
        
    }
    

    
    
    

    
    
    
    
   
    
    
    func showtabBarItem(tag: Int){
        tabBar.selectItem(with: tag)
        
        
    }

 
    
}

