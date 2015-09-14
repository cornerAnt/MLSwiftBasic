//
//  MLPhotoPickerBrowserViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/31.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import MediaPlayer

let MLPhotoPickerBrowserCellPadding:CGFloat = 10
let MLPhotoPickerBrowserCellIdentifier = "MLPhotoPickerCellIdentifier"

class MLPhotoPickerBrowserViewController: MBBaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,MLPhotoPickerBrowserScrollViewDelegate {

    var moviePlayer:MPMoviePlayerViewController!
    var doneAssets:Array<MLPhotoAssets>!
    var photos:Array<MLPhotoAssets>!{
        willSet{
            self.setBarButtonItemState(newValue.count > 0)
            self.maskView.hidden = !(newValue.count > 0)
            self.maskView.text = "\(newValue.count)"
            self.doneAssets = newValue
            self.reloadData()
        }
    }
    lazy var deleteAssets:NSMutableDictionary? = {
        return NSMutableDictionary()
    }()
    var isShowShowSheet:Bool?
    var sheet:UIActionSheet?
    var isEditing:Bool!{
        willSet{
            self.deleleBtn.hidden = !newValue
        }
    }
    var currentPage:Int?{
        willSet{
            self.setPageLabelPage(newValue!)
        }
    }
    
    var toolBar:UIToolbar!
    /// lazy
    lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = MLPhotoPickerBrowserCellPadding
        flowLayout.itemSize = CGSizeMake(self.view.frame.width, self.view.frame.height - TOP_Y)
        flowLayout.scrollDirection = .Horizontal
        
        var collectionView:UICollectionView = UICollectionView(frame: CGRectMake(0, TOP_Y, self.view.frame.width + MLPhotoPickerBrowserCellPadding, self.view.frame.height - TOP_Y), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: MLPhotoPickerBrowserCellIdentifier)
        self.view.addSubview(collectionView)

        if self.isEditing == true {
            // 初始化底部ToolBar
            self.setupToolBar()
        }
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
    
