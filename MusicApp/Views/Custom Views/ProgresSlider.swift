//
//  ProgresSlider.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/26/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



class ProgressIndicator: UIView {
    
    
    convenience init(){
        self.init(frame: CGRect.zero)
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        setUpViews()
    }
    
  
    
    
    
    private var progressBar: UIView = {
        let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = .red
        return x
    }()
    
    
    
    
    
    
    var progressConstraint: NSLayoutConstraint!
    
    
    
    private func setUpViews(){
        addSubview(progressBar)
        
        progressBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressConstraint = progressBar.rightAnchor.constraint(equalTo: leftAnchor)
        progressConstraint.isActive = true
        
        
    }
    
    
    func changeProgressTo(_ decimal: Double){
        layoutIfNeeded()
        
            self.progressConstraint.constant = self.frame.width * CGFloat(decimal)
            
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}























