//
//  CustomSlider.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MediaPlayer


protocol CustomSliderDelegate {
    func sliderDidBeginSliding(withAnimationTime time: Double)
    func sliderDidEndSliding(withAnimationTime time: Double, at point: Double)
}






class CustomSlider: UIView {
    
    
    override init(frame: CGRect) {
        let customFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: requiredHeight)
        super.init(frame: customFrame)
        
        positionSlidingTracks()
        positionButtonAndActivationArea()
    }
    
    
    
    private func positionSlidingTracks(){
        addSubview(sliderTrack)
        addSubview(leftTimeLabel)
        addSubview(rightTimeLabel)

    }
    
    private func positionButtonAndActivationArea(){
        addSubview(superSliderButton)
        sliderButton.center = superSliderButton.centerInBounds
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - PUBLIC PROPERTIES
    
    var customDelegate: CustomSliderDelegate?
    
    var sliderButtonAnimationTime = 0.3
    private var activeColor: UIColor = THEME_COLOR
    private var inactiveColor: UIColor = .gray
    private var rightSideColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3)
    

    var initialButtonSize: CGFloat = 7
    var endingButtonSize: CGFloat = 30
    var buttonActivationAreaSize: CGFloat = 40
    
    var sliderTrackHeight: CGFloat = 3
    
    var songDuration: Double = 5

    
    func syncSliderPositionWith(playBackPosition: TimeInterval){
        syncTimeLabelTextsWithSlider(playBackPosition: playBackPosition)
        toggleFingerPointPosition = sliderTrack.frame.width * CGFloat(playBackPosition / songDuration)
        syncToggleWithToggleFingerPointPosition()
    }
    
    
    
    private func syncTimeLabelTextsWithSlider(playBackPosition: TimeInterval){
        
        let currentMomentInSong = playBackPosition.positionalTime
        let timeLeftInSong = "-" + (songDuration - playBackPosition).positionalTime
        
        leftTimeLabel.text = currentMomentInSong
        rightTimeLabel.text = timeLeftInSong
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - PRIVATE PROPERTIES
    
    private var requiredHeight: CGFloat = 40


    
    
    private enum SideBumped { case left, right }
    
    private var timeLabelsDefaultYPosition: CGFloat = 11.5
    
    private lazy var leftTimeLabel: UILabel = {
       let x = UILabel(frame: CGRect(x: 0,
                                     y: timeLabelsDefaultYPosition,
                                     width: 200,
                                     height: 50))
        x.font = UIFont.boldSystemFont(ofSize: 13)
        x.textColor = self.leftSliderTrack.backgroundColor
        x.textAlignment = .left
        x.text = "0:00"
        return x
    }()
    
    private lazy var rightTimeLabel: UILabel = {
        let x = UILabel()
        x.font = UIFont.boldSystemFont(ofSize: 13)
        x.textColor = self.rightSliderTrack.backgroundColor?.withAlphaComponent(0.9)
        x.frame.size.height = 50
        x.frame.size.width = 200
        x.rightSide = sliderTrack.rightSide
        x.topSide = leftTimeLabel.topSide
        
        x.textAlignment = .right
        x.text = "-" + songDuration.positionalTime
        return x
    }()
    
    private lazy var superSliderButton: UIView = {
        let x = UIView()
        x.frame.size.width = buttonActivationAreaSize
        x.frame.size.height = x.frame.width
        x.center = CGPoint(x: leftSliderTrack.rightSide, y: sliderTrack.centerInFrame.y)
        x.addSubview(sliderButton)
        let interactionGesture = UIPanGestureRecognizer(target: self, action: #selector(moveToggleWithGesture(gesture:)))
        x.addGestureRecognizer(interactionGesture)
        return x
    }()
    
    private lazy var sliderButton: UIView = {
        let x = UIView()
        x.frame.size.width = initialButtonSize
        x.frame.size.height = x.frame.width
        
        x.layer.cornerRadius = x.halfOfWidth
        x.layer.masksToBounds = true
        
        x.backgroundColor = inactiveColor
        return x
    }()
    
    private lazy var sliderTrack: UIView = {
        let x = UIView(frame: CGRect(x: 0,
                                     y: self.halfOfHeight - (sliderTrackHeight / 2),
                                     width: frame.width,
                                     height: sliderTrackHeight))
        
        x.addSubview(leftSliderTrack)
        x.addSubview(rightSliderTrack)
        return x
    }()
    
    private lazy var leftSliderTrack: UIView = {
        let x = UIView(frame: CGRect(x: 0,
                                     y: 0,
                                     width: toggleFingerPointPosition,
                                     height: sliderTrackHeight))
        x.backgroundColor = inactiveColor
        
        x.layer.cornerRadius = x.halfOfHeight
        x.layer.masksToBounds = true
        return x
    }()
    
    private lazy var rightSliderTrack: UIView = {
        let x = UIView(frame: CGRect(x: leftSliderTrack.frame.width,
                                     y: 0,
                                     width: frame.width - leftSliderTrack.frame.width,
                                     height: sliderTrackHeight))
        x.backgroundColor = rightSideColor
        
        x.layer.cornerRadius = x.halfOfHeight
        x.layer.masksToBounds = true
        return x
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - ANIMATION HANDLING
    

    private func setActiveColor(){
        sliderButton.backgroundColor = activeColor
        leftSliderTrack.backgroundColor = activeColor
        leftTimeLabel.textColor = activeColor
    }
    
    private func setInactiveColor(){
        sliderButton.backgroundColor = inactiveColor
        leftSliderTrack.backgroundColor = inactiveColor
        leftTimeLabel.textColor = inactiveColor
    }
    
    
    private func enlargeSliderButton(toggleButtonBumpedSide: (Bool, SideBumped?)){
        
        UIView.animate(withDuration: sliderButtonAnimationTime, animations: {
            self.sliderButton.frame.size.width = self.endingButtonSize
            self.sliderButton.frame.size.height = self.endingButtonSize
            self.sliderButton.layer.cornerRadius = self.sliderButton.halfOfWidth
            self.sliderButton.center = self.superSliderButton.centerInBounds
            self.superSliderButton.center.x = self.leftSliderTrack.rightSide

            self.setActiveColor()
            
            self.handleSideBumping(toggleButtonBumpedSide: toggleButtonBumpedSide)
            
        })
        
    }
    
    
    
    private func handleSideBumping(toggleButtonBumpedSide: (Bool, SideBumped?)){
        
        let differenceBetweenHalfSuperSliderButtonAndSliderButton = (superSliderButton.halfOfWidth - sliderButton.halfOfWidth)
        
        if toggleButtonBumpedSide.0{
            
            switch toggleButtonBumpedSide.1!{
            case .left:
                self.superSliderButton.leftSide =
                    differenceBetweenHalfSuperSliderButtonAndSliderButton * -1
            case .right:
                self.superSliderButton.rightSide = sliderTrack.frame.width + (superSliderButton.halfOfWidth - sliderButton.halfOfWidth)
            }
            
        }
    }
    
    
    
    private func shrinkSliderButton(toggleButtonBumpedSide: (Bool, SideBumped?)){
        
        UIView.animate(withDuration: sliderButtonAnimationTime, animations: {
            self.sliderButton.frame.size.width = self.initialButtonSize
            self.sliderButton.frame.size.height = self.initialButtonSize
            
            self.sliderButton.layer.cornerRadius = self.sliderButton.frame.width / 2
            
            self.sliderButton.center = self.superSliderButton.centerInBounds
            self.superSliderButton.center.x = self.leftSliderTrack.rightSide
            self.setInactiveColor()
            
            self.handleSideBumping(toggleButtonBumpedSide: toggleButtonBumpedSide)
            
        })
        
    }
    
    
    private func moveTimeLabelsIfNeeded(gestureState: UIGestureRecognizerState){
        
        let endingDistanceForLabels = timeLabelsDefaultYPosition + 10
        switch gestureState{
        case .began:
            
            UIView.animate(withDuration: sliderButtonAnimationTime, animations: {
               
                self.rightTimeLabel.frame.origin.y = endingDistanceForLabels
                self.leftTimeLabel.frame.origin.y = endingDistanceForLabels

            })
        case .ended:
            
            UIView.animate(withDuration: sliderButtonAnimationTime, animations: {
                
                self.rightTimeLabel.frame.origin.y = self.timeLabelsDefaultYPosition
                self.leftTimeLabel.frame.origin.y = self.timeLabelsDefaultYPosition
                
            })
        default: break
        }
        
        
    }
    
    
    
    private var toggleFingerPointPosition: CGFloat = 50
    
    private var sliderIsSliding = false
    
    @objc private func moveToggleWithGesture(gesture: UIPanGestureRecognizer){
        let gestureXMovement = gesture.translation(in: superSliderButton).x
        
        
        var toggleButtonBumpedSide: (Bool, SideBumped?) = (false, nil)
        
        toggleFingerPointPosition = min(max(toggleFingerPointPosition + gestureXMovement, 0), sliderTrack.frame.width)
        
        
        
        if toggleFingerPointPosition < initialButtonSize / 2{
            
            toggleButtonBumpedSide = (true, .left)
            
        } else if (sliderTrack.frame.width - toggleFingerPointPosition) < initialButtonSize / 2 {
            
            toggleButtonBumpedSide = (true, .right)

        }
        
        
        
        syncToggleWithToggleFingerPointPosition()
        
        
        moveTimeLabelsIfNeeded(gestureState: gesture.state)
        
        
        
        
        switch gesture.state {
        case .began:
            sliderIsSliding = true
            customDelegate?.sliderDidBeginSliding(withAnimationTime: sliderButtonAnimationTime)
            enlargeSliderButton(toggleButtonBumpedSide: toggleButtonBumpedSide)
        case .changed:
            
            let position = TimeInterval(toggleFingerPointPosition / sliderTrack.frame.width) * songDuration
            
            syncTimeLabelTextsWithSlider(playBackPosition: position)
        case .ended:
            sliderIsSliding = false
            customDelegate?.sliderDidEndSliding(withAnimationTime: sliderButtonAnimationTime, at: Double(toggleFingerPointPosition) / Double(sliderTrack.frame.width))
            shrinkSliderButton(toggleButtonBumpedSide: toggleButtonBumpedSide)
            
        default: break
        }

        
        gesture.setTranslation(CGPoint.zero, in: superSliderButton)
    }
    
    private func syncToggleWithToggleFingerPointPosition(){
        let differenceBetweenHalfSuperSliderButtonAndHalfSliderButton = (superSliderButton.halfOfWidth - sliderButton.halfOfWidth)
        
        let minimumMinX = 0 - differenceBetweenHalfSuperSliderButtonAndHalfSliderButton
        let maximumMinX = (sliderTrack.frame.width + differenceBetweenHalfSuperSliderButtonAndHalfSliderButton) - superSliderButton.frame.width
        
        superSliderButton.leftSide = max(minimumMinX, min( toggleFingerPointPosition - superSliderButton.halfOfWidth , maximumMinX ))
        
        leftSliderTrack.frame.size.width = toggleFingerPointPosition
        rightSliderTrack.frame.origin.x = leftSliderTrack.frame.maxX
        rightSliderTrack.frame.size.width = sliderTrack.frame.width - leftSliderTrack.frame.width
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
