//
//  MiddleTextTableViewCell.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/13/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class MiddleTextCell: UITableViewCell{
    
    init(text: String){
        
        super.init(style: .default, reuseIdentifier: "alskdfja;sdkj")
        
        middleTextLabel.text = text
        addSubview(middleTextLabel)
        middleTextLabel.pin(centerX: centerXAnchor, centerY: centerYAnchor)
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        middleTextLabel.textColor = color
    }
    
    private lazy var middleTextLabel: UILabel = {
        let x = UILabel()
        
        //        x.textColor = UIColor(red: 0, green: 122, blue: 255)
        x.textColor = THEME_COLOR(asker: self)
        return x
        
        
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}
