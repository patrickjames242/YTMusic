//
//  MinimizedNowPlayingPreview.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/11/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit

class MinimizedNowPlayingPreview: UIView{
    
    
    init(nameLabelLeftInset: CGFloat){
        super.init(frame: CGRect.zero)
        
        setUpViews(nameLabelLeftInset: nameLabelLeftInset)
        
    }
    
    
    lazy var topLine: UIView = {
        let x = UIView()
        x.backgroundColor = .lightGray
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    lazy var progressBar: ProgressIndicator = {
        let x = ProgressIndicator()
        x.backgroundColor = .clear
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    
    lazy var songNameLabel: UILabel = {
        let x = UILabel()
        x.textColor = .black
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    lazy var rewindButton: MediaPlayingButton = {
        let x = MediaPlayingButton(buttonType: .rewind, imageSize: 30, circleSize: 50)
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    lazy var playPauseButton: MediaPlayingButton = {
        let x = MediaPlayingButton.init(buttonType: .play_pause, imageSize: 30, circleSize: 50)
        x.translatesAutoresizingMaskIntoConstraints = false
        
        x.automaticallyAnimatesImageWhenTapped = false
        
        
        return x
    }()
    
    
    lazy var fastForwardButton: MediaPlayingButton = {
        let x = MediaPlayingButton(buttonType: .fastForward, imageSize: 30, circleSize: 50)
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    
    
    
    
    
    lazy var musicControlsStackView: UIStackView = {
        let x = UIStackView(arrangedSubviews: [rewindButton,
                                               playPauseButton,
                                               fastForwardButton])
        x.spacing = 7.5
        x.distribution = .fillEqually
        
        fastForwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        fastForwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        x.translatesAutoresizingMaskIntoConstraints = false
        
        
        return x
    }()
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        fadeBackgroundIn()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        fadeBackgroundOut()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        fadeBackgroundOut()
    }
    
    
    private func fadeBackgroundIn(){
        backgroundColor = UIColor(red: 215, green: 215, blue: 215)

        
    }
    
    private func fadeBackgroundOut(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = .clear
        })
    }
    
    
    private func setUpViews(nameLabelLeftInset: CGFloat){
        
        
        backgroundColor = .clear
        
        
        
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(songNameLabel)
        addSubview(musicControlsStackView)
        addSubview(topLine)
        addSubview(progressBar)
        
        let label = songNameLabel
        let stackView = musicControlsStackView
        let bar = progressBar
        
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant:nameLabelLeftInset).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: stackView.leftAnchor, constant: -5).isActive = true
        
        topLine.pin(left: leftAnchor, right: rightAnchor, top: topAnchor, size: CGSize(height: 0.5))
        
    }
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}
