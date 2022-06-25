//
//  CustomCollectionView.swift
//  Y1
//
//  Created by 李朋 on 2022/6/15.
//

import Foundation
import UIKit
import Reusable

@objc public protocol CustomViewDelegate {
// 当数据源更新到目标位置调用,需要将新的数据源设置为当前的数据源
func dragCollectionCell(_ collection:UICollectionView,newArrayAfterMove:[AnyHashable]?)

// 移动完毕,并成功移动到新位置的时候调用
@objc optional func dragCollectionCellEndMoving(_ collection:UICollectionView)
// 交换位置
@objc optional func dragCollectionCellExchange(_ collection:UICollectionView,moveCellFromIndexPath:IndexPath,toIndexPath:IndexPath)
// 长按手势结束时是否删除当天拖动的单元格
 @objc optional func collectionCellShouldDeleteCurrentMoveItem(_ collection:UICollectionView,gestureRecognier:UILongPressGestureRecognizer,indexPath:IndexPath) -> Bool
// 长按手势发生改变时调用
 @objc optional func collectionViewChange(_ collectionView:UICollectionView,gestureRecognier:UILongPressGestureRecognizer,indexPath:IndexPath)
 // 长按手势开始时调用
 @objc optional func collectionViewBegin(_ collectionView:UICollectionView,gestureRecognier:UILongPressGestureRecognizer,indexPath:IndexPath)
 // 长按手势结束时调用
 @objc optional func collectionViewEnd(_ collectionView:UICollectionView,gestureRecognier:UILongPressGestureRecognizer,indexPath:IndexPath)
}

@objc public protocol CustomViewDataSource {
    // 返回整个CollectionView数据,需根据数据重排
    func dataSourceOfCollectionView(_ collection:CustomCollectionView,indexPath:IndexPath) -> [AnyHashable]
}

open class CustomCollectionView : UICollectionView {
  
 open weak var cDelegate:CustomViewDelegate?
 open weak var cDataSource:CustomViewDataSource?
    
    fileprivate var _editEnabled = false
    fileprivate var _isDeleteItem = false
    fileprivate var _originIndexPath:IndexPath!
    fileprivate var _dragCell:UIView!
    fileprivate var _tempMoveCell:UIView!
    fileprivate var _lastPoint:CGPoint!
    fileprivate var _moveIndexPath:IndexPath!
    fileprivate var longGesture:UILongPressGestureRecognizer!
    
    var onlySortedFirstSection = true // 默认仅排序第一分区
    
    var editEnabled:Bool {
        get {
            return _editEnabled
        }
        set {
            longGesture.isEnabled = newValue
            _editEnabled = newValue
        }
    }
    
