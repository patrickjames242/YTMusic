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


class Screen: PortraitViewController, UITabBarDelegate, CustomTabBarDelegate{

    
    
    
    //MARK: - CHILD VIEW CONTROLLERS
    
    var songView: SongListView_NavCon {
        return AppManager.shared.songListNavCon
    }


    var settingsView: MusicSettings_NavCon {
        return AppManager.shared.musicSettingsNavCon
    }
    
    var downloadsView: DownloadsView_NavCon {
        return AppManager.shared.downloadsView_NavCon
    }
    
    var searchView: SearchTableView_NavCon {
        return AppManager.shared.searchNavCon
    }
    
    var recentlyAddedView: RecentlyAdded_NavCon {
        return AppManager.shared.recentlyAddedView_NavCon
    }
    
    
    
    
    
    
    
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(recentlyAddedView)
        addChildViewController(songView)
        addChildViewController(searchView)
        addChildViewController(downloadsView)
        addChildViewController(settingsView)
        
        view.addSubview(holderView)
        view.addSubview(tabBar)
        
        holderView.pinAllSidesTo(view)
        
        
//        tabBar.pin(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
//
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = THEME_COLOR
//        view.addSubview(backgroundView)
//
//        backgroundView.pin(left: tabBar.leftAnchor, right: tabBar.rightAnchor, top: tabBar.topAnchor, size: CGSize.height(49 + Variations.bottomAppInset))
//
        view.backgroundColor = .black
        
        delegate_Stuff_To_Be_Done_In_ViewDidLoad()
        
        
        
        
    }
    
    
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        if viewJustRotated{
            (recentlyAddedView.viewControllers[0] as! RecentlyAddedView).collectionView?.reloadData()
        }
        AppManager.appInsets = view.safeAreaInsets

        view.addSubview(AppManager.shared.musicView)
        view.bringSubview(toFront: tabBar)
    }
    
    
    
    private var viewJustRotated = false

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        var newSize = size
        newSize.width = newSize.width * 2
        songsHolderView.contentSize = newSize
        
        let position = songsHolderView.contentOffset.x
        if position > 0 {
            songsHolderView.setContentOffset(CGPoint(x: size.width, y: 0), animated: true)
        }
        
        viewJustRotated = true
        
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
        x.addSubview(songsHolderView)

        shadeView.pinAllSidesTo(x)
        songsHolderView.pinAllSidesTo(x)
        searchView.view.pinAllSidesTo(x)
        downloadsView.view.pinAllSidesTo(x)
        settingsView.view.pinAllSidesTo(x)
        
        
        return x
        
    }()
    

    
    lazy var songsHolderView: UIScrollView = {
        let x = UIScrollView()
        let contentWidth = view.frame.width * 2
        x.contentSize = CGSize(width: contentWidth, height: view.frame.height)
        
        x.translatesAutoresizingMaskIntoConstraints = false
        x.isPagingEnabled = true
        x.showsHorizontalScrollIndicator = false
        x.showsVerticalScrollIndicator = false
        
        
        
        
        let recDel = recentlyAddedView.view!
        let songs = songView.view!
        
        
        x.addSubview(songs)
        x.addSubview(recDel)

        
        recDel.pin(left: x.leftAnchor, top: x.topAnchor, width: x.widthAnchor, height: x.heightAnchor)
        
        songs.pin(left: recDel.rightAnchor, top: recDel.topAnchor, bottom: recDel.bottomAnchor, width: recDel.widthAnchor)
        
        
        
        
        return x
        
    }()
    
    override func interfaceColorDidChange(to color: UIColor) {
        tabBar.tintColor = color
    }
    

    
    
    
    let songItem = CustomTabBarItem(tag: 1, image: #imageLiteral(resourceName: "note"))
    let searchItem = CustomTabBarItem(tag: 2, image: #imageLiteral(resourceName: "search"))
    let downloadsItem = CustomTabBarItem(tag: 3, image: #imageLiteral(resourceName: "downloadIcon"), imagePadding: UIEdgeInsets(top: 6))
    
    let settingsItem = CustomTabBarItem(tag: 4, image: #imageLiteral(resourceName: "settingsIcon") )

    
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    

    
    


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SWITCHING BETWEEN TAB BAR ITEMS
    
    
    
    
    
    
    func customTabBar(tabBar: CustomTabBar, userDidTap item: CustomTabBarItem) {
        tabBar.setTouchesEnabled(to: false)
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            self.tabBar.setTouchesEnabled(to: true)
            timer.invalidate()
        }
        
        let tag = item.tag
        enum Side{ case left, right }
        
        func animateNewViewEntrance(oldView: UIView, newView: UIView, from side: Side){
            
            
            if oldView === newView {
                if newView === searchView.view{
                    AppManager.shared.searchNavCon.popToRootViewController(animated: true)
                } else if newView === settingsView.view{
                    AppManager.shared.musicSettingsNavCon.popToRootViewController(animated: true)
                }
                
                
                return
            }
            
            holderView.bringSubview(toFront: shadeView)
            holderView.bringSubview(toFront: oldView)
            holderView.bringSubview(toFront: newView)
            newView.alpha = 0
            newView.transform = CGAffineTransform(translationX: (side == .left) ? -170 : 170, y: 0)
            let oldViewEndingXPosition: CGFloat = (side == .left) ? 170 : -170
            
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                oldView.alpha = 0
                oldView.transform = CGAffineTransform(translationX: oldViewEndingXPosition, y: 0)
                
                newView.transform = CGAffineTransform.identity
                newView.alpha = 1
                
                
            }, completion: { (success) in
                tabBar.isUserInteractionEnabled = true
                self.currentFrontViewTuple = (newView, tag)
                oldView.alpha = 1
                oldView.transform = CGAffineTransform.identity
                self.holderView.bringSubview(toFront: self.shadeView)
                self.holderView.bringSubview(toFront: newView)
            })
        }
        
        
        
        let viewDict: [Int: UIView] = [
            1: songsHolderView,
            2: searchView.view,
            3: downloadsView.view,
            4: settingsView.view
        ]
        
        
        
        let side: Side = (tag > currentFrontViewTuple.tag) ? .right : .left
        
        animateNewViewEntrance(oldView: currentFrontViewTuple.view, newView: viewDict[tag]!, from: side)
        
        
    }
    
    
    
    
   
    
    private lazy var currentFrontViewTuple: (view: UIView, tag: Int) = (view: self.songsHolderView, tag: 0)
    
    
    func showtabBarItem(tag: Int){
        tabBar.selectItem(with: tag)
        self.customTabBar(tabBar: tabBar, userDidTap: tabBar.currentlySelectedItem!)
        
        
    }

    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
}














