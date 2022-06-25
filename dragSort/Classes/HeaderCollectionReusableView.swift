//
//  HeaderCollectionReusableView.swift
//  CustomUICollection
//
//  Created by ls on 2018/5/8.
//  Copyright © 2018年 ls. All rights reserved.
//

import UIKit
import Reusable
import SnapKit

open class HeaderCollectionReusableView: UICollectionReusableView,Reusable {
    
    var lineColor:UIColor!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
         addSubview(lineView)
         addSubview(label)
        addSubview(warnLabel)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        warnLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        layoutIfNeeded()
    }
    
    func dataSource(text:String,ishidden:Bool = false,color:UIColor = UIColor(red: 54, green: 134, blue: 255, alpha: 1)) {
        label.text = text
        warnLabel.isHidden = ishidden
        lineColor = color
    }
    
    open override func layoutSubviews() {
        let frame = lineView.frame
         if frame.equalTo(CGRect.zero) == false {
             let bgLayer = CALayer()
             bgLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
             bgLayer.backgroundColor = lineColor.cgColor
             lineView.layer.addSublayer(bgLayer)
        }
    }
    
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.setAffineTransform(CGAffineTransform(rotationAngle: -90))
        return view
    }()
    
    lazy var label:UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 94, green: 94, blue: 94, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        return view
    }()
    
    lazy var warnLabel:UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 153, green: 153, blue: 153, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        view.text = "按住拖动可调整顺序"
        return view
    }()
}