    var itemHeaders = [String]()
  open var items: [[AnyHashable]]!
    var dragingIndexPath: IndexPath?
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        layer.masksToBounds = false
        if (UIDevice.current.systemVersion < "11.0") {
            longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
            longGesture.minimumPressDuration = 0.25
            longGesture.isEnabled = true
            addGestureRecognizer(longGesture)
        }
        if #available(iOS 11.0, *) {
            dragDelegate = self
            dropDelegate = self
            dragInteractionEnabled = true
        }
        register(cellType: EditCollectionViewCell.self)
        register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
    }
    
    func dataSourceItems(_ itemBody:[[AnyHashable]]!,_ itemHeaderSections:[String]) {
        itemHeaders = itemHeaderSections
        items = itemBody
        delegate = self
        dataSource = self
    }
    
    @objc
    func longGestureAction(_ gesture:UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            do {
                _isDeleteItem = false;
                gestureRecognizerBegin(gesture as! UILongPressGestureRecognizer)
                cDelegate?.collectionViewBegin?(self, gestureRecognier: gesture as! UILongPressGestureRecognizer, indexPath: _originIndexPath)
            }
            break
        case .changed:
            do {
                if _originIndexPath.section != 0 {
                    if self.onlySortedFirstSection {
                        return
                    }
                }
                cDelegate?.collectionViewChange?(self, gestureRecognier: gesture as! UILongPressGestureRecognizer, indexPath: _originIndexPath)
                gestureRecognizerChange(gesture as! UILongPressGestureRecognizer)
                moveCell()
            }
        case .ended:
            fallthrough
        case .cancelled:
            do {
                cDelegate?.collectionViewEnd?(self, gestureRecognier: gesture as! UILongPressGestureRecognizer, indexPath: _originIndexPath)
                var isRemoveItem = false
                isRemoveItem = ((cDelegate?.collectionCellShouldDeleteCurrentMoveItem?(self, gestureRecognier: gesture as! UILongPressGestureRecognizer, indexPath: _originIndexPath)) != nil)
                
                if isRemoveItem {
                    cDelegate?.dragCollectionCellEndMoving?(self)
                    UIView.animate(withDuration: 0.25) {
                        self._tempMoveCell.alpha = 0
                    } completion: { finished in
                        self._tempMoveCell.removeFromSuperview()
                        self._dragCell.isHidden = false
                    }
                }
                handleItemInSpace()
                if (!_isDeleteItem) {
                    gestureRecognizerCancelOrEnd(gesture as! UILongPressGestureRecognizer)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - 手势长按
    func gestureRecognizerBegin(_ gesture:UILongPressGestureRecognizer) {
        _originIndexPath = indexPathForItem(at: gesture.location(ofTouch: 0, in: gesture.view))
        guard let originPath = _originIndexPath else {return}
        guard let cell = cellForItem(at: originPath) else { return }
        let tempMoveCell = cell.snapshotView(afterScreenUpdates: false)
        _dragCell = cell
        cell.isHidden = true
        _tempMoveCell = tempMoveCell
        _tempMoveCell.frame = cell.frame
        UIView.animate(withDuration: 0.25) {
            self._tempMoveCell.alpha = 0.8
            self._tempMoveCell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
        addSubview(_tempMoveCell)
        _lastPoint = gesture.location(ofTouch: 0, in: self)
    }
    
    // MARK: -手势变化
    func gestureRecognizerChange(_ gesture:UILongPressGestureRecognizer) {
        let offsetX = gesture.location(ofTouch: 0, in: gesture.view).x - _lastPoint.x
        let offsetY = gesture.location(ofTouch: 0, in: gesture.view).y - _lastPoint.y
        _tempMoveCell.center = _tempMoveCell.center.applying(CGAffineTransform(translationX: offsetX, y: offsetY))
        _lastPoint = gesture.location(ofTouch: 0, in: gesture.view)
        
    }
    
    // MARK: - 手机结束
    func gestureRecognizerCancelOrEnd(_ gesture:UILongPressGestureRecognizer) {
        cDelegate?.dragCollectionCellEndMoving?(self)
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25) {
            self._tempMoveCell.center = self._dragCell.center
            self._tempMoveCell.transform = .identity
            self._tempMoveCell.alpha = 1;
        } completion: { finished in
            self._tempMoveCell.removeFromSuperview()
            self._dragCell.isHidden = false
            self.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - 查找分区最后显示项
    func findAllLastIndexPathInVisibleSection() -> [IndexPath]? {
        var items = indexPathsForVisibleItems
        items = items.sorted { $0.section > $1.section}
        var totalItems = [IndexPath]()
        var tempSection = -1
        var tempItems:[IndexPath]!
        items.forEach { indexPath in
            if (tempSection != indexPath.section) {
                tempSection = indexPath.section
                if (tempItems != nil) {
                    let temp = tempItems.sorted(by:{$0.row > $1.row})
                    if (temp.last != nil) {
                        totalItems.append(temp.last!)
                    }
                }
                tempItems = [IndexPath]()
            }
            tempItems.append(indexPath)
        }
        let temp = tempItems.sorted(by: {$0.row > $1.row})
        if ((temp.count) != 0 && temp.last != nil) {
            totalItems.append(temp.last!)
        }
        return totalItems
    }
    
    // MARK: - 处理空白
    func handleItemInSpace() {
        guard let totalItems = findAllLastIndexPathInVisibleSection() else {return}
        _moveIndexPath = nil
        let sourceItems = cDataSource?.dataSourceOfCollectionView(self,indexPath: _originIndexPath)
        for indexPath in totalItems {
            let lastCell = cellForItem(at: indexPath)
            if (lastCell != nil) {
                let tempRect = CGRect.init(x: lastCell!.frame.maxX, y: lastCell!.frame.midY, width: frame.size.width - lastCell!.frame.maxX, height: lastCell!.frame.height)
                if (tempRect.width < lastCell!.frame.width) {
                    continue
                }
                if (tempRect.contains(_tempMoveCell.center)) {
                    _moveIndexPath = indexPath
                    break
                }
            }
        }
        if _moveIndexPath != nil {
            moveItemToIndexPath(indexPath: _moveIndexPath, withSource: sourceItems)
        }else {
            _moveIndexPath = _originIndexPath;
            let sectionLastCell = cellForItem(at: _moveIndexPath)!
            let spaceHeight = (frame.size.height - sectionLastCell.frame.maxY) > sectionLastCell.frame.height ? frame.size.height - sectionLastCell.frame.maxY : 0
            let spaceRect = CGRect.init(x: 0, y: sectionLastCell.frame.maxY, width: frame.size.width, height: spaceHeight)
            if (spaceHeight != 0 && spaceRect.contains( _tempMoveCell.center)) {
                moveItemToIndexPath(indexPath: _moveIndexPath, withSource: sourceItems)
            }
            
        }
    }
    
    // MARK: -
    func moveItemToIndexPath(indexPath:IndexPath,withSource:[AnyHashable]?) {
        if _originIndexPath.section == indexPath.section {// 同分区
            if _originIndexPath.row != indexPath.row { // 同位
                exchangeItemInSection(indexPath: indexPath, withSource: withSource)
            }else if (_originIndexPath.row == indexPath.row) {
                return
            }
        }
    }
    
    
    // MARK: -
    func moveCell() {
        let visibleCells = visibleCells
        for cell in visibleCells {
            if indexPath(for: cell) == _originIndexPath {
                continue
            }
            let spacingX  = fabs(_tempMoveCell.center.x - cell.center.x)
            let spacingY = fabs(_tempMoveCell.center.y - cell.center.y)
            if spacingX <= (_tempMoveCell.bounds.size.width / 2.0) && spacingY <= (_tempMoveCell.bounds.size.height / 2.0)  {
                _moveIndexPath = indexPath(for: cell)
                if _moveIndexPath.section != 0 {
                    if self.onlySortedFirstSection {
                        return
                    }
                }
                // 更新数据源
                 updateDataSource()
                // 开始移动
                moveItem(at: _originIndexPath, to: _moveIndexPath)
                //
                cDelegate?.dragCollectionCellExchange?(self, moveCellFromIndexPath: _originIndexPath, toIndexPath: _moveIndexPath)
                //
                _originIndexPath = _moveIndexPath
            }
        }
    }
    
    // MARK: -
    func updateDataSource (){
        // 数据源
        var tempItems: [AnyHashable]? = []
        guard let temp = cDataSource?.dataSourceOfCollectionView(self,indexPath: _originIndexPath) else {return}
        tempItems? += temp
        // 判断数据源是单个数组还是数组嵌套数组的多区分形式,嵌套则为YES
        let dataTypeCheck = (numberOfSections != 1 || (numberOfSections == 1 && temp.first is [AnyHashable]))
        if dataTypeCheck {
            for i in 0..<(tempItems?.count ?? 0) {
                tempItems![i] = tempItems![i]
            }
        }
        if _moveIndexPath.section == _originIndexPath.section {
            var originalSection:[Any] = dataTypeCheck ? tempItems?[_originIndexPath.section] as! [AnyHashable] : tempItems!
            if _moveIndexPath.item > _originIndexPath.item {
                for i in  _originIndexPath.item..<_moveIndexPath.item {
                    originalSection.swapAt(i, i+1)
                }
            }
            else {
                var i = _originIndexPath.item
                while i > _moveIndexPath.item {
                    originalSection.swapAt(i, i - 1)
                    i -= 1
                }
            }
        }
        else { // 不同分区
            var orignalSection = tempItems?[_originIndexPath.section] as? [AnyHashable]
            var currentSection = tempItems?[_moveIndexPath.section] as? [AnyHashable]
            if let item = orignalSection?[_originIndexPath.item] {
                currentSection?.insert(item, at: _moveIndexPath.item)
            }
            let targetItem = orignalSection?[_originIndexPath.item] as AnyObject
            orignalSection?.removeAll(where: { item in
                if (item == targetItem as! AnyHashable) {
                    return true
                }
                return false
            })
            tempItems?[_originIndexPath.section] = orignalSection
            tempItems?[_moveIndexPath.section]  = currentSection
        }
        cDelegate?.dragCollectionCell(self, newArrayAfterMove: tempItems)
    }
    
    
    // MARK: -
    func exchangeItemInSection(indexPath:IndexPath,withSource:[AnyHashable]?) {
        guard var originItemInSection = withSource else {return}
        let currentRow = _originIndexPath.row
        let toRow = indexPath.row
        if (originItemInSection[indexPath.section] is [AnyHashable]) {
            var items = originItemInSection[indexPath.section] as! [AnyHashable]
            items.swapAt(currentRow, toRow)
        }
        else {
            originItemInSection.swapAt(currentRow, toRow)
        }
        cDelegate?.dragCollectionCell(self, newArrayAfterMove: withSource)
        moveItem(at: _originIndexPath, to: indexPath)
    }

}


extension CustomCollectionView {
    
    open override func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
          super.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        
        if #available(iOS 13.0, *) {
            if contentOffset.y < 0 {
                setContentOffset(.zero, animated: false)
            }
            if (contentOffset.y > contentSize.height) {
                setContentOffset(CGPoint.init(x: 0, y: contentSize.height), animated: false)
            }
        }
    }
}

extension CustomCollectionView: UICollectionViewDelegate,UICollectionViewDataSource,EditCollectionViewCellDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].count
    }
    
    // 向数据源对象询问集合视图中的部分数量。
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemHeaders.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: EditCollectionViewCell.self)
        let item = items[indexPath.section][indexPath.item]
        if (item is String) {
            guard let dic = (item as! String).data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: dic, options: []) as! [String:Any]
           else { fatalError("Error") }
            let name = json["name"] as! String
            cell.dataSource(icon: correct(key: name), text: name,isAdd: indexPath.section == 1)
            cell.delegate = self
        }
        else  {
            let dit = items[indexPath.section][indexPath.item] as! [String:Any]
            let name = dit["name"] as! String
            cell.dataSource(icon:  correct(key: name), text: name,isAdd: indexPath.section == 1)
            cell.delegate = self
        }
        return cell
    }
    
    private func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionView.elementKindSectionHeader, for: indexPath, viewType: HeaderCollectionReusableView.self)
        switch indexPath.section {
        case 0:
            cell.dataSource(text: "显示在首页", ishidden: false,color: UIColor(red: 54, green: 134, blue: 255, alpha: 1))
        case 1:
            cell.dataSource(text: "可添加的卡片", ishidden: true)
        default:
            break
        }
        return cell
    }
    
    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let clickString = self.items[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            self.items[1].append(clickString)
            self.items[0].remove(at: indexPath.item)
            cDelegate?.dragCollectionCell(self, newArrayAfterMove: self.items)
            let indexPath1 = IndexPath.init(row: self.items[1].count - 1, section: 1)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath])
                collectionView.insertItems(at: [indexPath1])
            }

        }else if indexPath.section == 1 {
            self.items[0].append(clickString)
            self.items[1].remove(at: indexPath.item)
            let indexPath1 = IndexPath.init(item: items[0].count - 1, section: 0)
            cDelegate?.dragCollectionCell(self, newArrayAfterMove: self.items)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath])
                collectionView.insertItems(at: [indexPath1])
            }
        }
    }
    
    public func selectedCurrentCell(cell: EditCollectionViewCell,isAdd:Bool) {
        guard let indexPath = indexPath(for: cell) else {return}
        let clickString = self.items[indexPath.section][indexPath.row]
        if (isAdd) {
            self.items[0].append(clickString)
            self.items[1].remove(at: indexPath.item)
            let indexPath1 = IndexPath.init(item: items[0].count - 1, section: 0)
            cDelegate?.dragCollectionCell(self, newArrayAfterMove: self.items)
            performBatchUpdates {
                deleteItems(at: [indexPath])
                insertItems(at: [indexPath1])
            }
        }
        else {
            self.items[1].append(clickString)
            self.items[0].remove(at: indexPath.item)
            cDelegate?.dragCollectionCell(self, newArrayAfterMove: self.items)
            let indexPath1 = IndexPath.init(row: self.items[1].count - 1, section: 1)
            performBatchUpdates {
                deleteItems(at: [indexPath])
                insertItems(at: [indexPath1])
            }
        }
    }
    
    
    func correct(key:String) ->String {
        var str = key
        switch str {
        case "心率":
            str =  "心脏"
        case "血健康指数":
            str =  "心脏"
        default:
            break
        }
        return str
    }
}

