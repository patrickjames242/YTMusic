//
//  MenuBar.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit





protocol MenuBarDelegate: class {
    
    func userDidSelectItemIndex(of index: Int)
    
    
}




class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    weak var delegate: MenuBarDelegate?
    
    init(items: [String]){
        self.items = items
        super.init(frame: CGRect.zero)
        
        setUpViews()
        
        if !items.isEmpty{
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
    }
    
    
    
    
    
    
    
    
    
    private var items: [String]
    private let cellID = "The Best Cell Ever"
    
    
    private lazy var scrollBar: ScrollBar = {
        let x = ScrollBar(numberOfItems: items.count)
        return x
    }()
    
    
    
    
    /// This function receives the offset of the visible view from the beginning of the scrollable content, expressed as a percentage of the total scrollable content size.
    
    func userDidScrollBy(point: Double){
        
        scrollBar.scrollTo(point: point)
        
    }
    
    
    
    func selectItem(index: Int, animated: Bool){
        
        
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .left)
        
        scrollBar.pageTo(index: index, animated: animated)
        
        
    }
    
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let x = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        x.backgroundColor = .clear
        x.register(MenuBarCell.self, forCellWithReuseIdentifier: cellID)
        x.dataSource = self
        x.delegate = self
        return x
        
        
    }()
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuBarCell
        cell.setText(to: items[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionViewSize.width / CGFloat(items.count), height: collectionViewSize.height)
        
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollBar.pageTo(index: indexPath.item, animated: true)
        delegate?.userDidSelectItemIndex(of: indexPath.item)
    }
    
    private var collectionViewSize: CGSize{
        layoutIfNeeded()
        
        return CGSize(width: frame.width, height: frame.height)
        
    }
    
    
    private func setUpViews(){
        
        addSubview(collectionView)
        addSubview(scrollBar)
        collectionView.pin(left: leftAnchor, right: rightAnchor, top: topAnchor, bottom: bottomAnchor)
        
        scrollBar.pin(left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, size: CGSize(height: 3))
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Why are you using this init for 'Menu Bar!!!'")
    }
    
}




class MenuBarCell: UICollectionViewCell{
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    
    func setText(to text: String){
        self.label.text = text
        
        
    }
    
    override var isHighlighted: Bool{
        didSet{
            label.textColor = isHighlighted ? .red : .lightGray
        }
    }
    
    
    override var isSelected: Bool{
        didSet{
            label.textColor = isSelected ? .red : .lightGray
            
        }
    }
    
    
    private var label: UILabel = {
        let x = UILabel()
        x.textColor = .lightGray
        x.font = UIFont.systemFont(ofSize: 18)
        return x
        
    }()
    
    
    
    private func setUpViews(){
        
        
        addSubview(label)
        label.pin(centerX: centerXAnchor, centerY: centerYAnchor)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}

















