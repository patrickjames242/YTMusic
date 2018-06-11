//
//  CustomViewControllers.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/8/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class ViewDidLayoutSubviewsViewController: UIViewController{
    
    private var subviewsWereAlreadyLaidOut = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.subviewsWereAlreadyLaidOut == false{
            self.firstTimeTheViewLaysOutItsSubviews()
            self.subviewsWereAlreadyLaidOut = true
        }
        
    }
    
    func firstTimeTheViewLaysOutItsSubviews(){
        
    }
    
    
}


class PortraitViewController: ViewDidLayoutSubviewsViewController{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
}

class PortraitNavigationController: UINavigationController{
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
}


protocol SafeAreaObservable { }


extension UIViewController{
    @objc fileprivate func respondToSafeAreaNotification(notification: Notification){
        
        let inset = notification.userInfo![MNotifications.AppBottomSafeAreaInsetKey]! as! CGFloat
        self.additionalSafeAreaInsets.bottom = inset
        
    }
}

extension SafeAreaObservable where Self: UIViewController{

    fileprivate func setUp(){
        
        additionalSafeAreaInsets.bottom = AppManager.currentAppBottomInset
        
        NotificationCenter.default.addObserver(self, selector: #selector(respondToSafeAreaNotification(notification:)), name: MNotifications.AppBottomSafeAreaInsetsDidChange, object: nil)
        
        
    }
    

    
}



class SafeAreaObservantTableViewController: UITableViewController, SafeAreaObservable{
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}


class SafeAreaObservantCollectionViewController: UICollectionViewController, SafeAreaObservable{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
    }
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}


class SafeAreaObservantViewController: UIViewController, SafeAreaObservable{
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
}


