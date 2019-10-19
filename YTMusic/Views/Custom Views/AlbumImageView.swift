//
//  AlbumImageView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/18/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit




class AlbumImageView: UIView{
    
    
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setUpViews()
//
//    }
//
//    override init(image: UIImage?) {
//        super.init(image: image)
//        setUpViews()
//    }
//
//    override init(image: UIImage?, highlightedImage: UIImage?) {
//        super.init(image: image, highlightedImage: highlightedImage)
//        setUpViews()
//
//    }
    
    init(){
        super.init(frame: CGRect.zero)
        setUpViews()
    }
    
    
    override var frame: CGRect{
        get{
            return super.frame
        }
        set{
            
            super.frame = newValue
            layoutIfNeeded()
        }
    }
    
    
    
    var image: UIImage?{
        
        get{ return myImage.image }
        
        set{
            self.myImage.image = newValue
 
        }
        
    }
    
   
    
    
    func hideShadow(with time: TimeInterval){
        
        let animator = CABasicAnimation(keyPath: "shadowOpacity")
        animator.fromValue = imageContainerView.layer.shadowOpacity
        animator.toValue = 0
        animator.duration = time
        imageContainerView.layer.add(animator, forKey: animator.keyPath!)
        imageContainerView.layer.shadowOpacity = 0
        
    }
    private var fullShadowOpacity: Float = 0.8
    
    func showShadow(with time: TimeInterval){
        let animator = CABasicAnimation(keyPath: "shadowOpacity")
        animator.fromValue = imageContainerView.layer.shadowOpacity
        animator.toValue = fullShadowOpacity
        animator.duration = time
        imageContainerView.layer.add(animator, forKey: animator.keyPath!)
        imageContainerView.layer.shadowOpacity = fullShadowOpacity
    }
    
    func minimizeImage(){
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.imageContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        
    }
    
    func maximizeImage(){
        
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveLinear, animations: {
            self.imageContainerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func setUpViews(){
        addSubview(imageContainerView)
        imageContainerView.addSubview(myImage)
        
        
        imageContainerView.pin(centerX: centerXAnchor, centerY: centerYAnchor, width: widthAnchor)
        imageContainerView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor, multiplier: 9/16).isActive = true

        
        
        myImage.leftAnchor.constraint(equalTo: imageContainerView.leftAnchor).isActive = true
        myImage.rightAnchor.constraint(equalTo: imageContainerView.rightAnchor).isActive = true
        myImage.topAnchor.constraint(equalTo: imageContainerView.topAnchor).isActive = true
        myImage.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor).isActive = true
        
    }
    private lazy var imageContainerView: UIView = {
        let x = UIView()
        x.translatesAutoresizingMaskIntoConstraints = false
        x.backgroundColor = .clear
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowOffset = CGSize(width: 0, height: 10)
        x.layer.shadowRadius = 30
        x.layer.shadowOpacity = 0
        x.layer.masksToBounds = false
        return x
        
        
    }()
    
    private lazy var myImage: UIImageView = {
       let x = UIImageView()
        
        x.translatesAutoresizingMaskIntoConstraints = false

        x.contentMode = .scaleAspectFill
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
        return x
        
        
    }()
    

    
    

    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

