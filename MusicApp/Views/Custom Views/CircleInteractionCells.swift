//
//  CircleInteractionCells.swift
//  MusicApp
//
//  Created by Patrick Hanna on 6/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit







fileprivate class CircleInteractor{
    
    private var view = UIView()
    private var isRespondingToTap = false

    fileprivate var tapAction = {
        
        
    }
    
    fileprivate var longPressAction = {
        
    }
    
    
    func setUp(with view: UIView){
        
        self.view = view
        setUpViews()
        
        view.clipsToBounds = true
        let gesture = UITapGestureRecognizer()
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.cancelsTouchesInView = false
        
        view.addGestureRecognizer(gesture)
        gesture.addTarget(self, action: #selector(respondToTapGesture(gesture:)))
        
        
        let gesture2 = UILongPressGestureRecognizer()
        gesture2.delaysTouchesBegan = false
        gesture2.delaysTouchesEnded = false
        gesture2.cancelsTouchesInView = false
        gesture2.addTarget(self, action: #selector(respondToLongPressGesture(gesture:)))
        
    }
    
    var circleToScale: CGFloat = 175
    
    
    @objc private func respondToLongPressGesture(gesture: UILongPressGestureRecognizer){
        if gesture.state != .recognized{return}
        longPressAction()
    }
    
    @objc private func respondToTapGesture(gesture: UITapGestureRecognizer){
        if gesture.state != .recognized{return}
        tapAction()
        let point = gesture.location(in: view)
        respondToTap(at: point)
        
        
    }
    
    func highLight(){
        self.highlightView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.highlightView.alpha = 0.3
        }){ (success) in
            
            UIView.animate(withDuration: 0.5, delay: 0.3,animations: {
                self.highlightView.alpha = 0
            })
            
        }    }
    
    func respondToTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if isRespondingToTap{return}
        fadeHighlightView_In()
    }
    
    func respondToTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRespondingToTap{return}
        fadeHighLightedView_Out()
    }
        

    
    func respondToTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRespondingToTap{return}
        fadeHighLightedView_Out()
        animateCircle(at: touches.first!.location(in: view))
    }
    
    
    private func fadeHighlightView_In(){
        UIView.animate(withDuration: 0.5) {
            self.highlightView.alpha = 0.3
        }
    }
    
    
    private func fadeHighLightedView_Out(){
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = 0
        }
    }
    
    
    private func stopAllObjectAnimations(){
        self.highlightView.stopAnimations()
        self.circle.stopAnimations()
    }
    
    private func respondToTap(at point: CGPoint){
        isRespondingToTap = true
        stopAllObjectAnimations()
        view.bringSubview(toFront: highlightView)
        view.bringSubview(toFront: circle)
        
        flashHighlightedViewForTap()
        animateCircle(at: point)
    }
    
    private func flashHighlightedViewForTap(){
        self.highlightView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.highlightView.alpha = 0.3
        }){ (success) in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.highlightView.alpha = 0
                self.isRespondingToTap = false
            })
            
        }
        
    }
    
    private func animateCircle(at point: CGPoint){
        self.circle.alpha = 0.4
        circle.center = point
        UIView.animate(withDuration: 0.4, animations: {
            
            self.circle.transform = CGAffineTransform(scaleX: self.circleToScale, y: self.circleToScale)
            
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.2, animations: {
            self.circle.alpha = 0
        }, completion: { (success) in
            self.circle.transform = CGAffineTransform.identity
            self.isRespondingToTap = false
        })
    }
    
    
    
    private lazy var circle: MyView = {
        let x = MyView()
        x.alpha = 0
        x.backgroundColor = .lightGray
        x.layer.masksToBounds = true
        x.frame.size = CGSize(width: 1, height: 1)
        x.layoutSubviewsAction = {
            x.layer.cornerRadius = x.frame.width / 2
        }
        return x
    }()
    
    private lazy var highlightView: UIView = {
        let x = UIView()
        x.alpha = 0
        x.backgroundColor = .lightGray
        return x
    }()
    
    
    private func setUpViews(){
        view.addSubview(highlightView)
        view.addSubview(circle)
        
        highlightView.pinAllSidesTo(view)
        
    }
    
    
    
    
    
    
}




class CircleInteractionView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    init(){
        super.init(frame: CGRect.zero)
        setUp()
    }
  
    
    private func setUp(){
        circleInteractor.setUp(with: self)
        circleInteractor.tapAction = self.tapAction
        circleInteractor.longPressAction = self.longPressAction
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        circleInteractor.respondToTouchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        circleInteractor.respondToTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        circleInteractor.respondToTouchesEnded(touches, with: event)
        
    }
    
    private var circleInteractor = CircleInteractor()
    
    var tapAction = {}
    
    var longPressAction = {}
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
}







class CircleInteractionCollectionViewCell: UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(viewToShowInteraction)
        viewToShowInteraction.pinAllSidesTo(self, insets: interactionAreaInsets)
        
        circleInteractor.setUp(with: viewToShowInteraction)
        circleInteractor.circleToScale = 400
    }
    
    
    
    var interactionAreaInsets: UIEdgeInsets{
        return UIEdgeInsets(allInsets: -5)
    }
    
    
    func highLight(){
        circleInteractor.highLight()
    }
    
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        super.bringSubview(toFront: viewToShowInteraction)
    }
    
    override func bringSubview(toFront view: UIView) {
        super.bringSubview(toFront: view)
        super.bringSubview(toFront: viewToShowInteraction)
    }
    
    
    
    private var viewToShowInteraction: UIView = {
        let x = UIView()
        x.layer.cornerRadius = 8
        x.layer.masksToBounds = true
        return x
    }()
    
    private var circleInteractor = CircleInteractor()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        circleInteractor.respondToTouchesBegan(touches, with: event)
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        circleInteractor.respondToTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        circleInteractor.respondToTouchesCancelled(touches, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}




class CircleInteractionTableViewCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundView = nil
        circleInteractor.setUp(with: self)
    }
    
    private var circleInteractor = CircleInteractor()

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected{
                circleInteractor.highLight()
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        circleInteractor.respondToTouchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        circleInteractor.respondToTouchesEnded(touches, with: event)

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        circleInteractor.respondToTouchesCancelled(touches, with: event)

    }
    
    
    
    
    override var backgroundView: UIView?{
        get{ return nil }
        set{ super.backgroundView = nil }
    }
    
    
    override var selectionStyle: UITableViewCellSelectionStyle{
        get{ return .none }
        set{ super.selectionStyle = .none }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}










