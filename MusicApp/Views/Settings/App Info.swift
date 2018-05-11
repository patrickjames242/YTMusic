//
//  App Info.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit



class AppInfoTableView: UITableViewController{


    init(){
        super.init(style: .grouped)
        
        navigationItem.largeTitleDisplayMode = .never
        
    }




    override func viewDidLoad() {
        super.viewDidLoad()

        initiateStatistics()

    }

    
    private func initiateStatistics(){
        
        countCell.setInfoText(to: String(Song.count()))
        
//        Song.getNumberOfBytes { (int) in
//            print(int)
//            let string = self.convertBytesToString(int: int)
//            self.memoryCell.setInfoText(to: string)
//        }
        
    }
    
    
    private func convertBytesToString(int: Int) -> String{
        
        
        
        if int < 1000000{
            return String(format: "%.1f", int / 1000) + " KB"
        } else if int < 1000000000 {
            return String(format: "%.1f", int / 1000000) + " MB"
        } else {
            return String(format: "%.1f", int / 1000000000 ) + " GB"
        }
        
        
    }
    

    
    

    private let countCell = AppInfoTableViewCell(text: "Number Of Songs")
    private let memoryCell = AppInfoTableViewCell(text: "Total Song Storage")
    
    
    private lazy var cells: [[UITableViewCell]] = [
        [
            self.countCell,
            self.memoryCell,
        ],
        [
            MiddleBlueTextCell(text: "Purge Through All Songs")
        ],
        
        [
            MiddleBlueTextCell(text: "Delete All Songs")
            
        ]
        
    ]
    
    private let cellFooterStrings = [
        nil,
        "Select multiple songs, and delete them all at the same time.",
        "This deletes ALL songs currently in your library. Be warned that deleted songs cannot be recovered."
        
    ]
    
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return cellFooterStrings[section]
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cells[indexPath.section][indexPath.row]

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }





    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }






    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}











fileprivate class AppInfoTableViewCell: UITableViewCell{
    
    
    init(text: String){
        super.init(style: .default, reuseIdentifier: "blah blah blah")
        textLabel?.text = text
        selectionStyle = .none
        setUpViews()
        
    }
    
    
    
    
    func setInfoText(to text: String){
        
        self.infoLabel.text = text
        
    }
    
    private lazy var infoLabel: UILabel = {
        let x = UILabel()
        
        x.text = "Calculating..."
        x.textColor = .lightGray
        return x
    }()
    
    
    private func setUpViews(){
        addSubview(infoLabel)
        let INSET: CGFloat = 15
        
        infoLabel.pin(right: rightAnchor,centerY: centerYAnchor, insets: UIEdgeInsets(right: INSET))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
}










class MiddleBlueTextCell: UITableViewCell{
    
    init(text: String){
        
        super.init(style: .default, reuseIdentifier: "alskdfja;sdkj")
        
        middleTextLabel.text = text
        addSubview(middleTextLabel)
        middleTextLabel.pin(centerX: centerXAnchor, centerY: centerYAnchor)
    }
    
    

    
    private lazy var middleTextLabel: UILabel = {
        let x = UILabel()
        
//        x.textColor = UIColor(red: 0, green: 122, blue: 255)
        x.textColor = THEME_COLOR
        return x
        
        
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}



















