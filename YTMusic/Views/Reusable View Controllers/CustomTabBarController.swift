//
//  CustomTabBarController.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/13/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class CustomTabBarController: PortraitViewController, CustomTabBarDelegate{
   
    private var _items = [CustomTabBarItem]()

    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(viewHolder)
        viewHolder.pinAllSidesTo(view)
    }
    
    private var itemsHaveAlreadyBeenSet = false
    
    func setItems(items: [CustomTabBarItem]){
        if itemsHaveAlreadyBeenSet{
            fatalError("You tried to set the items on a Custom TabBar Controller a second time. This is not allowed.")
        }
        itemsHaveAlreadyBeenSet = true
        self._items = items
        view.addSubview(tabBar)

        tabBar.setItems(items: self._items)
        
        for item in items.reversed(){
            addChildViewController(item.viewController)
            viewHolder.bringSubview(toFront: shadeView)
            viewHolder.addSubview(item.view)
            item.view.pinAllSidesTo(viewHolder)
        }
        
    }
    
    
    
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        tabBar.tintColor = color
    }

    
    
    lazy var tabBar: CustomTabBar = {
        let x = CustomTabBar(delegate: self)
        x.tintColor = THEME_COLOR(asker: self)
        return x
        
    }()
    
    
    lazy var viewHolder: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        x.addSubview(shadeView)
        x.layer.masksToBounds = true
        shadeView.pinAllSidesTo(x)
        return x
    }()
    
    private lazy var shadeView: UIView = {
        let x = UIView()
        x.backgroundColor = .white
        return x
    }()
    
    
    
    func customTabBar(tabBar: CustomTabBar, itemWasSelected newItem: CustomTabBarItem, oldItem: CustomTabBarItem?, animationFinishedBlock: @escaping () -> Void) {
        
        
        
        let timer = Timer(timeInterval: 0.3, repeats: false) { (timer) in
            animationFinishedBlock()
            timer.invalidate()
        }
        
        RunLoop.current.add(timer, forMode: .commonModes)
        
        let newView = newItem.view
        let oldView = oldItem!.view
        
        if newView === oldView{
            self.itemTappedSameAsCurrentlyDisplayedItem(item: newItem)
            return
        }
        
        let viewShouldEnterFromLeft = newItem.tag < oldItem!.tag
        
        
        viewHolder.bringSubview(toFront: shadeView)
        viewHolder.bringSubview(toFront: oldView)
        viewHolder.bringSubview(toFront: newView)
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
            self.viewHolder.bringSubview(toFront: self.shadeView)
            self.viewHolder.bringSubview(toFront: newView)
            animationFinishedBlock()
            
        })
        
        
        
    }
    
    func itemTappedSameAsCurrentlyDisplayedItem(item: CustomTabBarItem){
        
    }
    
    
    
    func showtabBarItem(tag: Int){
        tabBar.selectItem(with: tag)
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}

