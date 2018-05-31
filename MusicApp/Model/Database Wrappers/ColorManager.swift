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



extension UIView: Colorful {
    @objc func interfaceColorDidChange(to color: UIColor) { }
}

extension UIViewController: Colorful{
    @objc func interfaceColorDidChange(to color: UIColor) { }
}



func THEME_COLOR(asker: Colorful) -> UIColor{
    ColorManager.addColorObserver(sender: asker)
    return DBColor.currentAppThemeColor
}

var CURRENT_THEME_COLOR: UIColor{
    return DBColor.currentAppThemeColor
}



fileprivate class WeakColorful {

    weak var value: Colorful?
    
    init(_ value: Colorful) {
        self.value = value
    }
}


fileprivate extension Array where Element: WeakColorful{
    
    mutating func purgeNils(){
        
        self = filter{ $0.value != nil }
        
    }
    
}











fileprivate class ColorManager {
    
    static func addColorObserver(sender: Colorful){
        
        for observer in colorObservers where observer.value === sender{
            return
        }
        
        colorObservers.append(WeakColorful(sender))
    }
    
    
    private static var _colorObservers = [WeakColorful]()
      
    private static var colorObservers: [WeakColorful]{
        get{
            _colorObservers.purgeNils()
            return _colorObservers
        } set {
            _colorObservers = newValue
        }
    }
    
    
    
    static func changeInterfaceColor(to color: UIColor){
        UIView.animate(withDuration: 0.5) {
            colorObservers.forEach { $0.value?.interfaceColorDidChange(to: color) }
        }
    }
}









class DBColor {
    
    private static let appThemeColorKey = "APP THEME COLOR KEY"
    
    
    private static var DEFAULT_APP_THEME_COLOR = UIColor.red
    
    
    static var currentAppThemeColor: UIColor{
        
        
        get {
            
            if let color = UserDefaults.standard.color(forKey: appThemeColorKey){
                return color
            }
            let defaultColor = DEFAULT_APP_THEME_COLOR
            UserDefaults.standard.set(defaultColor, forKey: appThemeColorKey)
            return defaultColor
            
        } set {
            
            UserDefaults.standard.set(newValue, forKey: appThemeColorKey)
            ColorManager.changeInterfaceColor(to: newValue)
            
        }
    }  
}

















