//
//  MLPhotoAssetsViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/28.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

// Max Count
let KMLPhotoShowMaxCount          = 9
// Show CollectionView column count.
let KMLPhotoAssetsShowColumnCount = 4
// ToolBar Height
let KMLPhotoAssetsToolBarHeight   = 44

class MLPhotoAssetsViewController: MBBaseViewController,MLPhotoCollectionViewDelegate {
    
    /// MLPhotoPickerViewController to content Code condition value.
    var maxCount:NSInteger!{
        willSet{
            if (self.selectAssets.count == newValue){
                self.collectionView.maxCount = 0
            }else{
                self.collectionView.maxCount = newValue
            }
        }
    }
    var status:PhotoViewShowStatus!
    var selectPickers:Array<MLPhotoAssets>!
    var topShowPhotoPicker:Bool!{
        willSet{
            if (newValue == true && self.collectionView.dataArray != nil) {
                var reSortArray = NSMutableArray()
                if self.collectionView.dataArray != nil {
                    for obj in self.collectionView.dataArray!.reverseObjectEnumerator() {
                        reSortArray.addObject(obj)
                    }
                }
                var mlAsset = MLPhotoAssets()
                mlAsset.asset = nil
                reSortArray.insertObject(mlAsset, atIndex: 0)
                
                self.collectionView.cellOrderStatus = .MLPhotoCollectionCellShowOrderStatusAsc
                self.collectionView.topShowPhotoPicker = newValue
                self.collectionView.dataArray = reSortArray
                self.collectionView.reloadData()
            }
        }
    }
    
    var groupVc:MLPhotoGruopViewController?
    var group:MLPhotoGroup!{
        willSet {
            if (newValue == nil) {
                return
            }
            // 请求Assets
            self.setTitleStr(newValue.groupName)
            MLPhotoPickerDAO().getAllAssetsWithGroup(newValue, assetsCallBack: { [weak self](assets) -> Void in
                if self?.topShowPhotoPicker != nil && self?.topShowPhotoPicker == true {
                    var reversObjects = NSMutableArray(array: assets)
                    var reSortArray:NSMutableArray = NSMutableArray()
                    if  reversObjects.count > 0 {
                        for obj in reversObjects.reverseObjectEnumerator() {
                            reSortArray.addObject(obj)
                        }
                    }
                    var mlAsset = MLPhotoAssets()
                    mlAsset.asset = nil
                    reSortArray.insertObject(mlAsset, atIndex: 0)
                    
                    self?.collectionView.cellOrderStatus = .MLPhotoCollectionCellShowOrderStatusAsc
                    self?.collectionView.topShowPhotoPicker = self?.topShowPhotoPicker
                    self?.collectionView.dataArray = reSortArray
                }else{
                    self?.collectionView.dataArray = assets
                }
                self?.collectionView.reloadData()
            })
        }
    }
    
    var assets:NSMutableArray!
    var selectPickerAssets:Array<MLPhotoAssets>!{
        willSet{
            if newValue == nil {
                return
            }
            var set = NSSet(array: newValue!)
            self.selectPickerAssets = set.allObjects as! Array<MLPhotoAssets>
            
            if self.assets == nil {
                self.assets = NSMutableArray(array: selectPickerAssets)
            }else{
                self.assets.addObjectsFromArray(newValue)
            }
            
            for asset in newValue {
                if asset.isKindOfClass(MLPhotoAssets.self) || assets.isKindOfClass(UIImage.self) {
                    self.selectAssets.addObject(asset)
                }
            }
            
            self.collectionView.lastDataArray = nil
            self.collectionView.isRecoderSelectPicker = true
            self.collectionView.selectAssets = self.selectAssets
            
            var count = self.selectAssets.count
            self.maskView.hidden = !(count > 0)
            self.maskView.text = "\(count)"
            self.setBarButtonItemState((count > 0))
        }
    }
    
