//
//  CustomTabBar.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/30/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class CustomTabBarItem {
    
    var tag: Int
    var image: UIImage
    var imagePadding: UIEdgeInsets
    var viewController: UIViewController
    
    var badgeValue: String?{
        didSet{
            if let action = badgeValueChangedAction{
                action(badgeValue)
            }
        }
    }
    
    
    var view: UIView{
        return viewController.view
    }
    
    fileprivate var badgeValueChangedAction: ((String?) -> Void)?
    
    init(tag: Int, image: UIImage, viewController: UIViewController, imagePadding: UIEdgeInsets = UIEdgeInsets.zero){
        self.viewController = viewController
        self.tag = tag
        self.image = image
        self.imagePadding = imagePadding
    }
    
}






protocol CustomTabBarDelegate: class{
    func customTabBar(tabBar: CustomTabBar, itemWasSelected newItem: CustomTabBarItem, oldItem: CustomTabBarItem?, animationFinishedBlock: @escaping () -> Void)
}


class CustomTabBar: UIView,  CustomTabBarImageViewDelegate{
    
    
    init(delegate: CustomTabBarDelegate){
        
        self.delegate = delegate

        super.init(frame: CGRect.zero)
        
        clipsToBounds = true
        backgroundColor = .white
        
    }
 
    
    func setItems(items: [CustomTabBarItem]){
        self.items = items
        setUpImagesStackView(for: self.items)
        
    }
    
    
    private weak var delegate: CustomTabBarDelegate?
    
    private(set) var items: [CustomTabBarItem] = []
    
    private let barHeight: CGFloat = 49
    
    private var imagesStackView = UIStackView()
    
    private var imageViews = [CustomTabBarImageView]()
    
    private var currentlySelectedItem: CustomTabBarItem?
    
    
    
    
    
    
    private lazy var topLine: UIView = {
        let x = UIView()
        x.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        imageViews.forEach{$0.tintColor = tintColor}
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {return}
        
        pin(left: superview.leftAnchor, right: superview.rightAnchor, top: superview.safeAreaLayoutGuide.bottomAnchor, bottom: superview.bottomAnchor, insets: UIEdgeInsets(top: -barHeight))

        
        setUpViews()
        setUpImagesStackView(for: items)
    }
    
    
    
   
    
    private func setUpViews(){
        
        addSubview(topLine)
        topLine.pin(left: leftAnchor, right: rightAnchor, top: topAnchor, size: CGSize(height: 0.5))
        
        
        let STACKVIEW_SIDE_INSET: CGFloat = 0
        
        imagesStackView.distribution = .fillEqually
        imagesStackView.axis = .horizontal
        addSubview(imagesStackView)
        
        
        imagesStackView.pin(left: leftAnchor, right: rightAnchor, top: topAnchor, bottom: superview!.safeAreaLayoutGuide.bottomAnchor, insets: UIEdgeInsets(left: STACKVIEW_SIDE_INSET, right: STACKVIEW_SIDE_INSET))
        
    }
    
    
    private func setUpImagesStackView(for items: [CustomTabBarItem]){
        
        imagesStackView.removeAllArangedSubviews()
        imageViews = []
        
        currentlySelectedItem = nil
        
        for item in items{
            let imageView = CustomTabBarImageView(item: item, delegate: self)
            imagesStackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
        }
        if let firstItem = imageViews.first{
            currentlySelectedItem = items.first!
            firstItem.select()
        }
        
    
    }
    
  
    
    
    

    
    
    func selectItem(with tag: Int){
        guard let item = items.filter({$0.tag == tag}).first else { return }
        let imageView = CustomTabBarImageView.getInstanceFor(item: item)!
        
        imageView.select()
        
        imageViews.filter{$0 !== imageView}.forEach{$0.deSelect()}
        let oldItem = currentlySelectedItem
        currentlySelectedItem = item
        
        let completionBlock = {
            self.imagesStackView.isUserInteractionEnabled = true
        }
        
        imagesStackView.isUserInteractionEnabled = false
        
        let timer = Timer(timeInterval: 1.5, repeats: false) { (timer) in
            self.imagesStackView.isUserInteractionEnabled = true
            timer.invalidate()
        }
        
        RunLoop.current.add(timer, forMode: .commonModes)
        
        delegate?.customTabBar(tabBar: self, itemWasSelected: item, oldItem: oldItem, animationFinishedBlock: completionBlock)
    }
    
    
    fileprivate func buttonTapped(imageView: CustomTabBarImageView, item: CustomTabBarItem) {
        selectItem(with: item.tag)
        
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

























fileprivate protocol CustomTabBarImageViewDelegate: class{
    
    func buttonTapped(imageView: CustomTabBarImageView, item: CustomTabBarItem)
    
}






fileprivate class CustomTabBarImageView: UIView{
    
    init(item: CustomTabBarItem, delegate: CustomTabBarImageViewDelegate){

        
        self.delegate = delegate
        self.item = item
        super.init(frame: CGRect.zero)

        item.badgeValueChangedAction = respondToBadgeValueChanged
        
        CustomTabBarImageView.allInstances.append(WeakWrapper(self))
        setUpViews()
    }
    
    
    private func setUpViews(){
        
        let imageSize: CGFloat = 30
        
        addSubview(imageView)
        let padding = item.imagePadding
        imageView.pin(centerX: centerXAnchor, centerY: centerYAnchor, size: CGSize(width: imageSize - padding.left - padding.right, height: imageSize - padding.top - padding.bottom))
        
        imageView.image = item.image.withRenderingMode(.alwaysTemplate)
        
        addSubview(badge)
        badge.pin(centerX: imageView.rightAnchor, centerY: imageView.topAnchor)
        
        setUpCircle()
        
    }
    
    
    
    
    private func respondToBadgeValueChanged(newValue: String?){
        let trimmedValue = newValue?.removeWhiteSpaces()
        
        if trimmedValue == nil && badge.value != nil{
            
            animateBadgeOut()
            
        } else if trimmedValue != nil && badge.value == nil{
            animateBadgeIn()
            
        }
        
        
        badge.value = trimmedValue
    }
    
    private func animateBadgeIn(){
        
        badge.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        badge.alpha = 1
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.badge.transform = CGAffineTransform.identity
        })
    }
    
