//
//  Variations.swift
//  MusicApp
//
//  Created by Patrick Hanna on 4/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




fileprivate let iPhoneXSMaxSize = CGSize(width: 414, height: 896)
fileprivate let iPhoneXSize = CGSize(width: 375, height: 812)
fileprivate let iPhonePlusSize = CGSize(width: 414, height: 736)
fileprivate let iPhoneSize = CGSize(width: 375, height: 667)
fileprivate let iPhoneSESize = CGSize(width: 320, height: 568)
fileprivate let iPhone4Size = CGSize(width: 320, height: 480)



fileprivate enum Orientation { case landscape, portrait}

fileprivate enum Device {
    
    static let current = Device.getFrom(size: UIScreen.main.fixedCoordinateSpace.bounds.size);

    case  iPhonePlus, iPhoneXSMax, iPhoneX, iPhone, iPhoneSE, iPhone4
    
    private static func getFrom(size: CGSize) -> Device{
        switch size{
            
        case iPhonePlusSize: return .iPhonePlus
        case iPhoneXSize: return .iPhoneX
        case iPhoneSize: return .iPhone
        case iPhoneXSMaxSize: return .iPhoneXSMax
        case iPhoneSESize: return .iPhoneSE
            
        default: fatalError("This device is not supported!!!! The initializer for the Device enum fell into the default case")
        }
    }
}














struct Variations {
    
    static var bottomAppInset: CGFloat{
        switch Device.current{
        case .iPhoneX: return 34
        default: return 0
        }
        
    }
    
    static var topAppInset: CGFloat{
        switch Device.current{
        case .iPhoneX: return 44
        default: return 20
        }
    }
    
    
   
    
    
    
    
    
    
    
    
    struct Screen{
        

        
        static var tabBarItemsBottomInset: CGFloat{
            switch Device.current{
            default: return -10
            }
            
        }
        
        
    }
    
    
    
    
    struct MusicView{
        
        static var distance_from_ScrubbingSliderBottom_to_InfoLabelsTop: CGFloat{
            switch Device.current{
            case .iPhoneX: return 50
            
            default: return 15
            }
        
        }
        
        static var albumImageDifferenceFactor: CGFloat{
            
            switch Device.current{
            case .iPhoneSE, .iPhone4: return 50
            
            case .iPhone: return 40
            case .iPhonePlus: return 20
            default: return 0
            }
            
        }
        
    }
    
    
    
    struct RecentlyAddedView{
        
        static var numberOfItemColumns: CGFloat {
            switch Device.current{
      

            default: return 2
                
                
                
            }
        }
        
        
    }
    
    
    
    
    
    struct DownloadsView {
        
        
        static var cellHeight: CGFloat {
            
            switch Device.current{
            case .iPhoneSE, .iPhone4: return 70
                
            
            default: return 90
                
            }
            
            
            
            
        }
        
        static var topTextLabelNumberOfLines: Int{
            
            switch Device.current{
            case .iPhoneSE, .iPhone4: return 1
            default: return 2
            }
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    struct SearchResultsView{
        
        static var cellHeight: CGFloat{
            switch Device.current{
                
            case .iPhoneSE, .iPhone4: return 90
            
            default: return 110
            }
            
            
        }
        
        static var topTextLabel_NumberOfLines: Int{
            
            switch Device.current{
            case .iPhoneSE, .iPhone4: return 2
            default: return 3
            }
            
            
        }
        
        
    }
    
    
    
    struct Settings{
        
        static var scrollViewContentViewHeightDifferenceFactor: CGFloat{
            
            switch Device.current{
                
            case .iPhoneSE: return 150
            default: return 0
                
            }
            
            
        }
        
        static var meImageTopAndBottomSpacing: CGFloat{
            
            switch Device.current{
                
            case .iPhoneX: return 40
            
            case .iPhonePlus: return 30
            
            default: return 15
            }
            
        }
        
        static var showsScrollIndicator: Bool{
            switch Device.current{
                
            case .iPhoneSE: return true
            default: return false
                
            }
            
        }
        
        
    }
}













