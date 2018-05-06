//
//  GlobalColorManager.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/5/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



protocol ColorObserver: class, NSObjectProtocol {
    
    func appThemeColorsDidChange(to color: UIColor)
    
}





extension NSObject: ColorObserver{
    
    func appThemeColorsDidChange(to color: UIColor) {
        print("\(self) has not implemented the Color Observer Method")
    }
}


//
//func THEME_COLOR(asker: ColorObserver) -> UIColor{
//    ColorManager.addObserver(observer: asker)
//    return ColorManager.currentAppThemeColor
//
//}


var THEME_COLOR: UIColor{
    
    return UIColor.red
}

fileprivate class ColorManager{
    
    
    static var currentAppThemeColor = UIColor.red
    
    private static var observers = [ColorObserver]()
    
    static func addObserver(observer: ColorObserver){
        for observer1 in observers where observer1 === observer { return }
        
        observers.append(observer)
    }
    
    
    static func changeAppColors(to color: UIColor){
        
        for observer in observers{
            observer.appThemeColorsDidChange(to: color)
        }
        
    }
}



