//
//  ColorChooserView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/14/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class ColorPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .white
        additionalSafeAreaInsets.bottom = AppManager.currentAppBottomInset
        setUpViews()
        
    }
    
    
    private var colors: [(color: UIColor, name: String)] = [
        
        (.red, "Red"),
        (.black, "Black"),
        (.orange, "Orange"),
        (.blue, "Blue"),
        (.brown, "Brown"),
        (.cyan, "Cyan"),
        (.green, "Green"),
        (.purple, "Purple"),
        (.magenta, "Magenta"),
        (.yellow, "Yellow"),
        (.gray, "Gray")
        
    ]
    
    
    
    
    private lazy var picker: UIPickerView = {
        let x = UIPickerView()
        x.dataSource = self
        x.delegate = self
        for (num, item) in colors.enumerated(){
            
            if item.color == DBColor.currentAppThemeColor{
                x.selectRow(num, inComponent: 0, animated: false)
            }
            
        }
        
        
        return x
    }()
    
    
    private func setUpViews(){
        
        view.addSubview(picker)
        picker.pin(centerX: view.safeAreaLayoutGuide.centerXAnchor, centerY: view.safeAreaLayoutGuide.centerYAnchor, size: CGSize(height: 375))
        
        
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
 
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DBColor.currentAppThemeColor = colors[row].color
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let viewToReturn: ColorPickerCell
        
        if let pickerView = view as? ColorPickerCell{ viewToReturn = pickerView }
        else { viewToReturn = ColorPickerCell() }
        
        viewToReturn.setWithColor(colors[row])
        
        return viewToReturn

    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 43
    }
    
    
    
    
}


fileprivate class ColorPickerCell: UIView {
    
    init(){
        super.init(frame: CGRect.zero)
        
        setUpViews()
        
        
    }
    
    func setWithColor(_ colorTuple: (color: UIColor, name: String)){
        
        circle.backgroundColor = colorTuple.color
        label.text = colorTuple.name
        
    }
    
    
    private lazy var circle: UIView = {
        let view = MyView()
        view.layer.masksToBounds = true
        view.layoutSubviewsAction = {
            view.layer.cornerRadius = min(view.frame.height, view.frame.width) / 2
        }
        return view
    }()
    
    private lazy var label: UILabel = {
        let x = UILabel()
        
        return x
        
    }()
    
    
    
    
    
    
    
    private func setUpViews(){
        
        
        let LEFT_OFFSET: CGFloat = 8
        
        [circle, label].forEach{addSubview($0)}
        circle.pin(right: centerXAnchor, centerY: centerYAnchor, size: CGSize(width: 30, height: 30), insets: UIEdgeInsets(right: 10 + LEFT_OFFSET))
        label.pin(left: circle.rightAnchor, centerY: centerYAnchor, insets: UIEdgeInsets(left: 20))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}








