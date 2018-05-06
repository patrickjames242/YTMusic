//
//  CustomAnchorExperimentation.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/22/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


fileprivate class ViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let origininalViewFrame = view.frame
        view = CUIView(frame: origininalViewFrame)
        
        view.backgroundColor = .red
        view.addSubview(someView)
        view.addSubview(anotherView)
        positionViews()
        
    }
    
    var theView: CUIView{
        return view as! CUIView
    }
    
    func positionViews(){
        someView.heightConstant.position(equalToConstant: 50)
        someView.widthConstant.position(equalToConstant: 50)
        someView.centerFrameXPosition.position(equalTo: theView.centerBoundsXPosition, constant: 0)
        someView.centerFrameYPosition.position(equalTo: theView.centerBoundsYPosition, constant: 40)
        
        anotherView.topFrameEdge.position(equalTo: someView.bottomFrameEdge, constant: 30)
        anotherView.centerFrameXPosition.position(equalTo: someView.centerFrameXPosition)
        anotherView.widthConstant.position(equalToConstant: 90)
        anotherView.heightConstant.position(equalToConstant: 90)
        
    }
    
    lazy var someView: CUIView = {
       let x = CUIView()
        x.backgroundColor = .white
        return x
    
    }()
    
    lazy var anotherView: CUIView = {
        let x = CUIView()
        x.backgroundColor = .white
        return x
    }()
    
    
}





final fileprivate class PositionAnchor{
    
    private var viewToObserve: UIView?
    private var viewIAmOwnedBy: UIView
    private var viewsObservingMe = [UIView]()
    
    
    
    private var dimension_ofViewIAmOwnedBy: CGFloat
    private var dimension_ofViewToObserve: CGFloat?
    
    private var constant: CGFloat = 0
    
    
    private var myChangedDimension: CGFloat{
        return dimension_ofViewIAmOwnedBy + constant
    }
    
    
    

    
    
    
    init(viewIAmOwnedBy: UIView, associatedDimension: CGFloat) {
        self.viewIAmOwnedBy = viewIAmOwnedBy
        self.dimension_ofViewIAmOwnedBy = associatedDimension
    }
    
    // Whenever the view that owns this anchor changes its frame, this function is called
    fileprivate func myPositionDidChange(to dimension: CGFloat){
        
        for view in viewsObservingMe{
            
            if let view = view as? CUIView {
                view.aViewIObserveDidChange(sender: self, to: myChangedDimension)
            }
            if let view = view as? CUIButton {
                view.aViewIObserveDidChange(sender: self, to: myChangedDimension)
            }
        }
    }
    
    
    // this function is to be called by the user of the api
    func position(equalTo anchor: PositionAnchor, constant: CGFloat = 0){
        
        self.viewToObserve = anchor.viewIAmOwnedBy
        self.constant = constant
        self.dimension_ofViewToObserve = anchor.dimension_ofViewIAmOwnedBy
        (self.viewIAmOwnedBy as! CUIView).aViewIObserveDidChange(sender: self, to: dimension_ofViewToObserve! + constant)
        anchor.viewsObservingMe.append(self.viewIAmOwnedBy)
    
    }
    // this function is to be called by the user of the api

    func position(equalToConstant constant: CGFloat){
        
        self.constant = constant
        (self.viewIAmOwnedBy as! CUIView).aViewIObserveDidChange(sender: self, to: myChangedDimension)
    }
    
}





fileprivate class CUIButton: UIButton{
    
    fileprivate func aViewIObserveDidChange(sender: PositionAnchor, to dimension: CGFloat) {
        
    }
    
}





