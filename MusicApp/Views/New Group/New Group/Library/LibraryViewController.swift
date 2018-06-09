//
//  LibraryViewController.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/31/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class LibraryViewController: UIViewController {
    
    
    var songView: UIViewController{
        return AppManager.shared.songListNavCon
    }
    var recentlyAddedView: UIViewController {
        return AppManager.shared.recentlyAddedView_NavCon
    }
    
    func page(){
        
        let desiredOffset: CGPoint
        
        if scrollView.contentOffset.x > 0{
            desiredOffset = CGPoint(x: 0, y: 0)
        } else {
            desiredOffset = CGPoint(x: scrollView.contentSize.width / 2, y: 0)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.scrollView.contentOffset = desiredOffset
        }
        
    }
    

    
    init(){
        
        super.init(nibName: nil, bundle: nil)
        let scrollView = UIScrollView()
        view = scrollView
        
        addChildViewController(songView)
        addChildViewController(recentlyAddedView)
        
        
        
        setUpView()
        setUpSubviews()
        
    }
    
    var scrollView: UIScrollView {
        return view as! UIScrollView
    }
    
    
    private func setUpView(){
        
        scrollView.isPagingEnabled = true
        
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
 
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    
    
    
    private func setUpSubviews(){
        view.addSubview(songView.view)
        view.addSubview(recentlyAddedView.view)
        
        
        
        recentlyAddedView.view.pin(left: scrollView.contentLayoutGuide.leftAnchor, right: scrollView.contentLayoutGuide.rightAnchor, top: scrollView.contentLayoutGuide.topAnchor, bottom: scrollView.contentLayoutGuide.bottomAnchor)
        songView.view.pin(left: recentlyAddedView.view.rightAnchor, top: recentlyAddedView.view.topAnchor, bottom: recentlyAddedView.view.bottomAnchor, width: recentlyAddedView.view.widthAnchor)
        
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}