    private func animateBadgeOut(){
        
        badge.alpha = 1
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.badge.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }){ (success) in
            self.badge.transform = CGAffineTransform.identity
            self.badge.alpha = 0
        }
    }
    
    private var isSelected = false
    
    func select(){
        isSelected = true
        imageView.tintColor = tintColor
    }
    
    func deSelect(){
        isSelected = false
        imageView.tintColor = .lightGray
    }
    
    private static var allInstances = [WeakWrapper<CustomTabBarImageView>]()
    
    static func getInstanceFor(item: CustomTabBarItem) -> CustomTabBarImageView?{
        allInstances = allInstances.filter{$0.value != nil}
        return allInstances.filter{$0.value!.item === item}.first?.value!
    }
    
 
    
    
    
    private let item: CustomTabBarItem
    
    
    private weak var delegate: CustomTabBarImageViewDelegate?
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        if isSelected{
            imageView.tintColor = tintColor
        }
        circleOnColor = tintColor.withAlphaComponent(0.2)
        badge.tintColor = tintColor
    }
    
    private lazy var imageView: UIImageView = {
        let x = UIImageView()
        x.isUserInteractionEnabled = false
        x.contentMode = .scaleAspectFit
        x.tintColor = .lightGray
        return x
        
    }()
    
    
    private lazy var badge: TabBarBadge = {
        let x = TabBarBadge()
        x.tintColor = tintColor
        x.alpha = 0
        return x
        
        
    }()
    
    private lazy var circle: UIView = {
        let x = UIView()
        x.isUserInteractionEnabled = false
        
        x.backgroundColor = .clear
        return x
        
    }()
    
    private lazy var circleOnColor = tintColor.withAlphaComponent(0.2)
    
    private let CIRCLE_SIZE: CGFloat = 80
    
    private func setUpCircle(){
        addSubview(circle)
        circle.pin(centerX: centerXAnchor, centerY: centerYAnchor, size: CGSize(width: CIRCLE_SIZE, height: CIRCLE_SIZE))
        circle.layer.cornerRadius = CIRCLE_SIZE / 2
        
    }
    
    private func animateCircle_In(){
        UIView.animate(withDuration: 0.3) {
            self.circle.backgroundColor = self.circleOnColor
            self.circle.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
        
    }
    
    private func animateCircle_Out(){
        UIView.animate(withDuration: 0.5) {
            self.circle.backgroundColor = .clear
            self.circle.transform = CGAffineTransform.identity
        }
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateCircle_In()
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateCircle_Out()
        delegate?.buttonTapped(imageView: self, item: item)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateCircle_Out()
    }
    

    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
    
}












fileprivate class TabBarBadge: UIView{
    
    init(){
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        setUpViews()
        pin(size: CGSize(width: 10, height: 10))
    }
    
    
    private func setUpViews(){
        addSubview(circle)

        addSubview(textLabel)
        
        
        textLabel.pin(centerX: centerXAnchor, centerY: centerYAnchor)
        
        textLabel.widthAnchor.constraint(greaterThanOrEqualTo: textLabel.heightAnchor).isActive = true
        
        circle.pinAllSidesTo(textLabel, insets: UIEdgeInsets(top: -CIRCLE_OUTSETS_TOP, left: -CIRCLE_OUTSETS_SIDES, bottom: -CIRCLE_OUTSETS_TOP, right: -CIRCLE_OUTSETS_SIDES))
        
    }
    
    private let CIRCLE_OUTSETS_SIDES: CGFloat = 2.5
    private let CIRCLE_OUTSETS_TOP: CGFloat = 2.5

    var value: String?{
        get{
            return textLabel.text
        } set{
            textLabel.text = newValue
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        circle.backgroundColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        circle.layer.cornerRadius = circle.frame.height / 2
       
    }
    
    
    
    
    
    private lazy var textLabel: UILabel = {
        let x = UILabel()
        x.textColor = .white
        x.font = UIFont.systemFont(ofSize: 13)
        x.textAlignment = .center
        return x
        
    }()
    
    
    private lazy var circle: UIView = {
        let x = UIView()
        x.layer.masksToBounds = true
        x.backgroundColor = tintColor
        return x
        
        
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}












