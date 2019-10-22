//
//  About Me.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import ContactsUI




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
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        learnMoreButton.backgroundColor = color
        
    }
    
    private lazy var learnMoreButton: UIButton = {
        let x = UIButton(type: .system)
        
        x.backgroundColor = THEME_COLOR(asker: self)
        
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



























class AboutMeController: PortraitViewController, MFMailComposeViewControllerDelegate{
    
    init(){
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func interfaceColorDidChange(to color: UIColor) {
        shortDescriptionLabel.textColor = color
        innerCloseButton.backgroundColor = color
    }
    
   
    
    
    private lazy var paragraphLabel: UILabel = {
        let x = UILabel()
        x.text = "In addition to being a programming enthusiast in my spare time, I currently major in Accounting at the University of The Bahamas. Yep, that’s right, an Accounting major. So when I’m not gleefully bursting my brain over Xcode, Swift, and iOS development, I’m busy mulling over income statements, journal entries and balance sheets. \n\nThis app is the result of two months of hard work and endless Stack Overflow searches, and will be continuously improved as time goes on. I hope you’re thoroughly enjoying it!"
        x.textAlignment = .center
        x.font = UIFont.systemFont(ofSize: 14)
        x.numberOfLines = 0
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingRectHeight = NSString(string: x.text!).boundingRect(with: CGSize(width: view.frame.width - 50, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: [.font: x.font], context: nil).height + 1
        
        x.heightAnchor.constraint(equalToConstant: boundingRectHeight).isActive = true
        
        return x
    }()
    
    
    
    private lazy var topView: UIView = {
        
        let x = UIView()
        x.backgroundColor = .white
        return x
        
        
    }()
    
    private lazy var bottomView: UIView = {
        
        let x = UIView()
        x.backgroundColor = .white
        return x
        
        
    }()
    
    
    private lazy var shortDescriptionLabel: UILabel = {
        let x = UILabel()
        
        x.textColor = THEME_COLOR(asker: self)
        x.text = "19 | University of The Bahamas | 🇧🇸🇧🇸"
        x.numberOfLines = 1
        x.font = UIFont.systemFont(ofSize: 14)
        
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingRectHeight = NSString(string: x.text!).boundingRect(with: CGSize(width: view.frame.width - 50, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: [.font: x.font], context: nil).height
        
        x.heightAnchor.constraint(equalToConstant: boundingRectHeight).isActive = true
        
        
        return x
        
        
    }()
    
    
    private lazy var imPatrickLabel: UILabel = {
        
        let x = UILabel()
        x.text = "Hey, I'm Patrick!"
        x.textAlignment = .center
        x.font = UIFont.boldSystemFont(ofSize: 16)
        x.numberOfLines = 0
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingRectHeight = NSString(string: x.text!).boundingRect(with: CGSize(width: view.frame.width - 50, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: [.font: x.font], context: nil).height
        
        x.heightAnchor.constraint(equalToConstant: boundingRectHeight).isActive = true
        
        return x
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Variations.Settings.showsScrollIndicator{
            scrollView.flashScrollIndicators()
        }
    }
    
    
    private lazy var scrollView: UIScrollView = {
        
        let x = UIScrollView()
        x.contentLayoutGuide.widthAnchor.constraint(equalTo: x.frameLayoutGuide.widthAnchor).isActive = true
        x.contentLayoutGuide.heightAnchor.constraint(equalTo: x.frameLayoutGuide.heightAnchor, constant: Variations.Settings.scrollViewContentViewHeightDifferenceFactor).isActive = true
        
        x.addSubview(aboutMeLabel)
        x.addSubview(paragraphLabel)
        x.addSubview(shortDescriptionLabel)
        x.addSubview(circleImage)
        x.addSubview(imPatrickLabel)
        
        aboutMeLabel.pin(top: x.contentLayoutGuide.topAnchor, centerX: x.contentLayoutGuide.centerXAnchor, insets: UIEdgeInsets(top: 10))
        
        let CIRCLE_INSETS = Variations.Settings.meImageTopAndBottomSpacing
        
        let circleImageHolder = UIView()
        circleImageHolder.addSubview(circleImage)
        
        x.addSubview(circleImageHolder)
        
        circleImageHolder.pin(left: x.contentLayoutGuide.leftAnchor, right: x.contentLayoutGuide.rightAnchor, top: aboutMeLabel.bottomAnchor, bottom: imPatrickLabel.topAnchor, centerX: x.contentLayoutGuide.centerXAnchor, insets: UIEdgeInsets(top: CIRCLE_INSETS, bottom: CIRCLE_INSETS))
        
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        circleImage.topAnchor.constraint(greaterThanOrEqualTo: circleImageHolder.topAnchor).isActive = true
        circleImage.bottomAnchor.constraint(lessThanOrEqualTo: circleImageHolder.bottomAnchor).isActive = true
        
        
        circleImage.centerXAnchor.constraint(equalTo: circleImageHolder.centerXAnchor).isActive = true
        circleImage.centerYAnchor.constraint(equalTo: circleImageHolder.centerYAnchor).isActive = true
        circleImage.widthAnchor.constraint(equalTo: circleImage.heightAnchor).isActive = true
        {
            let h = circleImage.heightAnchor.constraint(equalToConstant: 1000)
            h.priority = UILayoutPriority(900)
            h.isActive = true
        }()
        
        circleImage.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        
        
        imPatrickLabel.pin(bottom: shortDescriptionLabel.topAnchor, centerX: x.contentLayoutGuide.centerXAnchor, insets: UIEdgeInsets(bottom: 3))
        
        shortDescriptionLabel.pin(bottom: paragraphLabel.topAnchor, centerX: x.contentLayoutGuide.centerXAnchor, insets: UIEdgeInsets(bottom: 10))
        
        paragraphLabel.pin(left: x.contentLayoutGuide.leftAnchor, right: x.contentLayoutGuide.rightAnchor, bottom: x.contentLayoutGuide.bottomAnchor, insets: UIEdgeInsets(left: 25, right: 25))
        
        return x
    }()
    
    
    
    
    
    private lazy var aboutMeLabel: UILabel = {
        let x = UILabel()
        x.text = "About Me"
        x.numberOfLines = 1
        x.font = UIFont.boldSystemFont(ofSize: 40)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingRectHeight = NSString(string: x.text!).boundingRect(with: CGSize(width: view.frame.width - 50, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: [.font: x.font], context: nil).height
        
        x.heightAnchor.constraint(equalToConstant: boundingRectHeight).isActive = true
        
        return x
    }()
    
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView(image: #imageLiteral(resourceName: "ME"))
        x.contentMode = .scaleAspectFill
        return x
        
    }()
    
    private let innerCircleImage = UIImageView(image: #imageLiteral(resourceName: "ME"))

    
    private lazy var circleImage: UIView = {
        innerCircleImage.contentMode = .scaleAspectFill
        innerCircleImage.layer.masksToBounds = true
        let wrapper = UIView()
        wrapper.addSubview(innerCircleImage)
        innerCircleImage.pinAllSidesTo(wrapper)
        
        wrapper.backgroundColor = .clear
        wrapper.layer.shadowColor = UIColor.black.cgColor
        wrapper.layer.shadowRadius = 10
        wrapper.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapper.layer.shadowOpacity = 0.8
        
        return wrapper
    }()
    
    
    
    private let innerCloseButton = UIButton(type: .system)

    private lazy var closeButton: UIView = {
        let x = UIView()
        
    
        x.backgroundColor = .clear
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowRadius = 10
        x.layer.shadowOffset = CGSize(width: 0, height: 2)
        x.layer.shadowOpacity = 0.8
        

        innerCloseButton.backgroundColor = THEME_COLOR(asker: self)
        innerCloseButton.layer.masksToBounds = true
        
        innerCloseButton.setAttributedTitle(NSAttributedString(string: "Close", attributes: [.font: UIFont.boldSystemFont(ofSize: 14.5), .foregroundColor: UIColor.white]), for: .normal)
        
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
        
        
        button1.addTarget(self, action: #selector(respondToFacebookButtonPressed), for: .touchUpInside)
        button2.addTarget(self, action: #selector(respondToSnapChatButtonPressed), for: .touchUpInside)
        button3.addTarget(self, action: #selector(respondToWhatsAppButtonPressed), for: .touchUpInside)
        button4.addTarget(self, action: #selector(respondToEmailButtonPressed), for: .touchUpInside)
        
        let x = UIStackView(arrangedSubviews: [button1, button2, button3, button4])
        x.axis = .horizontal
        x.distribution = .fillEqually
        x.spacing = 20
        return x
        
    }()
    
    
    @objc private func respondToEmailButtonPressed(){
        
        
        if MFMailComposeViewController.canSendMail(){
            let newController = MFMailComposeViewController()
            newController.setSubject("Music App Feedback")
            newController.setToRecipients(["patrickjh1998@hotmail.com"])
            newController.setMessageBody("Hey Patrick, your app is awesome!", isHTML: false)
            newController.mailComposeDelegate = self
            self.present(newController, animated: true, completion: nil)
        } else {
            AppManager.displayErrorMessage(target: self, message: "For some reason, iOS is now allowing this app to send emails. Check your email settings.", completion: nil)
        }
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        controller.dismiss(animated: true){
            if let error = error{
            AppManager.displayErrorMessage(target: self, message: error.localizedDescription, completion: nil)
            }
            
        }
    }
    
    
    
    @objc private func respondToFacebookButtonPressed(){
        
        guard let url = URL(string: "https://www.facebook.com/patrick.hanna.75") else { return }
        guard let appURL = URL(string: "fb://profile/100002070912835") else {return}
        if UIApplication.shared.canOpenURL(appURL){
            UIApplication.shared.open(appURL, completionHandler: nil)
        } else {
            UIApplication.shared.open(url) { (success) in
                if !success{
                    AppManager.displayErrorMessage(target: self, message: "An error occured when trying to redirect you to my Facebook page 😞.", completion: nil)
                    return
                }
                
            }
        }
    }
    
    @objc private func respondToWhatsAppButtonPressed(){
        let newContact = CNMutableContact()
        newContact.givenName = "Patrick Hanna"
        
        newContact.phoneNumbers.append(CNLabeledValue(label: "cell", value: CNPhoneNumber(stringValue: "+1 (242) 809-2518")))
        let contactVC = CNContactViewController(forUnknownContact: newContact)
        contactVC.contactStore = CNContactStore()
        contactVC.allowsActions = false
        navController = UINavigationController(rootViewController: contactVC)
        contactVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(respondToContactCancelButtonTapped))
        self.present(navController, animated: true, completion: nil)
        
        
    }
    
    
    
    private var navController: UINavigationController!
    
    @objc private func respondToContactCancelButtonTapped(){
        
        navController.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @objc func respondToSnapChatButtonPressed(){
        let url = URL(string: "snapchat://www.snapchat.com/add/patrickjh1998")!
        
        UIApplication.shared.open(url) { (success) in
            if !success{
                self.displayDownloadSnapchatAlert()
                
            }
        }
        
    }
    
    private func displayDownloadSnapchatAlert(){
        
        let alert = UIAlertController(title: "You don't have Snapchat installed 😣", message: "I tried to redirect you to my profile on Snapchat, but you don't have it installed 😰. Would you like to install it now?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let installAction = UIAlertAction(title: "Install", style: .default) { (action) in
            
            let url = URL(string: "itms://itunes.apple.com/us/app/apple-store/id447188370?mt=8")!
            UIApplication.shared.open(url, completionHandler: { (success) in
                if !success {
                    AppManager.displayErrorMessage(target: self, message: "Something went wrong when trying to redirect you to the iTunes store.", completion: nil)
                }
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(installAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    

    @objc private func respondtoDismissButtonPressed(){
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        innerCloseButton.layer.cornerRadius = innerCloseButton.frame.height / 2
        innerCircleImage.layer.cornerRadius = innerCircleImage.frame.height / 2
        
    }
    
    
    
    
    private func setUpViews(){
        
        
        view.addSubview(topView)
        view.addSubview(bottomView)
        view.addSubview(closeButton)
        view.addSubview(socialMediaStackView)
        view.addSubview(scrollView)
     
        closeButton.pin(right: view.rightAnchor, top: view.safeAreaLayoutGuide.topAnchor, size: CGSize(width: 70, height: 30), insets: UIEdgeInsets(top: 10, right: 20))
        topView.pin(left: view.leftAnchor, right: view.rightAnchor, top: view.topAnchor, bottom: closeButton.bottomAnchor, insets: UIEdgeInsets(bottom: -20))
        socialMediaStackView.pin(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, insets: UIEdgeInsets(left: 25, bottom: 25, right: 25))
        bottomView.pin(left: view.leftAnchor, right: view.rightAnchor, top: socialMediaStackView.topAnchor, bottom: view.bottomAnchor,insets: UIEdgeInsets(top: -25))
        scrollView.pin(left: view.leftAnchor, right: view.rightAnchor, top: topView.bottomAnchor, bottom: bottomView.topAnchor)
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
        setUpViews()
    }
    
    
    private lazy var socialMediaImage: UIImageView = {
        
        let x = UIImageView()
        x.contentMode = .scaleAspectFill
        x.layer.masksToBounds = true
        x.isUserInteractionEnabled = false
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
        
        
        x.isUserInteractionEnabled = false
        socialMediaImage.pinAllSidesTo(x)
        
        return x
        
        
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        let value = socialMediaImage.frame.width / 2
        socialMediaImage.layer.cornerRadius = value
        
    }
    

    
    
    
    
    private func animateButtonIn(){
        
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.socialMediaImageHolder.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        })
        
    }
    
    private func animateButtonOut(){
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.socialMediaImageHolder.transform = CGAffineTransform.identity
            
        })
        
    }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateButtonIn()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateButtonOut()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateButtonOut()
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