extension CustomCollectionView: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (ScreenWidth - 10 * 2 - (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing) / 2
//        return CGSize(width: width, height: 80)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
//    }
}


@available(iOS 11.0,*)
extension CustomCollectionView: UICollectionViewDropDelegate {
   //  处理拖动放下后如何处理
    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            if let item = items.first, let sourceIndexPath = item.sourceIndexPath {
                //执行批量更新
                collectionView.performBatchUpdates({
                    self.items[destinationIndexPath.section].remove(at: sourceIndexPath.row)
                    self.items[destinationIndexPath.section].insert(item.dragItem.localObject as! String, at: destinationIndexPath.row)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                //将项目动画化到视图层次结构中的任意位置
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                // 2022-06-23
                // lipeng 新增
                cDelegate?.dragCollectionCell(self, newArrayAfterMove: self.items)
            }
            break
        case .copy:
            //执行批量更新
            collectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for (index, item) in coordinator.items.enumerated() {
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    self.items[destinationIndexPath.section].insert(item.dragItem.localObject as! String, at: indexPath.row)
                    indexPaths.append(indexPath)
                }
                collectionView.insertItems(at: indexPaths)
            })
            break
        default:
            return
        }
    }
    // 处理拖动过程中
    private func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard dragingIndexPath?.section == destinationIndexPath?.section else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        if session.localDragSession != nil {
            if collectionView.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
}

@available(iOS 11.0,*)
extension CustomCollectionView : UICollectionViewDragDelegate {
    // 处理首次拖动时，是否响应
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.section != 1 else {
            return []
        }
        let item = self.items[indexPath.section][indexPath.row]
        let itemProvider = NSItemProvider(object: item as! NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        dragingIndexPath = indexPath
        return [dragItem]
    }
}

