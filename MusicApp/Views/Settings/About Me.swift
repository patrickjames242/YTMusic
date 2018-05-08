//
//  About Me.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit





class AboutMeView: UIView {
    
    init(){
        super.init(frame: CGRect.zero)
        setUpViews()
        
        
    }
    
    
    private func setUpViews(){
        
        addSubview(imageView)
        addSubview(learnMoreButtonHolderView)
        addSubview(topLabel)
        
        imageView.pin(left: leftAnchor, top: topAnchor, bottom: bottomAnchor, width: imageView.heightAnchor)
        
        learnMoreButtonHolderView.pin(left: imageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, size: CGSize(height: 35), insets: UIEdgeInsets(left: 15, bottom: 7))
        
        topLabel.pin(bottom: learnMoreButtonHolderView.topAnchor, centerX: learnMoreButtonHolderView.centerXAnchor, insets: UIEdgeInsets(bottom: 15))
        
        
        learnMoreButton.layer.cornerRadius = 35 / 2
        
    }

    
    
    
    
    
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: #imageLiteral(resourceName: "ME"))
        x.layer.masksToBounds = true
        x.contentMode = .scaleAspectFill
        return x
    }()
    
    private lazy var learnMoreButtonHolderView: UIView = {
        
        let x = UIView()
       
        
        x.backgroundColor = .clear
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowRadius = 10
        x.layer.shadowOffset = CGSize(width: 0, height: 2)
        x.layer.shadowOpacity = 0.8
        
        x.addSubview(learnMoreButton)
        
        learnMoreButton.pinAllSidesTo(x)
        
        return x
        
    }()
    
    private lazy var learnMoreButton: UIButton = {
        let x = UIButton(type: .system)
        
        x.backgroundColor = THEME_COLOR
        
        x.setAttributedTitle(NSAttributedString(string: "Learn More", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]), for: .normal)
        
        x.addTarget(self, action: #selector(respondToLearnMoreButtonPressed), for: .touchUpInside)
        
        x.layer.masksToBounds = true
        return x
        
        
        
    }()
    
    
    @objc private func respondToLearnMoreButtonPressed(){
        
        AppManager.shared.screen.present(AboutMeController(), animated: true, completion: nil)
        
        
    }
    
    
    private lazy var topLabel: UILabel = {
        
        let x = UILabel()
        x.numberOfLines = 2
        x.textAlignment = .center
        x.text = "Hey, I'm Patrick! \nI'm the creator of this App."
        x.font = UIFont.systemFont(ofSize: 16)
        return x
        
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fool")
    }
}



























