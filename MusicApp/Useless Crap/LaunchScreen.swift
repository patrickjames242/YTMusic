//
//  LaunchScreen.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/25/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class LaunchScreen: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    private lazy var loadingIndicator: NVActivityIndicatorView = {
        let size: CGFloat = 70
        let frame = CGRect(x: (view.center.x / 2) - (size / 2),
                                y: (view.center.y / 2) - (size / 2),
                                width: size,
                                height: size)
        
       let x = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineScale, color: .white, padding: nil)
        return x
    }()
    
}