fileprivate class CUIView: UIView{
    
    override var frame: CGRect{
        
        get { return super.frame }
        
        set { super.frame = newValue
              setFramePositionAnchors()
        }
        
    }
    
    override var bounds: CGRect{
        
        get{ return super.bounds }
        set{ super.bounds = newValue
             setBoundsPositionAnchors()
        }
    }
    
    private func setFramePositionAnchors(){
        topFrameEdge.myPositionDidChange(to: frame.minY)
        bottomFrameEdge.myPositionDidChange(to: frame.maxX)
        leftFrameEdge.myPositionDidChange(to: frame.minX)
        rightFrameEdge.myPositionDidChange(to: frame.maxX)
        
        setSizePositionAnchors()
    }
    
    
    
    private func setBoundsPositionAnchors(){
        topBoundsEdge.myPositionDidChange(to: bounds.minY)
        bottomBoundsEdge.myPositionDidChange(to: bounds.maxX)
        leftBoundsEdge.myPositionDidChange(to: bounds.minX)
        rightBoundsEdge.myPositionDidChange(to: bounds.maxX)
        
        setSizePositionAnchors()
    }
    
    private func setSizePositionAnchors(){
        heightConstant.myPositionDidChange(to: frame.width)
        widthConstant.myPositionDidChange(to: frame.height)
    }
    
    
    fileprivate func aViewIObserveDidChange(sender: PositionAnchor, to dimension: CGFloat) {
        if sender === topFrameEdge{
            
            // imagine the view is being pushed up because of the anchor
            let difference = frame.topSide - dimension
            frame.size.height += difference
            frame.topSide = dimension
            
        }
        else if sender === bottomFrameEdge{
            
            // imagine the view is being pushed up because of the anchor
            let difference = frame.bottomSide - dimension
            frame.size.height -= difference
            frame.bottomSide = dimension
            
        }
        else if sender === leftFrameEdge{
            
            //imagine the view is being pushed to the left
            let difference = frame.leftSide - dimension
            frame.size.width += difference
            frame.leftSide = dimension
        }
        else if sender === rightFrameEdge{
            
            //imagine the view is being pushed to the right
            let difference = dimension - frame.rightSide
            frame.size.width += difference
            frame.rightSide = dimension
            
        }
        
        
        
        else if sender === topBoundsEdge{
            print("the topBounds edge was pinned to something... weird 🤔")
        }
        else if sender === bottomBoundsEdge{
            print("the bottomBounds edge was pinned to something... weird 🤔")

        }
        else if sender === leftBoundsEdge{
            print("the leftBounds edge was pinned to something... weird 🤔")

        }
        else if sender === rightBoundsEdge{
            print("the rightBounds edge was pinned to something... weird 🤔")

        }
        
        
        else if sender === centerFrameXPosition{
            center.x = dimension
        }
        else if sender === centerFrameYPosition{
            center.y = dimension
        }
        else if sender === centerBoundsXPosition{
            print("the centerBoundsYPosition was pinned to something... weird 🤔")
        }
        else if sender === centerBoundsYPosition{
            print("the centerBoundsYPosition was pinned to something... weird 🤔")
        }
        
        
        else if sender === heightConstant{
            frame.size.height = dimension
        }
        else if sender === widthConstant{
            frame.size.width = dimension
        }
    }

    
    lazy var topFrameEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: frame.minY)
    
    lazy var bottomFrameEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: frame.maxY)
    
    lazy var leftFrameEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: frame.minX)
    
    lazy var rightFrameEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: frame.maxX)
    
    
    
    
    
    lazy var topBoundsEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: bounds.minY)
    
    lazy var bottomBoundsEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: bounds.maxY)
    
    lazy var leftBoundsEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: bounds.minX)
    
    lazy var rightBoundsEdge = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: bounds.maxX)
    
    
    
    
    lazy var centerBoundsXPosition = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: centerInBounds.x)
    
    lazy var centerBoundsYPosition = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: centerInBounds.y)
    
    lazy var centerFrameXPosition = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: center.x)
    
    lazy var centerFrameYPosition = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: center.y)
    
    
    
    
    lazy var heightConstant = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: self.frame.height)
    
    lazy var widthConstant = PositionAnchor(viewIAmOwnedBy: self, associatedDimension: self.frame.width)
    
    
    
    

    
    
    
}


















