//
//  Variations.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


fileprivate let iPhoneXSize = CGSize(width: 375, height: 812)
fileprivate let iPhoneSESize = CGSize(width: 320, height: 568)
fileprivate let iPhoneSize = CGSize(width: 375, height: 667)
fileprivate let iPhonePlusSize = CGSize(width: 414, height: 736)
fileprivate let iPhone4Size = CGSize(width: 320, height: 480)

fileprivate let iPad9_Portrait = CGSize(width: 768, height: 1024)
fileprivate let iPad10_Portrait = CGSize(width: 834, height: 1112)
fileprivate let iPad12_Portrait = CGSize(width: 1024, height: 1366)

fileprivate let iPad9_Landscape = CGSize(width: 1024, height: 768)
fileprivate let iPad10_Landscape = CGSize(width: 1112, height: 834)
fileprivate let iPad12_Landscape = CGSize(width: 1366, height: 1024)

fileprivate enum Orientation { case landscape, portrait}

fileprivate enum Device {

    case  iPhonePlus, iPhoneX, iPhone, iPhoneSE, iPad(Orientation), iPhone4
    

    
    
    static func getFrom(size: CGSize) -> Device{
        switch size{
            
        case iPhonePlusSize: return .iPhonePlus
        case iPhoneXSize: return .iPhoneX
        case iPhoneSize: return .iPhone
        case iPhoneSESize: return .iPhoneSE
            
//        case iPad9_Portrait, iPad10_Portrait, iPad12_Portrait:
//            return .iPad(.portrait)
//        case iPad9_Landscape, iPad10_Landscape, iPad12_Landscape:
//            return .iPad(.landscape)
//
        default: fatalError("This device is not supported!!!! The initializer for the Device enum fell into the default case")
        }
    }
}














struct Variations {
    
    static var bottomAppInset: CGFloat{
        switch currentDevice{
        case .iPhoneX: return 34
        default: return 0
        }
        
    }
    
    static var topAppInset: CGFloat{
        switch currentDevice{
        case .iPhoneX: return 44
        default: return 20
        }
    }
    
    
    private static var currentDevice: Device{
        
     return Device.getFrom(size: UIScreen.main.bounds.size)
    }
    
    static func doOnIPad(_ action: () -> Void){
        switch currentDevice{
        case .iPad:
            action()
        default: break
        }
        
    }
    
    static func doOnIPhone(_ action: () -> Void){
        switch currentDevice{
        case .iPhone, .iPhoneX, .iPhoneSE, .iPhonePlus, .iPhone4:
            action()
        default: break
        }
        
    }
    
    
    
    
    struct Screen{
        

        
        static var tabBarItemsBottomInset: CGFloat{
            switch currentDevice{
            case .iPad: return 0
            default: return -10
            }
            
        }
        
        
    }
    
    
    
    
    struct MusicView{
        
        static var distance_from_ScrubbingSliderBottom_to_InfoLabelsTop: CGFloat{
            switch currentDevice{
            case .iPhoneX: return 50
            
            default: return 15
            }
        
        }
        
        static var albumImageDifferenceFactor: CGFloat{
            
            switch currentDevice{
            case .iPhoneSE, .iPhone4: return 50
            
            case .iPhone: return 40
            case .iPhonePlus: return 20
            case .iPad: return 150
            default: return 0
            }
            
        }
        
    }
    
    
    
    struct RecentlyAddedView{
        
        static var numberOfItemColumns: CGFloat {
            switch currentDevice{
            case .iPad(let orientation):
                switch orientation{
                case .landscape:
                    return 4
                case .portrait:
                    return 3
                }

            default: return 2
                
                
                
            }
        }
        
        
    }
    
    
    
    
    
    struct DownloadsView {
        
        
        static var cellHeight: CGFloat {
            
            switch currentDevice{
            case .iPhoneSE, .iPhone4: return 70
                
            case .iPad: return 130
            
            default: return 90
                
            }
            
            
            
            
        }
        
        static var topTextLabelNumberOfLines: Int{
            
            switch currentDevice{
            case .iPhoneSE, .iPhone4: return 1
            default: return 2
            }
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    struct SearchResultsView{
        
        static var cellHeight: CGFloat{
            switch currentDevice{
                
            case .iPhoneSE, .iPhone4: return 90
            case .iPad: return 160
            default: return 110
            }
            
            
        }
        
        static var topTextLabel_NumberOfLines: Int{
            
            switch currentDevice{
            case .iPhoneSE, .iPhone4: return 2
            default: return 3
            }
            
            
        }
        
        
    }
    
    
    
    struct Settings{
        
        static var scrollViewContentViewHeightDifferenceFactor: CGFloat{
            
            switch currentDevice{
                
            case .iPhoneSE: return 150
            default: return 0
                
            }
            
            
        }
        
        static var meImageTopAndBottomSpacing: CGFloat{
            
            switch currentDevice{
                
            case .iPhoneX: return 40
            
            case .iPhonePlus: return 30
            
            default: return 15
            }
            
        }
        
        static var showsScrollIndicator: Bool{
            switch currentDevice{
                
            case .iPhoneSE: return true
            default: return false
                
            }
            
        }
        
        
    }
}













