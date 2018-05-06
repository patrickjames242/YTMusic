////
////  Play_ShuffleView.swift
////  MusicApp
////
////  Created by Patrick Hanna on 2/25/18.
////  Copyright © 2018 Patrick Hanna. All rights reserved.
////
//
//import UIKit
//
//
//
//class Play_ShuffleView: UIView{
//
//    override init(frame: CGRect) {
//        super.init(frame: CGRect(x: 0,
//                                 y: frame.minY,
//                                 width: frame.width,
//                                 height: 80))
//
//
//    }
//
//    override func didMoveToSuperview() {
//        addSubview(leftButtonView)
//        addSubview(rightButtonView)
//
//        leftButtonView.addSubview(leftButtonStackView)
//        rightButtonView.addSubview(rightButtonStackView)
//        addSubview(bottomLine)
//        setAllConstraints()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//
//    func setColor(){
//        leftButtonView.backgroundColor = backGroundColor
//        rightButtonView.backgroundColor = backGroundColor
//
//        rightButtonLabel.textColor = secondaryColor
//        rightButtonImageView.tintColor = secondaryColor
//        leftButtonLabel.textColor = secondaryColor
//        leftButtonImageView.tintColor = secondaryColor
//
//    }
//
//    private var backGroundColor: UIColor{
//        return AppManager.currentBackgroundColor
//    }
//
//    private var secondaryColor: UIColor{
//        return UserPreferences.adaptiveColorIsOn ? AppManager.currentSecondaryColor  : AppManager.currentPrimaryColor
//    }
//
//
//    var leftInset: CGFloat = 17
//    var rightInset: CGFloat = 20
//
//
//    private var middleSpaceLength: CGFloat = 15
//
//
//
//
//
//
//
//    private lazy var leftButtonView: UIView = {
//        let x = UIView()
//        x.translatesAutoresizingMaskIntoConstraints = false
//        x.backgroundColor = backGroundColor
//        x.layer.cornerRadius = 10
//        x.layer.masksToBounds = true
//        return x
//    }()
//
//    private lazy var leftButtonStackView: UIStackView = {
//       let x = UIStackView(arrangedSubviews: [leftButtonImageView, leftButtonLabel])
//        x.axis = .horizontal
//        x.spacing = 5
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//
//    private lazy var leftButtonImageView: UIImageView = {
//        let x = UIImageView(image: #imageLiteral(resourceName: "sharpplay").withRenderingMode(.alwaysTemplate))
//        x.tintColor = secondaryColor
//        x.contentMode = .scaleAspectFit
//
//        return x
//    }()
//
//    private lazy var leftButtonLabel: UILabel = {
//        let x = UILabel()
//        x.text = "Play"
//        x.font = UIFont.boldSystemFont(ofSize: 16)
//        x.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        x.textColor = secondaryColor
//        return x
//    }()
//
//
//
//    private lazy var rightButtonView: UIView = {
//        let x = UIView()
//        x.translatesAutoresizingMaskIntoConstraints = false
//        x.backgroundColor = backGroundColor
//        x.layer.cornerRadius = 10
//        x.layer.masksToBounds = true
//        return x
//    }()
//
//    private lazy var rightButtonStackView: UIStackView = {
//        let x = UIStackView(arrangedSubviews: [rightButtonImageView, rightButtonLabel])
//        x.axis = .horizontal
//        x.spacing = 5
//        x.translatesAutoresizingMaskIntoConstraints = false
//        return x
//    }()
//
//    private lazy var rightButtonImageView: UIImageView = {
//        let x = UIImageView(image: #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate))
//        x.tintColor = secondaryColor
//        x.tintColor = self.secondaryColor
//        x.contentMode = .scaleAspectFit
//        return x
//    }()
//
//    private lazy var rightButtonLabel: UILabel = {
//        let x = UILabel()
//        x.text = "Shuffle"
//        x.font = UIFont.boldSystemFont(ofSize: 16)
//        x.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//        x.textColor = secondaryColor
//        return x
//    }()
//
//
//
//
//
//
//    private lazy var bottomLine: UIView = {
//       let x = UIView()
//        x.backgroundColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1)
//        x.translatesAutoresizingMaskIntoConstraints = false
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
//    private func setAllConstraints(){
//
//        let distanceBetweenButtons: CGFloat = 15
//
//        let buttonWidth: CGFloat = (frame.width - leftInset - rightInset - distanceBetweenButtons) / 2
//
//
//        leftButtonView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        leftButtonView.leftAnchor.constraint(equalTo: leftAnchor, constant: leftInset).isActive = true
//        leftButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        leftButtonView.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
//
//
//        rightButtonView.leftAnchor.constraint(equalTo: leftButtonView.rightAnchor, constant: distanceBetweenButtons).isActive = true
//        rightButtonView.heightAnchor.constraint(equalTo: leftButtonView.heightAnchor).isActive = true
//        rightButtonView.centerYAnchor.constraint(equalTo: leftButtonView.centerYAnchor).isActive = true
//        rightButtonView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
//
//
//
//        leftButtonStackView.centerXAnchor.constraint(equalTo: leftButtonView.centerXAnchor).isActive = true
//        leftButtonStackView.centerYAnchor.constraint(equalTo: leftButtonView.centerYAnchor).isActive = true
//
//
//        rightButtonStackView.centerXAnchor.constraint(equalTo: rightButtonView.centerXAnchor).isActive = true
//        rightButtonStackView.centerYAnchor.constraint(equalTo: rightButtonView.centerYAnchor).isActive = true
//
//
//        leftButtonImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        leftButtonImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
//
//        rightButtonImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        leftButtonImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
//
//        bottomLine.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
//        bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        bottomLine.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -rightInset).isActive = true
//        bottomLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftInset).isActive = true
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
//}

