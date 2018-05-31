//
//  MediaButton.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/16/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




@objc public enum MediaButtonType: Int { case play_pause, rewind, fastForward, play, pause}

public class MediaPlayingButton: UIButton{
    
        

    
    init(){
        fatalError("You tried to initialize a MediaPlayingButton instance with the 'init()' method. Use the other inits provided")
    }

    
    
    public convenience init(buttonType: MediaButtonType, imageSize: CGFloat, circleSize: CGFloat){
        self.init(frame: CGRect.zero, buttonType: buttonType, imageSize: imageSize, circleSize: circleSize)
    }
    
    
    private var type: MediaButtonType
    
    
    public init(frame: CGRect, buttonType: MediaButtonType, imageSize: CGFloat, circleSize: CGFloat) {
        self.type = buttonType
        super.init(frame: frame)
        self.setButtonImageWithImageType(buttonType)
        setUpViews(imageSize: imageSize, circleSize: circleSize)
        self.addTarget(self, action: #selector(animateCircle), for: .touchUpInside)
        
    }
    
    var action: (() -> Void)?
   
    var automaticallyAnimatesImageWhenTapped = true
    
    @objc private func animateCircle(){
        
        

        UIView.animate(withDuration: 0.05, animations: {
            self.circleView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }) { (success) in
            UIView.animate(withDuration: 0.65, animations: {
                self.circleView.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
            })
        }
        
        if automaticallyAnimatesImageWhenTapped{
            changeButtonImage(withEndingType: self.type)
        }
        
        if let action = action{
            action()
        }
        
   
    }



    
    

    private lazy var circleView: UIView = {
        let x = UIView()
        x.layer.masksToBounds = true
        x.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
        x.isUserInteractionEnabled = false
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    private lazy var controlImageView: UIImageView = {
        let x = UIImageView()
        x.tintColor = UIColor.black
        x.translatesAutoresizingMaskIntoConstraints = false
        x.isUserInteractionEnabled = false
        return x
    }()
    
    
    
    
    
    private func setUpViews(imageSize: CGFloat, circleSize: CGFloat){
       
        
        addSubview(circleView)
        addSubview(controlImageView)

        circleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        circleView.layer.cornerRadius = circleSize / 2

        controlImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        controlImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        controlImageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        controlImageView.heightAnchor.constraint(equalTo: controlImageView.widthAnchor).isActive = true
        

    }
    
    
    
    
    
    
    
    
    

    
    
    @objc public func changeButtonImage(withEndingType type: MediaButtonType){
        switch type {
        case .play:
            
            triggerButtonAnimationWith(endingImage: playButtonImage)

        case .pause:
            
            triggerButtonAnimationWith(endingImage: pauseButtonImage)
    
        case .play_pause:
            
            fatalError("Do not use the .play_pause case when calling 'respondToTap(withEndingType:)' on MediaPlayingButton. Please use either the .play or .pause case.")
            
        case .fastForward:
            triggerButtonAnimationWith(endingImage: fastForwardButtonImage)
        case .rewind:
            triggerButtonAnimationWith(endingImage: rewindButtonImage)
        }
    }
    
    
    private let imageDecreaseConstant: CGFloat = 0.8

    
    private func triggerButtonAnimationWith(endingImage: UIImage){
        

        UIView.animate(withDuration: 0.15 , animations: {
            self.controlImageView.transform = CGAffineTransform(scaleX: self.imageDecreaseConstant, y: self.imageDecreaseConstant)
        }) { (success) in
            self.controlImageView.image = endingImage
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.controlImageView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    
    
    private func setButtonImageWithImageType(_ imageType: MediaButtonType){
        switch imageType {
        case .play_pause:
            controlImageView.image = playButtonImage
            
        case .play:
            controlImageView.image = playButtonImage

        case .pause:
            controlImageView.image = pauseButtonImage
        
        case .rewind:
            controlImageView.image = rewindButtonImage
        
        case .fastForward:
            controlImageView.image = fastForwardButtonImage
        }
    }
    
    
    
    
    private var playButtonImage = UIImage(named: "icons8-play-100")!.withRenderingMode(.alwaysTemplate)
    
    private var pauseButtonImage = UIImage(named: "icons8-pause-100")!.withRenderingMode(.alwaysTemplate)
    
    private var fastForwardButtonImage = UIImage(named: "icons8-fast-forward-filled-100")!.withRenderingMode(.alwaysTemplate)
    
    private var rewindButtonImage = UIImage(named: "icons8-rewind-filled-100")!.withRenderingMode(.alwaysTemplate)
    
    
    
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    
    }
    
}