    lazy var deleleBtn:UIButton = {
        var deleleBtn = UIButton()
        deleleBtn.hidden = true
        deleleBtn.layer.cornerRadius = 15
        deleleBtn.frame = CGRectMake(self.view.frame.width - 50, 25, 30, 30)
        deleleBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
        if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("icon_image_yes")){
            deleleBtn.setImage(image, forState: .Normal)
        }
        deleleBtn.addTarget(self, action: "deleteAsset", forControlEvents: .TouchUpInside)
        self.view.addSubview(deleleBtn)
        self.deleleBtn = deleleBtn;
        return deleleBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    func setupToolBar(){
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.height - CGFloat(KMLPhotoAssetsToolBarHeight), self.view.frame.width, CGFloat(KMLPhotoAssetsToolBarHeight)))
        toolBar.barTintColor = UIColor(rgba: "999999")
        // 中间距 右视图
        var fiexItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var rightItem:UIBarButtonItem = UIBarButtonItem(customView: self.doneBtn)
        
        toolBar.setItems([fiexItem,rightItem], animated: false)
        self.view.addSubview(toolBar)
    }
    
    //MARK:: <UICollectionViewDataSource>
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(MLPhotoPickerBrowserCellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        if (self.photos.count > 0) {
            cell.backgroundColor = UIColor.clearColor()
            var photo = self.photos[indexPath.item]
            
            if(cell.contentView.subviews.last?.isKindOfClass(UIView.self) == true){
                cell.contentView.subviews.last?.removeFromSuperview()
            }
            
            var scrollBoxView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - TOP_Y))
            cell.contentView.addSubview(scrollBoxView)
            
            var scrollView = MLPhotoPickerBrowserScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - TOP_Y))
            if (self.sheet != nil || self.isShowShowSheet == true) {
                scrollView.sheet = self.sheet
            }
            scrollView.backgroundColor = UIColor.clearColor()
            // 为了监听单击photoView事件
            scrollView.photoScrollViewDelegate = self
            scrollView.photo = photo
            scrollBoxView.addSubview(scrollView)
            scrollView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
            
            if photo.isVideo == true {
                scrollView.scrollEnabled = false
                var videoBtn = UIButton()
                videoBtn.setImage(UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("video-play")), forState: .Normal)
                videoBtn.frame = scrollBoxView.bounds
                videoBtn.tag = indexPath.row
                videoBtn.imageView!.contentMode = .Center
                videoBtn.addTarget(self, action: "playerVideo:", forControlEvents: .TouchUpInside)
                scrollBoxView.addSubview(videoBtn)
            }else{
                scrollView.scrollEnabled = true
            }
        }
        
        return cell
    }
    
    func pickerPhotoScrollViewDidSingleClick() {
        self.navBar.hidden = !self.navBar.hidden
        self.deleleBtn.hidden = !self.deleleBtn.hidden
        if (self.isEditing == true) {
            self.toolBar.hidden = !self.toolBar.hidden;
        }
    }
    
    func setBarButtonItemState(state:Bool){
        if (state == true){
            doneBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            doneBtn.userInteractionEnabled = true
        }else{
            doneBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
            doneBtn.userInteractionEnabled = false
        }
    }
    
    func reloadData(){
        self.collectionView.reloadData()
        
        if self.currentPage > 0 {
            var attachVal:CGFloat = 0
            if (self.currentPage == self.photos.count - 1 && self.currentPage > 0) {
                attachVal = MLPhotoPickerBrowserCellPadding
            }
            
            self.collectionView.frame.origin.x = -attachVal;
            self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage!) * self.collectionView.frame.width, 0);
            
            if (self.currentPage == self.photos.count - 1 && self.photos.count > 1) {
                dispatch_after(dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(0.01 * Double(NSEC_PER_SEC))
                    ), dispatch_get_main_queue(), { () -> Void in
                        // 结束动画
                        self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage!) * self.collectionView.frame.width, self.collectionView.contentOffset.y);
                })
            }

        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var tempF = self.collectionView.frame
        var currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.frame.width) + 0.5)
        if (tempF.size.width < UIScreen.mainScreen().bounds.size.width){
            tempF.size.width = UIScreen.mainScreen().bounds.size.width
        }
        
        if ((currentPage < self.photos.count - 1) || self.photos.count == 1) {
            tempF.origin.x = 0;
        }else if(scrollView.dragging == true){
            tempF.origin.x = -MLPhotoPickerBrowserCellPadding;
        }
        self.collectionView.frame = tempF;
        
        
        let pageInt:Int = currentPage
        var currentPageStr:String = String(pageInt)
        
        if(self.deleteAssets?.allValues.count == 0 || self.deleteAssets?.valueForKeyPath(currentPageStr) == nil){
            if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("icon_image_yes")){
                self.deleleBtn.setImage(image, forState: .Normal)
            }
        }else{
            if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("icon_image_no")){
                self.deleleBtn.setImage(image, forState: .Normal)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var currentPage:Int = Int(scrollView.contentOffset.x / (scrollView.frame.width - MLPhotoPickerBrowserCellPadding))
        var isGtSystem8:Bool = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0
        
        if (currentPage == self.photos.count - 1 && currentPage != self.currentPage && isGtSystem8 == true) {
            self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
        }
        self.currentPage = currentPage;
        self.setPageLabelPage(currentPage)
    }
    
    func deleteAsset(){
        let pageInt:Int = self.currentPage!
        var currentPage:String = String(pageInt)

        if self.deleteAssets?.valueForKeyPath(currentPage) == nil {
            self.deleteAssets?.setObject(NSNumber(bool: true), forKey: currentPage)
            if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("icon_image_no")){
                self.deleleBtn.setImage(image, forState: .Normal)
            }
            if self.doneAssets.containsObject(self.photos[self.currentPage!]) == true {
                self.doneAssets.removeObject(self.photos[self.currentPage!])
            }
        }else{
            if self.doneAssets.containsObject(self.photos[self.currentPage!]) == false {
                self.doneAssets.append(self.photos[self.currentPage!])
            }
            self.deleteAssets?.removeObjectForKey(currentPage)
            if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("icon_image_yes")){
                self.deleleBtn.setImage(image, forState: .Normal)
            }
        }
        
        self.setBarButtonItemState(self.doneAssets.count > 0)
        self.maskView.hidden = !(self.doneAssets.count > 0)
        self.maskView.text = "\(self.doneAssets.count)"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName(MLPhotoTakeRefersh, object: nil, userInfo: ["selectAssets":self.doneAssets])
    }
    
    func setPageLabelPage(currentPage:Int){
        if self.photos != nil{
            self.setTitleStr("\(currentPage + 1)/\(self.photos.count)")
        }
    }
    
    func playerVideo(button:UIButton){
        var asset = self.photos[button.tag]
        
        #if TARGET_OS_IPHONE
        if (asset.isKindOfClass(MLPhotoAssets.self)){
            // 设置视频播放器
            
            self.moviePlayer = MPMoviePlayerViewController(contentURL: asset.asset.defaultRepresentation().url())

            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playVideoFinished:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playVideoFinished:", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
            self.view.addSubview(self.moviePlayer.view)
            
            self.moviePlayer.moviePlayer
            var player = self.moviePlayer.moviePlayer
            player.prepareToPlay()
            player.play()
        }
        #else
            var alertView = UIAlertView(title: "提示", message: "播放视频请用真机", delegate: self, cancelButtonTitle: "好的")
            alertView.show()
        #endif
    }
    
    func playVideoFinished(noti:NSNotification){
        var player = noti.object as? MPMoviePlayerController
        player?.stop()
        // 取消监听
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerWillExitFullscreenNotification , object: nil)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            player!.view.alpha = 0.0
        }) { (flag) -> Void in
            player!.view.removeFromSuperview()
        }
    }
    
    func done(){
        NSNotificationCenter.defaultCenter().postNotificationName(MLPhotoTakeDone, object: nil, userInfo: ["selectAssets":self.doneAssets])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
