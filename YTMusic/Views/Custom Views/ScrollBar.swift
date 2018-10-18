//
//  ScrollBar.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class ScrollBar: UIView{
    private let numberOfItems: Int
    
    init(numberOfItems: Int) {
        self.numberOfItems = numberOfItems
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        
        setUpViews()
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        scrollLine.backgroundColor = color
    }
    
    private lazy var scrollLine: UIView = {
        let x = UIView()
        x.backgroundColor = THEME_COLOR(asker: self)
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    private func setUpViews(){
        addSubview(scrollLine)
        scrollLine.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / CGFloat(numberOfItems)).isActive = true
        
        scrollLine.pin(top: topAnchor, bottom: bottomAnchor)
        
        scrollLineLeftConstraint = scrollLine.leftAnchor.constraint(equalTo: leftAnchor)
        scrollLineLeftConstraint.isActive = true
        
    }
    
    private var scrollLineLeftConstraint: NSLayoutConstraint!
    /// NOTE: indexes start at zero
    func pageTo(index: Int, animated: Bool){
        if index > (numberOfItems - 1){return}
        
        layoutIfNeeded()
        let width = frame.width
        
        let action: () -> Void = {
            self.superview!.layoutIfNeeded()
            
            let scrollXPosition = CGFloat(index) * (width / CGFloat(self.numberOfItems))
            self.scrollLineLeftConstraint.constant = scrollXPosition
            
            self.layoutIfNeeded()
            
            
        }
        if animated{
            UIView.animate(withDuration: 0.3, animations: action)
        } else {
            
            action()
        }
        
    }
    
    func scrollTo(point: Double){
        layoutIfNeeded()
        scrollLineLeftConstraint.constant = CGFloat(point) * frame.size.width
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("fool!")
    }
}
