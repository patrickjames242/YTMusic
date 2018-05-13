//
//  Extensions.swift
//  MusicApp
//
//  Created by Patrick Hanna on 2/18/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import SafariServices






extension UIColor {
    
    
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat){
        
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
        
    }
    
    
    static var random: UIColor{
        
        let random1 = CGFloat(arc4random_uniform(255))
        let random2 = CGFloat(arc4random_uniform(255))
        let random3 = CGFloat(arc4random_uniform(255))
        
        return UIColor(red: random1, green: random2, blue: random3)
        
        
    }
    
    
    
    
    
    
    
}


extension UserDefaults {
    func set(_ color: UIColor, forKey key: String) {
        set(NSKeyedArchiver.archivedData(withRootObject: color), forKey: key)
    }
    func color(forKey key: String) -> UIColor? {
        guard let data = data(forKey: key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
}



func youtubeURL(from videoID: String) -> URL?{
    
     return URL(string: "https://www.youtube.com/watch?v=\(videoID)")
}



class MySafariViewController: SFSafariViewController{
    
    
    var actionToCompleteUponDismisal: (() -> Void)?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        
        let action = {
            
            if let action1 = self.actionToCompleteUponDismisal{
                action1()
            }
            
            if let action2 = completion{
                action2()
            }
        }
        
        super.dismiss(animated: flag, completion: action)
        
        
    }
    
    
}








extension CGSize {
    
    init(width: CGFloat = 0, height: CGFloat = 0) {
        self.init()
        self.width = width
        self.height = height
    }
    
    
}





extension UIEdgeInsets{
    
    
    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0){
        
        self.init()
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
        
    }
    
    
}







//MARK: - CONVERT DEGREES TO RADIANS
extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


//MARK: - CONVERT UIIMAGE TO DATA
extension UIImage{
    
    func dataRepresentaiton() -> Data?{
        
        if let jpeg = UIImageJPEGRepresentation(self, 1.0){
            return jpeg
    
        } else { return nil }
    }
}

// MARK: - BOOL TOGGLE FUNCTION
extension Bool{
    /// Changes value of the receiver to the opposite of what it currently is.
    mutating func toggle(){
        self = !self
    }
    
    
}

//MARK: - MUSIC VIEW TIME FORMATTING 
extension TimeInterval {
    struct DateComponents {
        
        static func formatterPositional(includeHours: Bool) -> DateComponentsFormatter{
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits =  (includeHours) ? [.hour,.minute,.second] : [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
            
        }
        
    }
    var positionalTime: String {
        
        let bool = self >= 3600
        
        return DateComponents.formatterPositional(includeHours: bool).string(from: self) ?? ""
    }
}


// MARK: - UIVIEW CONVENIENCES VARS

extension CGRect{
    
    
    var centerInFrame: CGPoint{
        
        return CGPoint(x: minX + (width / 2),
                       y: minY + (height / 2))
        
    }
    
    var centerInBounds: CGPoint{
        
        return CGPoint(x: width / 2,
                       y: height / 2)
        
    }
    
    var rightSide: CGFloat {
        get { return self.maxX }
        set { self.origin.x = newValue - self.width }
    }

    var leftSide: CGFloat {
        get { return self.minX }
        set { self.origin.x = newValue }
    }

    var topSide: CGFloat {
        get { return self.minY }
        set { self.origin.y = newValue }
    }

    var bottomSide: CGFloat {
        get { return self.maxY }
        set { self.origin.y = newValue - self.height }
    }
    
}


extension UIView{
    
    var rightSide: CGFloat {
        get { return frame.rightSide }
        set { frame.rightSide = newValue }
    }
    
    var leftSide: CGFloat {
        get { return frame.leftSide }
        set { frame.leftSide = newValue }
    }
    
    var topSide: CGFloat {
        get { return frame.topSide }
        set { frame.topSide = newValue }
    }
    
