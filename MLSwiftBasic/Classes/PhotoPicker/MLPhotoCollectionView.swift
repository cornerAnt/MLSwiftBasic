//
//  MLPhotoCollectionView.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/29.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import AssetsLibrary

enum MLPhotoCollectionCellShowOrderStatus:Int {
    case MLPhotoCollectionCellShowOrderStatusDesc = 0
    case MLPhotoCollectionCellShowOrderStatusAsc = 1
}

class MLPhotoCollectionView: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    weak var mlDelegate:MLPhotoCollectionViewDelegate?
    
    var cellOrderStatus:MLPhotoCollectionCellShowOrderStatus?
    var topShowPhotoPicker:Bool!
    
    var isRecoderSelectPicker:Bool!
    var maxCount:NSInteger!
    var firstLoadding:Bool?
    
    lazy var selectsIndexPath:Array<NSNumber>! = {
        return Array<NSNumber>()
    }()
    lazy var lastDataArray:Array<MLPhotoAssets>! = {
        return Array<MLPhotoAssets>()
    }()
    lazy var selectAssets:Array<MLPhotoAssets>! = {
        return Array<MLPhotoAssets>()
    }()
    
    private var footerView:MLPhotoAssetsFooterView?
    
    var dataArray:Array<MLPhotoAssets>!{
        willSet{
            if (newValue == nil){
                return ;
            }
            // 需要记录选中的值的数据
            if self.isRecoderSelectPicker == true && newValue != nil{
                var assets = Array<MLPhotoAssets>()
                for selectAsset in self.selectAssets{
                    for dataAsset in newValue{
                        var realAsset:MLPhotoAssets = dataAsset
                        var selectRealAsset:MLPhotoAssets = selectAsset
                        
                        if realAsset.asset != nil && selectRealAsset.asset != nil {
                            if  selectRealAsset.asset.defaultRepresentation().url().isEqual(realAsset.asset.defaultRepresentation().url()) == true{
                                assets.append(realAsset)
                                break;
                            }
                        }
                    }
                }
                selectAssets = assets
            }
            self.reloadData()
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(0.01 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(), { () -> Void in
                    // 结束动画
                    self.reloadData()
            })
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        // register footerView
        self.cellOrderStatus = .MLPhotoCollectionCellShowOrderStatusDesc
        self.firstLoadding = false
        self.isRecoderSelectPicker = false
        
        self.registerClass(MLPhotoAssetsCell.self, forCellWithReuseIdentifier: "MLPhotoAssetsCell")
        self.backgroundColor = UIColor.clearColor()
        self.dataSource = self
        self.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let identifier = "MLPhotoAssetsCell"
        var cell:MLPhotoAssetsCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! MLPhotoAssetsCell
        
        var cellImgView:MLPhotoPickerCellImageView? = cell.thumbImageView
        
        if(indexPath.item == 0 && self.topShowPhotoPicker != nil
             && self.topShowPhotoPicker == true){
            cellImgView!.contentMode = .ScaleAspectFit;
            cellImgView!.clipsToBounds = true;
            cellImgView!.tag = indexPath.item;
            cellImgView!.isMaskSelected = false
            if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("camera")){
                cellImgView!.image = image
            }
        }else{
            // 需要记录选中的值的数据
            if (self.isRecoderSelectPicker == true) {
                for asset in self.selectAssets {
                    var dataAsset:MLPhotoAssets = self.dataArray[indexPath.item] as MLPhotoAssets
                    var selectRealAsset = asset
                    if selectRealAsset.asset.defaultRepresentation().url().isEqual(dataAsset.asset.defaultRepresentation().url()) {
                        selectsIndexPath.append(NSNumber(integer: indexPath.row))
                    }
                }
            }
            
            if (selectsIndexPath.containsObject(NSNumber(integer: indexPath.row))){
                println(indexPath.row)
            }
            cellImgView!.isMaskSelected = selectsIndexPath.containsObject(NSNumber(integer: indexPath.row))
            cell.assets = self.dataArray[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var cell:MLPhotoAssetsCell = collectionView.cellForItemAtIndexPath(indexPath) as! MLPhotoAssetsCell
        
        if (self.topShowPhotoPicker != nil && self.topShowPhotoPicker == true && indexPath.item == 0) {
            if (self.mlDelegate!.respondsToSelector("photoCollectionViewDidCameraSelectCollectionView:")) {
                self.mlDelegate!.photoCollectionViewDidCameraSelectCollectionView!(self)
            }
            return ;
        }
        
        var cellImgView:MLPhotoPickerCellImageView = (cell.contentView.subviews.last as? MLPhotoPickerCellImageView)!
        
        var asset = self.dataArray[indexPath.row]
        // 如果没有就添加到数组里面，存在就移除
        if (cellImgView.isMaskSelected == true) {
            
            var row = NSNumber(integer: indexPath.row)
            
            self.selectsIndexPath.removeObject(NSNumber(integer: indexPath.row))
            self.selectAssets.removeObject(asset)
            self.lastDataArray.removeObject(asset)
        }else{
            // 判断图片数超过最大数或者小于0
            var maxCount = (self.maxCount == nil || self.maxCount < 0) ? KMLPhotoShowMaxCount :  self.maxCount
            var currentCount = self.selectAssets.count
            if (currentCount >= maxCount) {
                var format = "最多只能选择\(maxCount)张图片"
                if (maxCount == 0) {
                    format = "您已经选满了图片呦."
                }
                var alertView = UIAlertView(title: "提醒", message: format, delegate: self, cancelButtonTitle: "好的")
                alertView.show()
                
                return
            }
            
            self.selectsIndexPath.append(NSNumber(integer: indexPath.row))
            self.selectAssets.append(asset)
            self.lastDataArray.append(asset)
        }
        
        var photoCollectionView = collectionView as? MLPhotoCollectionView
        if (self.mlDelegate?.respondsToSelector("photoCollectionViewDidSelectedCollectionView:") != nil) {
            if cellImgView.isMaskSelected == true{
                // Delete
                self.mlDelegate?.photoCollectionViewDidSelectedCollectionView!(photoCollectionView!, deleteAssets: asset)
            }else{
                // Add
                self.mlDelegate?.photoCollectionViewDidSelectedCollectionView!(photoCollectionView!, deleteAssets: nil)
            }
        }
        
        cellImgView.isMaskSelected = (cellImgView.isKindOfClass(MLPhotoPickerCellImageView.self)) && !cellImgView.isMaskSelected;
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView:MLPhotoAssetsFooterView?;
        if (kind == UICollectionElementKindSectionFooter) {
            footerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", forIndexPath: indexPath) as? MLPhotoAssetsFooterView
            footerView!.count = self.dataArray.count;
            reusableView = footerView;
        }else{
            
        }
        return reusableView!;
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.cellOrderStatus == MLPhotoCollectionCellShowOrderStatus.MLPhotoCollectionCellShowOrderStatusDesc {
            if ((self.firstLoadding == false && self.contentSize.height > UIScreen.mainScreen().bounds.size.height)) {
                // 滚动到最底部（最新的）
                self.scrollToItemAtIndexPath(NSIndexPath(forItem: self.dataArray.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
                // 展示图片数
                self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + CGFloat(KMLPhotoAssetsToolBarHeight) * 2);
                self.firstLoadding = true;
            }
        }
    }
}

@objc protocol MLPhotoCollectionViewDelegate: NSObjectProtocol{
    optional func photoCollectionViewDidSelectedCollectionView(collectionView:MLPhotoCollectionView, deleteAssets:MLPhotoAssets?);
    optional func photoCollectionViewDidCameraSelectCollectionView(collectionView:MLPhotoCollectionView);
}