    /// Lazy
    lazy var collectionView:MLPhotoCollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        var allMargin:CGFloat = 12
        var width:CGFloat = (self.view.frame.width - allMargin) / CGFloat(KMLPhotoAssetsShowColumnCount)
        var margin:CGFloat = allMargin / (CGFloat(KMLPhotoAssetsShowColumnCount)-1)
        flowLayout.itemSize = CGSizeMake(width, width)
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, CGFloat(KMLPhotoAssetsToolBarHeight) * 2.0);
        
        var collectionView:MLPhotoCollectionView = MLPhotoCollectionView(frame: CGRectMake(0, TOP_Y + MARGIN_8, self.view.frame.width, self.view.frame.height - TOP_Y - MARGIN_8 - CGFloat(KMLPhotoAssetsToolBarHeight)), collectionViewLayout: flowLayout)
        collectionView.mlDelegate = self
        collectionView.registerClass(MLPhotoAssetsFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,withReuseIdentifier: "FooterView")
        
        self.view.addSubview(collectionView)
        
        self.setupToolbar()
        
        return collectionView
    }()
    
    lazy var maskView:UILabel = {
        var maskView = UILabel(frame: CGRectMake(-5, -5, 20, 20))
        maskView.textColor = UIColor.whiteColor()
        maskView.textAlignment = .Center
        maskView.font = UIFont.systemFontOfSize(13)
        maskView.hidden = true
        maskView.layer.cornerRadius = maskView.frame.height / 2.0
        maskView.clipsToBounds = true
        maskView.backgroundColor = UIColor.redColor()
        self.maskView = maskView
        return maskView
    }()
    
    lazy var previewBtn:UIButton = {
        var previewBtn = UIButton()
        previewBtn.titleLabel!.font = UIFont.systemFontOfSize(17)
        previewBtn.frame = CGRectMake(0, 0, 45, 45);
        previewBtn.setTitle("预览", forState: .Normal)
        previewBtn.addTarget(self, action: "preview", forControlEvents: .TouchUpInside)
        self.previewBtn = previewBtn;
        return previewBtn
    }()
    
    lazy var doneBtn:UIButton = {
        var doneBtn = UIButton()
        doneBtn.frame = CGRectMake(0, 0, 45, 45);
        doneBtn.titleLabel!.font = UIFont.systemFontOfSize(17)
        doneBtn.setTitle("完成", forState: .Normal)
        doneBtn.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
        doneBtn.addSubview(self.maskView)
        self.doneBtn = doneBtn;
        return doneBtn
    }()
    
    lazy var selectAssets:NSMutableArray = {
        return NSMutableArray()
    }()
    
    func setBarButtonItemState(state:Bool){
        if (state == true){
            doneBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            previewBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            
            doneBtn.userInteractionEnabled = true
            previewBtn.userInteractionEnabled = true
        }else{
            previewBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
            doneBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
            
            doneBtn.userInteractionEnabled = false
            previewBtn.userInteractionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupToolbar(){
        var toolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.height - CGFloat(KMLPhotoAssetsToolBarHeight), self.view.frame.width, CGFloat(KMLPhotoAssetsToolBarHeight)))
        // 左视图 中间距 右视图
        var leftItem:UIBarButtonItem = UIBarButtonItem(customView: self.previewBtn)
        var fiexItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var rightItem:UIBarButtonItem = UIBarButtonItem(customView: self.doneBtn)
        self.setBarButtonItemState(false)
        
        toolbar.setItems([leftItem,fiexItem,rightItem], animated: false)
        self.view.addSubview(toolbar)
    }
    
    func preview(){
        var browserVc:MLPhotoPickerBrowserViewController = MLPhotoPickerBrowserViewController()
        browserVc.isEditing = true

        var realAssets = NSMutableArray(array: self.selectAssets)
        var tempAssets = NSArray(array: realAssets)
        browserVc.photos = tempAssets as! Array<MLPhotoAssets>
        self.navigationController?.pushViewController(browserVc, animated: true)
    }
    
    func done(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(MLPhotoTakeDone, object: self, userInfo: ["selectAssets":self.selectAssets])
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: <MLPhotoCollectionViewDelegate>
    /**
    DidSelected
    
    :param: deleteAssets deleteAssets
    */
    func photoCollectionViewDidSelectedCollectionView(collectionView: MLPhotoCollectionView, deleteAssets: MLPhotoAssets?) {
        // animation
        self.startAnimation()

        if self.selectPickerAssets != nil && self.selectPickerAssets.count == 0{
            self.selectAssets = collectionView.selectAssets
        }else if deleteAssets == nil {
            self.selectAssets.addObject(collectionView.selectAssets.lastObject!)
        }
        
        
        if (deleteAssets != nil && self.selectPickerAssets != nil && self.selectPickerAssets.count > 0) {
            var selectAssetsCurrentPage = -1;
            for (var i = 0; i < self.selectAssets.count; i++) {
                var photoAsset:MLPhotoAssets = self.selectAssets[i] as! MLPhotoAssets
                if (photoAsset.isKindOfClass(UIImage.self)) {
                    continue;
                }

                if deleteAssets!.asset.defaultRepresentation().url().isEqual(photoAsset.asset.defaultRepresentation().url()) == true{
                    selectAssetsCurrentPage = i
                    break
                }
            }
            
            if (
                (self.selectAssets.count > selectAssetsCurrentPage)
                    &&
                    (selectAssetsCurrentPage >= 0)
                ){
                    if (deleteAssets != nil){
                        self.selectAssets.removeObjectAtIndex(selectAssetsCurrentPage)
                    }
                    
                    self.collectionView.selectsIndexPath.removeObject(NSNumber(integer: selectAssetsCurrentPage))
            }
        }
        
        var count = 0
        if (collectionView.selectAssets.count > self.selectAssets.count) {
            count = collectionView.selectAssets.count
        }else{
            count = self.selectAssets.count
        }
        
        self.maskView.hidden = !(count > 0)
        self.maskView.text = "\(count)"
        self.setBarButtonItemState((count > 0))
    }
    
    /**
    DidCamera
    */
    func photoCollectionViewDidCameraSelectCollectionView(collectionView: MLPhotoCollectionView) {
        
    }
    
    func startAnimation(){
        self.maskView.layer.removeAllAnimations()
        var scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.25
        scaleAnimation.autoreverses = true
        scaleAnimation.values = [
            NSNumber(float: 1.0),
            NSNumber(float: 1.2),
            NSNumber(float: 1.0)
        ]
        scaleAnimation.fillMode = kCAFillModeForwards
        self.maskView.layer.addAnimation(scaleAnimation, forKey: "transform.rotate")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 赋值给上一个控制器
        self.groupVc?.topShowPhotoPicker = self.topShowPhotoPicker
        if var selectAssets = NSArray(array: self.selectAssets) as? Array<MLPhotoAssets> {
            self.groupVc?.selectPickers = selectAssets
        }
        
//        // Clear
//        if (self.collectionView.dataArray != nil){
//            self.collectionView.dataArray = nil
//        }
//        self.selectPickerAssets = nil
//        self.assets = nil
//        self.collectionView.removeFromSuperview()
//        self.view.removeFromSuperview()
//        self.removeFromParentViewController()
        
    }
}
