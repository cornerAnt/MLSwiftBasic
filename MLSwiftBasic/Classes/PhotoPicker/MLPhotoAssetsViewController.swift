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

class MLPhotoAssetsViewController: MBBaseViewController,MLPhotoCollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    /// MLPhotoPickerViewController to content Code condition value.
    var privateTempMaxCount:Int?
    var maxCount:Int!{
        willSet{
            if (newValue == nil){
                return
            }
            
            self.privateTempMaxCount = self.privateTempMaxCount ?? newValue

            if (self.selectPickerAssets != nil){
                if (self.selectAssets.count == newValue){
                    self.maxCount = 0
                }else if (self.selectPickerAssets.count - self.selectAssets.count > 0) {
                    self.maxCount = self.privateTempMaxCount
                }
                self.collectionView.maxCount = self.maxCount
            }else{
                self.collectionView.maxCount = newValue
            }
        }
    }
    var status:PhotoViewShowStatus!
    var selectPickers:Array<MLPhotoAssets>!
    var topShowPhotoPicker:Bool!{
        willSet{
            if (newValue == nil){
                return 
            }
            if (newValue == true && self.collectionView.dataArray != nil) {
                var reSortArray = Array<MLPhotoAssets>()

                if (self.status != nil && self.status != PhotoViewShowStatus.PhotoViewShowStatusVideo){
                    var mlAsset = MLPhotoAssets()
                    mlAsset.asset = nil
                    reSortArray.append(mlAsset)
                }
                
                if self.collectionView.dataArray != nil {
                    for obj in self.collectionView.dataArray.reverse() {
                        reSortArray.append(obj)
                    }
                }
                
                self.collectionView.cellOrderStatus = .MLPhotoCollectionCellShowOrderStatusAsc
                self.collectionView.topShowPhotoPicker = newValue
                self.collectionView.dataArray = reSortArray
                self.collectionView.reloadData()
            }
        }
    }
    
    weak var groupVc:MLPhotoGruopViewController?
    var group:MLPhotoGroup!{
        willSet {
            if (newValue == nil) {
                return
            }
            // 请求Assets
            self.setTitleStr(newValue.groupName)
            MLPhotoPickerDAO().getAllAssetsWithGroup(newValue, assetsCallBack: { [weak self](assets) -> Void in
                if self?.topShowPhotoPicker != nil && self?.topShowPhotoPicker == true {
                    var reversObjects:Array = assets
                    var reSortArray:Array = Array<MLPhotoAssets>()
                    if  reversObjects.count > 0 {
                        for obj in reversObjects.reverse() {
                            reSortArray.append(obj)
                        }
                    }
                    
                    if (self!.status != nil && self!.status != PhotoViewShowStatus.PhotoViewShowStatusVideo){
                        var mlAsset = MLPhotoAssets()
                        mlAsset.asset = nil
                        reSortArray.insert(mlAsset, atIndex: 0)
                    }
                    
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
    
    lazy var assets:Array<MLPhotoAssets>! = {
        return Array<MLPhotoAssets>()
    }()
    var selectPickerAssets:Array<MLPhotoAssets>!{
        willSet{
            if newValue == nil {
                return
            }
            var set = NSSet(array: newValue!)
            self.selectPickerAssets = set.allObjects as! Array<MLPhotoAssets>
            
            if self.assets == nil {
                self.assets = selectPickerAssets
            }else{
                for asset in newValue! {
                    self.assets.append(asset)
                }
            }
            
            for asset in newValue {
                if asset.isKindOfClass(MLPhotoAssets.self) {
                    self.selectAssets.append(asset)
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
        collectionView.status = self.status
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
    
    lazy var selectAssets:Array<MLPhotoAssets>! = {
        return Array<MLPhotoAssets>()
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh:", name: MLPhotoTakeRefersh, object: nil)
    }
    
    func refresh(noti:NSNotification){
        var userInfo = noti.userInfo as! [NSObject: Array<MLPhotoAssets>]
        var assets = userInfo["selectAssets"]
        
        self.selectAssets = assets
        self.collectionView.isRecoderSelectPicker = true
        self.collectionView.selectsIndexPath.removeAll(keepCapacity: true)
        self.collectionView.selectAssets = assets
        self.collectionView.reloadData()
        
        var count = 0
        if (self.collectionView.selectAssets.count < self.selectAssets.count) {
            count = self.collectionView.selectAssets.count
        }else{
            count = self.selectAssets.count
        }
        
        // 刷新下最小的页数
        if self.maxCount == nil {
            self.maxCount = KMLPhotoShowMaxCount
        }else{
            self.maxCount = self.selectAssets.count + (self.privateTempMaxCount! - self.selectAssets.count)
        }
        
        self.maskView.hidden = !(count > 0)
        self.maskView.text = "\(count)"
        self.setBarButtonItemState(count > 0)
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
        browserVc.currentPage = 0
        self.navigationController?.pushViewController(browserVc, animated: true)
    }
    
    func done(){
        NSNotificationCenter.defaultCenter().postNotificationName(MLPhotoTakeDone, object: self, userInfo: ["selectAssets":self.selectAssets])
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

        if self.selectPickerAssets != nil && self.selectPickerAssets.count == 0 {
            self.selectAssets = collectionView.selectAssets
        }else if deleteAssets == nil {
            self.selectAssets.append(collectionView.selectAssets.last!)
        }
        
        if (deleteAssets != nil && self.selectAssets != nil && self.selectAssets.count > 0) {
            var selectAssetsCurrentPage = -1;
            for (var i = 0; i < self.selectAssets.count; i++) {
                var photoAsset:MLPhotoAssets = self.selectAssets[i]
                if (photoAsset.image != nil && photoAsset.image.isKindOfClass(UIImage.self)) {
                    continue;
                }
                if deleteAssets!.asset.defaultRepresentation().url().isEqual(photoAsset.asset.defaultRepresentation().url()) == true{
                    selectAssetsCurrentPage = i
                    break
                }
            }
            
            if ((self.selectAssets.count > selectAssetsCurrentPage) && selectAssetsCurrentPage >= 0) {
                    if (deleteAssets != nil){
                        self.selectAssets.removeAtIndex(selectAssetsCurrentPage)
                    }
                
                    collectionView.selectAssets = self.selectAssets
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
        
        // 刷新下最小的页数
        if self.maxCount == nil {
            self.maxCount = KMLPhotoShowMaxCount
        }else{
            self.maxCount = self.selectAssets.count + (self.privateTempMaxCount! - self.selectAssets.count)
        }
    }
    
    /**
    DidCamera
    */
    func photoCollectionViewDidCameraSelectCollectionView(collectionView: MLPhotoCollectionView) {
        var maxCount = (self.maxCount == nil || self.maxCount < 0) ? KMLPhotoShowMaxCount :  self.maxCount
        if (self.selectAssets.count >= maxCount) {
            var alertView = UIAlertView(title: "提醒", message: String("您已经选满了图片呦."), delegate: nil, cancelButtonTitle: "好的")
            alertView.show()
            return
        }
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            var ctrl = UIImagePickerController()
            ctrl.delegate = self
            ctrl.sourceType = .Camera
            self.presentViewController(ctrl, animated: true, completion: nil)
        }else{
            var alertView = UIAlertView(title: "提醒", message: String("请在真机使用哈"), delegate: nil, cancelButtonTitle: "好的")
            alertView.show()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            // 处理
            var image:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
            // create Asset
            var imageAsset = MLPhotoAssets()
            imageAsset.image = image
            self.selectAssets.append(imageAsset)
            self.collectionView.selectAssets = self.selectAssets
            
            var count = self.selectAssets.count
            self.maskView.hidden = !(count > 0)
            self.maskView.text = "\(count)"
            self.setBarButtonItemState(count > 0)
            // 刷新当前相册
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
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
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 赋值给上一个控制器
        self.groupVc?.topShowPhotoPicker = self.topShowPhotoPicker
        if let selectAssets = NSArray(array: self.selectAssets) as? Array<MLPhotoAssets> {
            self.groupVc?.selectPickers = selectAssets
        }
    }
}
