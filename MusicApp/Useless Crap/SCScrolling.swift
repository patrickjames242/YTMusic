////
////  SCScrolling.swift
////  MusicApp
////
////  Created by Patrick Hanna on 3/26/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import UIKit
//
//
//@objc protocol SCScrollableController{
//    
//    @objc optional func userDidStartSrollingAway()
//    @objc optional func userDidFinishScrollingAway()
//    
//    @objc optional func userDidStartScrollingTowards()
//    @objc optional func userDidFinishScrollingTowards()
//    
//    var view: UIView { get }
//    
//}
//
//
//
//class Stack<x>{
//    
//    init(items: [x]) {
//        storage.append(contentsOf: items)
//    }
//    
//    init(){
//        
//    }
//    
//    private var storage = [x]()
//    
//    func push(_ item: x){
//        storage.append(item)
//    }
//    
//    func popAndReturn() -> x?{
//        
//        return storage.popLast()
//        
//    }
//    func accessViewToPop() -> x?{
//        return storage.first
//    }
// 
//    func forEach(_ closure: (x) -> Void){
//        
//        for element in storage{
//            closure(element)
//        }
//        
//    }
//    
//    
//}
//
//
//
//
//
//
//
//class SCScrollView: UIView{
//    
//    private var inBetweenSpace: CGFloat = 50
//    private let heldViews: [UIView]
//    private let holderViews: [UIView]
//    
//    // these are the positions of the x value of the wide view in order for the corresponding holder view to be compeletely on screen.
//    private var holderPositions = [UIView: CGFloat]()
//    
//    
//    
//    
//    
//    init(frame: CGRect, views: [UIView]){
//        self.heldViews = views
//        var holderViews = [UIView]()
//        
//        for _ in views{
//            let newHolderView = UIView()
//            holderViews.append(newHolderView)
//            
//            
//        }
//        
//        self.holderViews = holderViews
//        var z = holderViews.count - 1
//        for holderView in holderViews.reversed(){
//            if z != 0{ rightViewsStack.push(holderView)}
//          z -= 1
//        }
//        
//        super.init(frame: frame)
//
//
//        addSubview(wideView)
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(respondToPanGestureRecognizer(sender:)))
//        
//        addGestureRecognizer(gestureRecognizer)
//        
//    }
//
//    
//    private var leftViewsStack = Stack<UIView>()
//    private lazy var currentlyVisibleView = holderViews[0]
//    private var rightViewsStack = Stack<UIView>()
//    
//    
//    
//    
//    
//    private var swipeAcceptanceThreshhold: CGFloat = 60
//    
//    private var totalCurrentSwipeDistance: CGFloat = 0
//    
//    @objc func respondToPanGestureRecognizer(sender: UIPanGestureRecognizer){
//        
//        let xTranslation = (sender.translation(in: self).x * 1.6)
//        totalCurrentSwipeDistance += xTranslation
//        
//        let minimumValue: CGFloat = 0 - (wideView.frame.width - frame.width)
//        let maximumValue: CGFloat = 0
//        
//        wideView.frame.origin.x = max(minimumValue, min(wideView.frame.origin.x + xTranslation, maximumValue))
//        
//        
//        switch sender.state{
//            
//        case .ended:
//            let velocity = sender.velocity(in: self).x
//            print(velocity)
//            if totalCurrentSwipeDistance > swipeAcceptanceThreshhold{
//                if let leftView = leftViewsStack.popAndReturn(){
//                    pullRestOfViewOnScreen(holderView: leftView, velocity: velocity)
//                    
//                    rightViewsStack.push(currentlyVisibleView)
//                    currentlyVisibleView = leftView
//                } else {
//                    pullRestOfViewOnScreen(holderView: currentlyVisibleView, velocity: velocity)
//                }
//            } else if totalCurrentSwipeDistance < -swipeAcceptanceThreshhold{
//                if let rightView = rightViewsStack.popAndReturn(){
//                    pullRestOfViewOnScreen(holderView: rightView, velocity: velocity)
//                    
//                    leftViewsStack.push(currentlyVisibleView)
//                    currentlyVisibleView = rightView
//                } else {
//                    pullRestOfViewOnScreen(holderView: currentlyVisibleView, velocity: velocity)
//                }
//            } else {
//                pullRestOfViewOnScreen(holderView: currentlyVisibleView, velocity: velocity)
//            }
//            
//            
//            
//            totalCurrentSwipeDistance = 0
//        default: break
//            
//        }
//        
//        sender.setTranslation(CGPoint.zero, in: self)
//    }
//    
//    
//    enum Side{case left, right}
//    
//    
//    class ViewResizingHandler{
//        
//        private static var leftView: UIView?
//        private static var currentView = UIView()
//        private static var rightView: UIView?
//        private static var chosenSmallestScale: CGFloat = 0.5
//        
//        private static var amountUserHasSwipedTowardsRight: CGFloat = 0
//        private static var amountUserHasSwipedTowardsLeft: CGFloat = 0
//        private static var parent: SCScrollView!
//        
//        
//        static func scrollingDidOccurWith(left: UIView?, current: UIView, right: UIView?, userIsSwipingTowards side: Side, translation: CGFloat, parent: SCScrollView){
//            
//            self.parent = parent
//            
//            self.leftView = left
//            self.currentView = current
//            self.rightView = right
//            
//            if wideViewXVal > currentViewZeroPosition{
//                
//                
//                
//                
//                
//                
//            }
//            
//            
//        }
//        
//        static func endScrollingSessionWith(chosenView: UIView){
//            
//            parent.leftViewsStack.forEach { (view) in
//                view.subviews[0].transform = CGAffineTransform(scaleX: chosenSmallestScale, y: chosenSmallestScale)
//                view.subviews[0].center.y = view.centerInFrame.y
//                view.subviews[0].rightSide = parent.frame.width
//            }
//            
//        }
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        
//    }
//    
//    
//    
//    
//
//    
//    
//    
//    private func pullRestOfViewOnScreen(holderView: UIView, velocity: CGFloat){
//        let velocity = abs(velocity)
//        let currentHolderViewPosition = wideView.frame.minX
//        
//        let distanceAwayFromFullPosition = abs(currentHolderViewPosition - holderPositions[holderView]!)
//
//        let time: Double = Double(distanceAwayFromFullPosition / velocity)
//        let time2 = max(0.1, min(0.5, time))
//        
//        UIView.animate(withDuration: time2) {
//            self.wideView.frame.origin.x = self.holderPositions[holderView]!
//        }
//        
//        
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    private lazy var wideView: UIView = {
//        
//        
//        var newFrame = frame
//        newFrame.size.width = (frame.width * CGFloat(heldViews.count)) + (CGFloat(heldViews.count - 1) * inBetweenSpace)
//        
//        let x = UIView(frame: newFrame)
//        
//        var newViewPlacement: CGFloat = 0
//        var y = 0
//        for heldView in heldViews{
//            
//            let correspondingHolderView = holderViews[y]
//            
//            correspondingHolderView.frame = CGRect(x: newViewPlacement, y: 0, width: frame.width, height: frame.height)
//            x.addSubview(correspondingHolderView)
//            correspondingHolderView.addSubview(heldView)
//            
//            heldView.frame = frame
//            holderPositions[correspondingHolderView] = -newViewPlacement
//            newViewPlacement += (frame.width + inBetweenSpace)
//            
//            y += 1
//        }
//        
//        return x
//    }()
//    
//    
//    
//    
//    
//    
//    
//
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    override init(frame: CGRect) {
//        fatalError("Don't use this init to instantiate SCScrollView")
//    }
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("why you using this!!")
//    }
//}
//
//
//class SCScrollViewPlayGroundViewController: UIViewController{
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        var views = [UIView]()
//        
//        for _ in 1...4{
//            let newView = UIView()
//            newView.backgroundColor = .red
//            views.append(newView)
//        }
//        
//        let scrollView = SCScrollView(frame: view.bounds, views: views)
//        view.addSubview(scrollView)
//        
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
