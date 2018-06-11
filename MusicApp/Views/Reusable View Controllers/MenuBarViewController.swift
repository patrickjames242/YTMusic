//
//  SongQueueView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit





struct MenuBarControllerItem{
    var viewController: UIViewController
    var name: String
}



class MenuBarViewController: PortraitViewController, UIScrollViewDelegate, MenuBarDelegate{
 
    init(items: [MenuBarControllerItem], titleText: String, showsDismissButton: Bool){
        self.showsDismissButton = showsDismissButton
        self.titleText = titleText
        self.menuBarItems = items
        super.init(nibName: nil, bundle: nil)
    }
    

    
    
    
    private let showsDismissButton: Bool
    private let titleText: String
    private let menuBarItems: [MenuBarControllerItem]
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
        
        
    }
    
    
    
    private let navBarHeight: CGFloat = 80
    
    
    
    
    private lazy var blurView: UIVisualEffectView = {
       let x = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.prominent))
       return x
    }()
    
    /// Selects the view of the corresponding index. Index starts from 0.
    func setSelectedView(to index: Int, animated: Bool){
        view.layoutIfNeeded()
        let xOffset = CGFloat(Double(index) / 2) * scrollView.contentSize.width
        
        var rect = scrollView.bounds
        rect.origin.x = xOffset
        scrollViewIsAutomaticallyScrolling = true
        scrollView.scrollRectToVisible(rect, animated: animated)
        scrollViewIsAutomaticallyScrolling = false
        menu.selectItem(index: index, animated: animated)
        
        
    }
    
    
    private lazy var scrollView: UIScrollView = {
       let x = UIScrollView()

        let viewControllers = self.menuBarItems.map {$0.viewController}
        self.view.layoutIfNeeded()
        x.contentSize = CGSize(width: view.frame.width * CGFloat(viewControllers.count), height: view.frame.height)
        x.isPagingEnabled = true
        x.delegate = self
        x.showsHorizontalScrollIndicator = false
        x.showsVerticalScrollIndicator = false
        
        var y: CGFloat = 0
        viewControllers.forEach { (controller) in
            addChildViewController(controller)
            controller.view.frame = x.bounds
            controller.view.frame.origin.x = (y / CGFloat(viewControllers.count)) * x.contentSize.width
            x.addSubview(controller.view)

            y += 1
        }
        return x
    }()
  
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollViewIsAutomaticallyScrolling { return }
        
        let index = Int((scrollView.contentOffset.x / scrollView.contentSize.width) * CGFloat(menuBarItems.count))
        
        menu.selectItem(index: index, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewIsAutomaticallyScrolling = false
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollViewIsAutomaticallyScrolling{return}
        menu.userDidScrollBy(point: Double(scrollView.contentOffset.x / scrollView.contentSize.width))
    }
    
 
    func userDidSelectItemIndex(of index: Int) {
        view.layoutIfNeeded()
        let xOffset = CGFloat(Double(index) / 2) * scrollView.contentSize.width
        
        var rect = scrollView.bounds
        rect.origin.x = xOffset
        scrollViewIsAutomaticallyScrolling = true
        scrollView.scrollRectToVisible(rect, animated: true)
        
    }
    
    private var scrollViewIsAutomaticallyScrolling = false
    
    override func interfaceColorDidChange(to color: UIColor) {
        navBar.tintColor = color
        button.setTitleColor(color, for: .normal)
        setButtonAttributesUsing(color: color)
        
    }
    
    private lazy var navBar: UINavigationBar = {
        let x = UINavigationBar()
        x.isTranslucent = true
      
        x.tintColor = THEME_COLOR(asker: self)
        
        
        x.setBackgroundImage(UIImage(), for: .default)
        x.shadowImage = UIImage()
 
        let item = UINavigationItem(title: titleText)
       
        if showsDismissButton{
            item.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(respondToDismissButtonPressed))
        }
        x.items = [item]
   
        return x
        
        
    }()
    
    @objc private func respondToDismissButtonPressed(){
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    private lazy var menu: MenuBar = {
        
        let names = menuBarItems.map{ $0.name }
        
        let menu = MenuBar(items: names)
        menu.delegate = self
        return menu
        
    }()
    
    
    
    
    
    private lazy var topBar: UIView = {
        let x = UIView()
        
        x.backgroundColor = .clear
        
        

        let bottomLine = UIView()
        bottomLine.backgroundColor = .lightGray
        
        x.addSubview(navBar)
        x.addSubview(bottomLine)

        x.addSubview(menu)
        

        navBar.pin(left: x.leftAnchor, right: x.rightAnchor, top: x.topAnchor, bottom: x.bottomAnchor)
        
        menu.pin(left: x.leftAnchor, right: x.rightAnchor, bottom: x.bottomAnchor, size: CGSize(height: 50))
        bottomLine.pin(left: x.leftAnchor, right: x.rightAnchor, bottom: x.bottomAnchor, size: CGSize(height: 0.3))
        
        
        return x
        
        
    }()
    

    
    
    private lazy var bottomBlurView: UIVisualEffectView = {
        let x = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        
        return x
        
    }()
    private let button = UIButton.init(type: .system)

    private lazy var bottomBar: UIView = {
        
       let x = UIView()
        
        let topLine = UIView()
        topLine.backgroundColor = .lightGray
        
        
        
        setButtonAttributesUsing(color: THEME_COLOR(asker: self))
        
        
        button.addTarget(self, action: #selector(respondToDismissButtonPressed), for: .touchUpInside)
        
        x.addSubview(button)
        x.addSubview(topLine)
        button.pin(top: x.topAnchor, bottom: x.bottomAnchor, centerX: x.centerXAnchor, size: CGSize(width: 60))
        topLine.pin(left: x.leftAnchor, right: x.rightAnchor, top: x.topAnchor, size: CGSize(height: 0.3))
        
        
        return x
        
    }()
    
    
    private func setButtonAttributesUsing(color: UIColor){
        button.setAttributedTitle(NSAttributedString.init(string: "Done", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: color]), for: .normal)
        
        
    }
    

    private let bottomBarHeight: CGFloat = 40
    
    
    private func setUpViews(){
        view.addSubview(scrollView)

        view.addSubview(bottomBlurView)
        view.addSubview(bottomBar)

        view.addSubview(blurView)
        view.addSubview(topBar)
        
        blurView.pin(left: view.leftAnchor, right: view.rightAnchor, top: view.topAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, insets: UIEdgeInsets(bottom: -navBarHeight))
        
        topBar.pin(left: view.leftAnchor, right: view.rightAnchor, top: view.safeAreaLayoutGuide.topAnchor, bottom: blurView.bottomAnchor)
        
        bottomBlurView.pin(left: view.leftAnchor, right: view.rightAnchor, top: view.safeAreaLayoutGuide.bottomAnchor, bottom: view.bottomAnchor, insets: UIEdgeInsets(top: -bottomBarHeight))
        
        bottomBar.pin(left: view.leftAnchor, right: view.rightAnchor, top: bottomBlurView.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        
        scrollView.pinAllSidesTo(view)
        
        
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Why you using this!")
    }
}




