//
//  ViewController.swift
//  dragSort
//
//  Created by 1720177 on 06/25/2022.
//  Copyright (c) 2022 1720177. All rights reserved.
//

import UIKit
import dragSort

class ViewController: UIViewController {
  
    //
    var itemHeaders:[String]!
    var items: [[AnyHashable]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        itemHeaders = ["显示在首页","可添加的卡片"]
        let item01 = ["name":"01","value":"01"]
        let item02 = ["name":"02","value":"02"]
        let item03 = ["name":"03","value":"03"]
        
        let item01Data = try! JSONSerialization.data(withJSONObject: item01, options: .prettyPrinted)
        let item01Str = String(data: item01Data, encoding: .utf8)
        
        let item02Data = try! JSONSerialization.data(withJSONObject: item02, options: .prettyPrinted)
        let item02Str = String(data: item02Data, encoding: .utf8)
        
        let item03Data = try! JSONSerialization.data(withJSONObject: item03, options: .prettyPrinted)
        let item03Str = String(data: item03Data, encoding: .utf8)
        
        items = [[item01Str,item02Str],[item03Str]]
        view.addSubview(collection)
        collection.dataSourceItems(items, itemHeaders)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    lazy var  collection:CustomCollectionView = {
        let view = CustomCollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        view.cDelegate = self
        view.cDataSource = self
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var flowLayout: UICollectionViewLayout = {
        let width: CGFloat = self.view.frame.width
        let height: CGFloat = width
         let flowLayout = UICollectionViewFlowLayout()
       // flowLayout.scrollDirection = .vertical
       // flowLayout.minimumInteritemSpacing = 10
        //滚动方向
       // flowLayout.scrollDirection = .vertical
        //网格中各行项目之间使用的最小间距
        flowLayout.minimumLineSpacing = 10
        //在同一行中的项目之间使用的最小间距
        flowLayout.minimumInteritemSpacing = 0
        //用于单元格的默认大小
        flowLayout.itemSize = CGSize.init(width: width, height: 50)
        //用于标题的默认大小
        flowLayout.headerReferenceSize = CGSize.init(width: self.view.frame.width, height: 50)
        return flowLayout
    }()
}

extension ViewController : CustomViewDataSource,CustomViewDelegate {
    
    func dragCollectionCell(_ collection: UICollectionView, newArrayAfterMove: [AnyHashable]?) {
        NSLog("==after ==", newArrayAfterMove ?? [])
        items = newArrayAfterMove as? [[AnyHashable]]
        (collection as! CustomCollectionView).items = items
    }
    
    func dataSourceOfCollectionView(_ collection: CustomCollectionView, indexPath: IndexPath) -> [AnyHashable] {
        return (items)
    }
    
    func dragCollectionCellExchange(_ collection: UICollectionView, moveCellFromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
    }
}
