//
//  AudioPanningTableView.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit





class AudioPanningSlider: UISlider{
    
    init(){
        super.init(frame: CGRect.zero)
        
        
        minimumTrackTintColor = COLOR
        maximumTrackTintColor = COLOR
        
        minimumValue = -1
        maximumValue = 1
        
        setValue(UserPreferences.audioPanningPosition, animated: false)
        [leftLine, rightLine, middleLine, RLabel, LLabel].forEach{ addSubview($0)}
        
        leftLine.pin(centerX: leftAnchor, centerY: centerYAnchor)
        rightLine.pin(centerX: rightAnchor, centerY: centerYAnchor)
        middleLine.pin(centerX: centerXAnchor, centerY: centerYAnchor)
        
        
        let labelUpset: CGFloat = 20
        
        RLabel.pin(bottom: centerYAnchor, centerX: rightAnchor, insets: UIEdgeInsets(bottom: labelUpset))
        LLabel.pin(bottom: centerYAnchor, centerX: leftAnchor, insets: UIEdgeInsets(bottom: labelUpset))
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = super.trackRect(forBounds: bounds)
        bounds.size.height = THICKNESS
        return bounds
    }
    
    private let COLOR = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    
    private let THICKNESS: CGFloat = 1
    
    private let smallLineHeight: CGFloat = 8
    
    
    
    private lazy var RLabel: UILabel = {
        let x = UILabel()
        x.text = "R"
        x.font = UIFont.systemFont(ofSize: 14)
        return x
        
    }()
    
    private lazy var LLabel: UILabel = {
        let x = UILabel()
        x.text = "L"
        x.font = UIFont.systemFont(ofSize: 14)
        return x
        
    }()
    
    private lazy var leftLine: UIView = {
        let x = UIView()
        x.backgroundColor = COLOR
        
        x.pin(size: CGSize(width: THICKNESS, height: smallLineHeight))
        
        return x
        
    }()
    
    private lazy var rightLine: UIView = {
        let x = UIView()
        x.backgroundColor = COLOR
        
        x.pin(size: CGSize(width: THICKNESS, height: smallLineHeight))
        
        return x
        
    }()
    
    private lazy var middleLine: UIView = {
        let x = UIView()
        x.backgroundColor = COLOR
        
        x.pin(size: CGSize(width: THICKNESS, height: smallLineHeight))
        
        return x
        
    }()
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}




class AudioPanningTableView: UITableViewController{
    
    
    init(){
        
        
        
        super.init(style: .grouped)
        if UserPreferences.audioPanningIsOn{
            cells.append([self.panningSliderCell])
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
    }
    
    
    func createCell(completion: (UITableViewCell) -> Void) -> UITableViewCell{
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Hellerrr")
        completion(cell)
        return cell
        
        
    }
    
    
    @objc private func respondToSwitchSwitched(sender: UISwitch){
        
        tableView.beginUpdates()
        
        if sender.isOn{
            
            UserPreferences.audioPanningIsOn = true
            cells.insert([panningSliderCell], at: 1)
            tableView.insertSections(IndexSet(integer: 1), with: .fade)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
            
        } else {
            
            UserPreferences.audioPanningIsOn = false
            cells.remove(at: 1)
            tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        
        }

        tableView.endUpdates()
    }
    
    
    private lazy var panningSliderCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "yama")
        
        let slider = AudioPanningSlider()
        
        cell.addSubview(slider)
        
        
        let SLIDER_INSETS: CGFloat = 25
        
        slider.pin(left: cell.leftAnchor, right: cell.rightAnchor, bottom: cell.bottomAnchor, insets: UIEdgeInsets(left: SLIDER_INSETS, bottom: 15, right: SLIDER_INSETS))
        
        
        slider.addTarget(self, action: #selector(respondToSliderSliding(sender:)), for: .valueChanged)

        
        return cell
        
        
    }()
    
    
    @objc private func respondToSliderSliding(sender: UISlider){
        
        UserPreferences.audioPanningPosition = sender.value
        
        
    }
    
    
    
    private lazy var cells = [
        [
            self.createCell(completion: { (cell) in
                cell.textLabel?.text = "Toggle Audio Panning"
                
                toggle.setOn(UserPreferences.audioPanningIsOn, animated: false)
                toggle.onTintColor = THEME_COLOR(asker: self)
                toggle.addTarget(self, action: #selector(respondToSwitchSwitched(sender:)), for: .valueChanged)
                cell.addSubview(toggle)
                toggle.pin(right: cell.rightAnchor, centerY: cell.centerYAnchor, insets: UIEdgeInsets(right: 15))
                
                
                
            })
        ]
        
    ]
    
    private let toggle = UISwitch()

    
    
    override func interfaceColorDidChange(to color: UIColor) {
        toggle.onTintColor = color
    }
    
    
    private var cellFooterStrings = [
    
        
        "When enabled, this allows you to adjust the audio volume balance between left and right channels.",
        nil
        
    ]
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return cellFooterStrings[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cells[indexPath.section][indexPath.row]
        
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section{
            
        case 0: return 50
        case 1: return 100
        default: return 0 
            
        }
        
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