    var bottomSide: CGFloat {
        get { return frame.bottomSide }
        set { frame.bottomSide = newValue }
    }
    
    
    func pinAllSidesTo(_ viewToPinTo: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: viewToPinTo.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: viewToPinTo.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: viewToPinTo.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: viewToPinTo.bottomAnchor).isActive = true
        
    }
    

    
    func pin(left: NSLayoutXAxisAnchor? = nil,
             right: NSLayoutXAxisAnchor? = nil,
             top: NSLayoutYAxisAnchor? = nil,
             bottom: NSLayoutYAxisAnchor? = nil,
             centerX: NSLayoutXAxisAnchor? = nil,
             centerY: NSLayoutYAxisAnchor? = nil,
             width: NSLayoutDimension? = nil,
             height: NSLayoutDimension? = nil,
             size: CGSize? = nil,
             insets: UIEdgeInsets = UIEdgeInsets.zero){
        
        
        
        translatesAutoresizingMaskIntoConstraints = false
        if let left = left{
            leftAnchor.constraint(equalTo: left, constant: insets.left).isActive = true
        }
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -insets.right).isActive = true
        }
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: insets.top).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -insets.bottom).isActive = true
        }
        if let centerX = centerX{
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY{
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        if let height = height{
            heightAnchor.constraint(equalTo: height).isActive = true
        }
        if let width = width{
            widthAnchor.constraint(equalTo: width).isActive = true
        }
        
        if let size = size {
            
            if size.width != 0{
                widthAnchor.constraint(equalToConstant: size.width).isActive = true
            }
            if size.height != 0{
                heightAnchor.constraint(equalToConstant: size.height).isActive = true
            }
            
        }
        
    }
    
    
    
    var centerInFrame: CGPoint{
        
        return center
    }
    
    var centerInBounds: CGPoint{
        return CGPoint(x: halfOfWidth,
                       y: halfOfHeight)
    }
    
    var halfOfWidth: CGFloat{
        return frame.width / 2
    }
    
    var halfOfHeight: CGFloat{
        return frame.height / 2
    }
    
}


// MARK: - SHUFFLING

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}




extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}















//MARK: - REMOVE WHITE SPACES


extension String{
    
    func removeWhiteSpaces() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
        
    }
    

    
}








//MARK: - YT VIDEO DURATION ALGORITHM EXTENSIONS

extension Character{
    var isNumber: Bool{
        return CharacterSet(charactersIn: String(self)).isSubset(of: CharacterSet.decimalDigits)
    }
    
    var isLetter: Bool{
        return CharacterSet(charactersIn: String(self)).isSubset(of: CharacterSet.letters)
    }
}






//MARK: - SONG ALPHABETIZING ALGORITHM EXTENSION

extension Array {

    var lastItemIndex: Int?{
        if isEmpty{return nil}
        return self.count - 1
    }
}



extension Array where Element: Song{
    
    private func turnIntoDictionary(array:[Song]) -> [String: [Song]]{
        
        let dictionaryToReturn = (Dictionary.init(grouping: array) { (element) -> String in
            
            let songNameToReturn = element.name.uppercased().removeWhiteSpaces()
            
            let firstLetter = String(songNameToReturn[element.name.startIndex])
            let characterSet = CharacterSet(charactersIn: firstLetter)
            
            if characterSet.isSubset(of: CharacterSet.uppercaseLetters){
                return firstLetter
            } else { return "#" }
            
        })
        return dictionaryToReturn
    }
    
    
    func alphabetizeSongs() -> (letters: [String], songs: [[Song]]){
        
        if self.isEmpty{return ([], [])}

        
      

        let dict2 = turnIntoDictionary(array: self).sorted{$0.key < $1.key }
        
        let songArrays = EArray<[Song]>()
        let letterArray = EArray<String>()
        
        for (key, value) in dict2{
            
            let array = value.sorted { $0.name < $1.name }
            
            songArrays.add(array)
            letterArray.add(key)
        }
        
        var songArrays2 = songArrays.elements
        var letterArray2 = letterArray.elements
        
        
        if letterArray2[0] == "#"{
            letterArray2.append(letterArray2.remove(at: 0))
            songArrays2.append(songArrays2.remove(at: 0))
        }
        
        return (letterArray2, songArrays2)
        
    }
}





