class AboutMeController: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUpViews()
        
        
    }
    
    
    
    private lazy var paragraphLabel: UILabel = {
        let x = UILabel()
        x.text = "In addition to being a programming enthusiast in my spare time, I currently major in Accounting at the University of The Bahamas. Yep, that’s right, an Accounting major. So when I’m not gleefully bursting my brain over Xcode, Swift, and iOS development, I’m busy mulling over income statements, journal entries and balance sheets. \n\nThis app is the amalgamation of two months of hard work and endless Stack Overflow searches, and will be continuously improved as time goes on. I hope you’re thoroughly enjoying it!"
        x.textAlignment = .center
        x.font = UIFont.systemFont(ofSize: 14)
        x.numberOfLines = 0
        return x
        
        
    }()
    
    
    
    private lazy var topView: UIView = {
        
        let x = UIView()
        return x
        
        
    }()
    
    private lazy var bottomView: UIView = {
        
        let x = UIView()
        return x
        
        
    }()
    
    private lazy var aboutMeLabel: UILabel = {
        let x = UILabel()
        x.text = "About Me"
        x.font = UIFont.boldSystemFont(ofSize: 40)
        return x
    }()
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: #imageLiteral(resourceName: "ME"))
        x.contentMode = .scaleAspectFill
        return x
        
    }()
    
    
    
    private let innerCloseButton = UIButton(type: .system)

    private lazy var closeButton: UIView = {
        let x = UIView()
        
    
        x.backgroundColor = .clear
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowRadius = 10
        x.layer.shadowOffset = CGSize(width: 0, height: 2)
        x.layer.shadowOpacity = 0.8
        
        
    
        
        innerCloseButton.backgroundColor = THEME_COLOR
        innerCloseButton.layer.masksToBounds = true
        
        innerCloseButton.setAttributedTitle(NSAttributedString(string: "close", attributes: [.font: UIFont.boldSystemFont(ofSize: 14.5), .foregroundColor: UIColor.white]), for: .normal)
        
        innerCloseButton.addTarget(self, action: #selector(respondtoDismissButtonPressed), for: .touchUpInside)
        
        innerCloseButton.layer.masksToBounds = true
        
        
        x.addSubview(innerCloseButton)
        innerCloseButton.pinAllSidesTo(x)
        
        return x
        
    }()
    
    
    
    private var socialMediaStackView: UIStackView = {
        
        let button1 = SocialMediaButton(type: .facebook)
        let button2 = SocialMediaButton(type: .snapchat)
        let button3 = SocialMediaButton(type: .whatsapp)
        let button4 = SocialMediaButton(type: .email)
        
        let x = UIStackView(arrangedSubviews: [button1, button2, button3, button4])
        x.axis = .horizontal
        x.distribution = .fillEqually
        x.spacing = 20
        return x
        
    }()
    
    

    @objc private func respondtoDismissButtonPressed(){
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        innerCloseButton.layer.cornerRadius = innerCloseButton.frame.height / 2
        
    }
    
    
    
    
    private func setUpViews(){
        
        view.addSubview(closeButton)
        view.addSubview(socialMediaStackView)
        view.addSubview(aboutMeLabel)
        view.addSubview(paragraphLabel)
        
        closeButton.pin(right: view.rightAnchor, top: view.safeAreaLayoutGuide.topAnchor, size: CGSize(width: 70, height: 30), insets: UIEdgeInsets(top: 10, right: 20))
        
        aboutMeLabel.pin(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, insets: UIEdgeInsets(top: 60))
        
        
        
        paragraphLabel.pin(left: socialMediaStackView.leftAnchor, right: socialMediaStackView.rightAnchor, bottom: socialMediaStackView.topAnchor, insets: UIEdgeInsets(bottom: 50))
        
        
        socialMediaStackView.pin(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, insets: UIEdgeInsets(left: 25, bottom: 25, right: 25))
        
        
        
    }
    
    
    
    
    
    
}







































































fileprivate class SocialMediaButton: UIButton{
    
    
    enum SocialMediaImageType: String{
        case whatsapp = "whatsapp"
        case snapchat = "snapchat"
        case facebook = "facebook"
        case email = "email"
    }
    
    
    
    
    init(type: SocialMediaImageType){
        
        super.init(frame: CGRect.zero)
        socialMediaImage.image = UIImage(named: type.rawValue)
//        socialMediaImage.image = UIImage(named: "facebook")

        setUpViews()
    }
    
    
    private lazy var socialMediaImage: UIImageView = {
        
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.backgroundColor = THEME_COLOR
        x.layer.masksToBounds = true
        return x
        
    }()
    
    private lazy var socialMediaImageHolder: UIView = {
        let x = UIView()
        x.backgroundColor = .clear
        
        let y = x.layer
        
        y.shadowColor = UIColor.black.cgColor
        y.shadowRadius = 10
        y.shadowOffset = CGSize(width: 0, height: 2)
        y.shadowOpacity = 0.8
        
        
        x.addSubview(socialMediaImage)
        
        
        
        socialMediaImage.pinAllSidesTo(x)
        
        return x
        
        
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        let value = socialMediaImage.frame.width / 2
        socialMediaImage.layer.cornerRadius = value
        
    }
    

    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
  
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.socialMediaImageHolder.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            
        }) { (success) in

            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.socialMediaImageHolder.transform = CGAffineTransform.identity

            })
            
            
        }
        
        
    }
    

    
    

    
    
    
    
    private func setUpViews(){
        
        addSubview(socialMediaImageHolder)
        
        socialMediaImageHolder.pin(centerX: centerXAnchor, centerY: centerYAnchor, width: widthAnchor, height: heightAnchor)
        self.pin(width: heightAnchor, height: widthAnchor)
        
    }
    
    
   
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Fool!")
    }
}

























