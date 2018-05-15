//
//  ColorManager.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/12/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



protocol Colorful: NSObjectProtocol {
    
    func interfaceColorDidChange(to color: UIColor)
    
}



extension NSObject: Colorful {
    
    @objc func interfaceColorDidChange(to color: UIColor) {
        
    }

    func THEME_COLOR(asker: Colorful) -> UIColor{
        ColorManager.addColorObserver(sender: asker)
        return UserPreferences.currentAppThemeColor
    }
    
    
    
    
    
}

var CURRENT_THEME_COLOR: UIColor{
    return UserPreferences.currentAppThemeColor
}



fileprivate struct WeakColorful {

    weak var value: Colorful?
    
    init(_ value: Colorful) {
        self.value = value
    }
    
    
    
}






class ColorManager{
    
    fileprivate static func addColorObserver(sender: Colorful){
        
        for observer in colorObservers where observer.value === sender{
            return
        }
        
        colorObservers.append(WeakColorful(sender))
        
        
        
    }
    
    
    private static var colorObservers = [WeakColorful]()
    
    
    static func changeInterfaceColor(to color: UIColor){
        UserPreferences.currentAppThemeColor = color
        UIView.animate(withDuration: 0.5) {
            for observer in colorObservers {
                observer.value?.interfaceColorDidChange(to: color)
            }
        }
     
        
        
    }
    
    
    
    
    
    
}

















