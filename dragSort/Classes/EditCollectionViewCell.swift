//
//  EditCollectionViewCell.swift
//  CustomUICollection
//
//  Created by ls on 2018/5/8.
//  Copyright © 2018年 ls. All rights reserved.
//

import UIKit
import Reusable

public protocol EditCollectionViewCellDelegate {
    func selectedCurrentCell(cell:EditCollectionViewCell,isAdd:Bool)
}

open class EditCollectionViewCell: UICollectionViewCell,Reusable {
  
     var delegate:EditCollectionViewCellDelegate!
    
    var isAddAction = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(image)
        bgView.addSubview(label)
        bgView.addSubview(accessBtn)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
        image.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(image.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }
        accessBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
   open  func dataSource(icon:String,text:String,isAdd:Bool = true) {
        isAddAction = isAdd
        image.image = UIImage.init(named: icon)
        label.text = text
        accessBtn.setImage(UIImage(named: isAdd ? "添加" : "移除"), for: .normal)
        accessBtn.addTarget(self, action: #selector(showAccessAction), for: .touchUpInside)
    }
    
    @objc
    func showAccessAction() {
        delegate?.selectedCurrentCell(cell: self,isAdd: isAddAction)
    }
    // 背景
    lazy var bgView:UIView = {
       let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    // icon
    lazy var image:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    // 标题
    lazy var label:UILabel = {
       let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        view.textAlignment = .left
        return view
    }()
    
    //
    lazy var accessBtn:UIButton = {
        let view = UIButton()
        return view
    }()
}
