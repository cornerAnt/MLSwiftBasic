//
//  MLPhotoBrowserViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/5.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

let MLPhotoPickerCollectionViewPadding:CGFloat = 10

// 点击View执行的动画
enum MLPhotoBrowserAnimationAnimationStatus:Int {
    case MLPhotoBrowserAnimationAnimationStatusZoom = 0 // 放大缩小
    case MLPhotoBrowserAnimationAnimationStatusFade = 1 // 淡入淡出
}

class MLPhotoBrowserViewController: MBBaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,MLPhotoBrowserPhotoScrollViewDelegate,UIAlertViewDelegate {
    
    /// 展示的图片数组
    var photos:Array<MLPhotoBrowser>!
    /// 显示第几张图片
    var currentPage:Int!
    /// 是否删除
    var isDeletePhotoMode:Bool?
    /// 动画效果展示, Default = MLPhotoBrowserAnimationAnimationStatusZoom
    var status:MLPhotoBrowserAnimationAnimationStatus?
    var delegate:MLPhotoBrowserViewControllerDelegate?
    /// 导航栏高度
    var navigationHeight:CGFloat?
    var isPush:Bool?
    /// 屏幕旋转
    private var isNowRotation:Bool?
    private var disMissBlock:((page:Int) -> Void)!
    
    lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = MLPhotoPickerCollectionViewPadding
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = self.view.frame.size
        flowLayout.scrollDirection = .Horizontal;
        
        var collectionView = UICollectionView(frame: CGRectMake(0, TOP_Y, self.view.frame.width + MLPhotoPickerCollectionViewPadding,self.view.frame.height - TOP_Y), collectionViewLayout: flowLayout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier:"cell")
        self.view.addSubview(collectionView)
        self.collectionView = collectionView

        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-x-|", options: nil, metrics: ["x":NSNumber(float: Float(-MLPhotoPickerCollectionViewPadding))], views: ["collectionView":collectionView]))
        
        if (self.isPush == nil || self.isPush == false){
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: ["collectionView":collectionView]))
        }else{
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[collectionView]-0-|", options: nil, metrics: nil, views: ["collectionView":collectionView]))
        }
        
        self.pageLabel.hidden = false
        self.deleleBtn.hidden = (self.isDeletePhotoMode! != true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeRotationDirection:", name:UIDeviceOrientationDidChangeNotification, object: nil)
        
        return collectionView
    }()
    
    lazy var deleleBtn:UIButton = {
        var deleleBtn = UIButton()
        deleleBtn.frame = CGRectMake(self.view.frame.width - 80, 0, 80, 20)
        deleleBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleleBtn.titleLabel!.font = UIFont.systemFontOfSize(18)
        deleleBtn.setTitle("移除", forState: .Normal)
        // 设置阴影
        deleleBtn.layer.shadowColor = UIColor.blackColor().CGColor
        deleleBtn.layer.shadowOffset = CGSizeMake(0, 0)
        deleleBtn.layer.shadowRadius = 3
        deleleBtn.layer.shadowOpacity = 1.0
        deleleBtn.hidden = true
        deleleBtn.addTarget(self, action: "delete", forControlEvents: .TouchUpInside)
        self.view.addSubview(deleleBtn)
        self.deleleBtn = deleleBtn
        
        deleleBtn.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[deleleBtn(deleteBtnWH)]-margin-|", options: nil, metrics: ["deleteBtnWH":NSNumber(float: Float(50)), "margin":NSNumber(float: Float(10))], views: ["deleleBtn":deleleBtn]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[deleleBtn(deleteBtnWH)]", options: nil, metrics: ["deleteBtnWH":NSNumber(float: Float(50)), "margin":NSNumber(float: Float(20))], views: ["deleleBtn":deleleBtn]))
        
        return deleleBtn
    }()
    
    lazy var pageLabel:UILabel = {
        var pageLabel = UILabel()
        pageLabel.frame = CGRectMake(0, self.view.frame.height - 60, self.view.frame.width, 60)
        pageLabel.font = UIFont.systemFontOfSize(18)
        pageLabel.textAlignment = .Center
        pageLabel.userInteractionEnabled = false
        pageLabel.backgroundColor = UIColor.clearColor()
        pageLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(pageLabel)
        self.pageLabel = pageLabel
        
        pageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[pageLabel]-0-|", options: nil, metrics: nil, views: ["pageLabel":pageLabel]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageLabel(25)]-20-|", options: nil, metrics: nil, views: ["pageLabel":pageLabel]))
        
        return pageLabel
    }()
    
    func showPickerVc(vc:UIViewController){
        weak var viewController = vc
        if viewController!.isKindOfClass(UIViewController.self){
            viewController!.presentViewController(self, animated: false, completion: nil)
        }
    }
    
    func showPushVc(vc:UIViewController){
        self.isPush = true
        weak var viewController = vc
        if viewController!.isKindOfClass(UIViewController.self){
            viewController!.navigationController?.pushViewController(self, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavBarViewBackgroundColor(UIColor.blackColor())
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.isPush == nil || self.isPush == false){
            self.showToView()
        }else{
            
            self.collectionView.reloadData()
            if (self.currentPage >= 0) {
                self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width, 0)
                if (self.currentPage == self.photos.count - 1 && self.photos.count > 1) {
                    dispatch_after(dispatch_time(
                        DISPATCH_TIME_NOW,
                        Int64(0.01 * Double(NSEC_PER_SEC))
                        ), dispatch_get_main_queue(), { () -> Void in
                            // 结束动画
                            self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width - MLPhotoPickerCollectionViewPadding, 0)
                    })
                }
            }
            self.setPageLabelPage(self.currentPage)
            
        }
    }
    
    func showToView(){
        var mainView = UIView(frame: UIScreen.mainScreen().bounds)
        mainView.backgroundColor = UIColor.blackColor()
        mainView.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        UIApplication.sharedApplication().keyWindow?.addSubview(mainView)
        
        self.reloadData()
        
        var toImageView = self.photos[self.currentPage].toView
        var imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFill;
        imageView.clipsToBounds = true
        mainView.addSubview(imageView)
        mainView.clipsToBounds = true
        
        var thumbImage:UIImage? = self.photos[self.currentPage].toView!.image
        if (thumbImage == nil) {
            thumbImage = toImageView!.image
        }
        
        if (self.status == MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusFade){
            imageView.image = thumbImage
            imageView.alpha = 0.0
        }else{
            if (thumbImage == nil) {
                imageView.image = toImageView!.image
            }else{
                imageView.image = thumbImage
            }
        }

        var tempF = toImageView!.superview?.convertRect(toImageView!.frame, toView: self.getParsentView(self.getParsentView(toImageView)))
        imageView.frame = tempF!

        self.disMissBlock = { [weak self](page) -> Void in
            mainView.hidden = false
            mainView.alpha = 1.0
            var originalFrame = CGRectZero
            self?.dismissViewControllerAnimated(false, completion: nil)
            
            // 缩放动画
            if(self!.status == nil || self!.status == MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusZoom){
                var thumbImage = self?.photos[page].thumbImage
                var photo:MLPhotoBrowser = self!.photos[page] as MLPhotoBrowser
                
                if (thumbImage == nil) {
                    imageView.image = photo.toView?.image
                    thumbImage = imageView.image
                }else{
                    imageView.image = thumbImage
                }
                
                var ivFrame = ZLPhotoRect.setMaxMinZoomScalesForCurrentBoundWithImage(thumbImage!)
                if (!CGRectEqualToRect(ivFrame, CGRectZero)) {
                    imageView.frame = ivFrame;
                }
                var toImageView2 = photo.toView
                
                originalFrame = toImageView2!.superview!.convertRect(toImageView2!.frame, toView: self?.getParsentView(toImageView2))
                if (CGRectIsEmpty(originalFrame)) {
                    originalFrame = tempF!
                }
            }else{
                // 淡入淡出
                imageView.alpha = 0.0
            }
            
            if (self!.navigationHeight != nil && self!.navigationHeight > 0) {
                originalFrame.origin.y += self!.navigationHeight!
            }
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    if (self?.status == MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusFade                ){
                        mainView.alpha = 0.0
                    }else{
                        mainView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                        imageView.frame = originalFrame
                    }
                }, completion: { (flag) -> Void in
                    mainView.removeFromSuperview()
                    imageView.removeFromSuperview()
                })
        }
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if (self.status == MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusFade                ){
                mainView.alpha = 0.0
            }else{
                imageView.frame = ZLPhotoRect.setMaxMinZoomScalesForCurrentBoundWithImageView(imageView)
            }
        }) { (flag) -> Void in
            mainView.hidden = true
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        if (collectionView.dragging) {
            cell.hidden = false
        }
        if (self.photos.count > 0) {
            var photo:MLPhotoBrowser = self.photos[indexPath.item]
            if cell.contentView.subviews.last?.isKindOfClass(UIView.self) == true{
               cell.contentView.subviews.last?.removeFromSuperview()
            }
            
            var tempF = UIScreen.mainScreen().bounds
            var scrollBoxView = UIView(frame: tempF)
            scrollBoxView.autoresizingMask = .FlexibleHeight | .FlexibleWidth;
            cell.contentView.addSubview(scrollBoxView)
            
            var scrollView = MLPhotoBrowserPhotoScrollView()
            //            scrollView.sheet = self.sheet;
            // 为了监听单击photoView事件
            scrollView.frame = tempF
            scrollView.tag = 101
            scrollView.photo = photo
            scrollView.photoScrollViewDelegate = self
            scrollBoxView.addSubview(scrollView)
            scrollView.autoresizingMask = .FlexibleHeight | .FlexibleWidth;
        }
        
        return cell
    }
    
    func getParsentView(view:UIView?) -> UIView {
        if ((view!.nextResponder()?.isKindOfClass(UIViewController.self) == true) || view == nil){
            return view!
        }else{
            return self.getParsentView(view!.superview!)
        }
    }
    
    func photoBrowserPhotoScrollViewDidSingleClick() {
        if self.delegate?.respondsToSelector("photoBrowser:photoDidSelectAtIndexPath:") == true{
            self.delegate?.photoBrowser!(self, photoDidSelectAtIndexPath:NSIndexPath(forItem: self.currentPage, inSection: 0))
        }
        if self.disMissBlock != nil{
            if (self.photos.count == 1) {
                self.currentPage = 0
            }
            self.disMissBlock!(page: self.currentPage)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadData(){
        
        if (self.currentPage >= self.photos.count) {
            self.currentPage = self.photos.count - 1
        }
        self.collectionView.reloadData()
        self.setPageLabelPage(currentPage)
        
        if (self.currentPage >= 0) {
            self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width, 0)
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(0.01 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(), { () -> Void in
                    // 结束动画
                    self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width, 0)
            })
        }
        
    }
    
    
    /// MARK:<UIScrollViewDelegate>
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.isNowRotation == true) {
            self.isNowRotation = false
            return
        }
        var tempF = self.collectionView.frame
        var currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5)
        
        if (tempF.size.width < UIScreen.mainScreen().bounds.size.width){
            tempF.size.width = UIScreen.mainScreen().bounds.size.width
        }

        if ((currentPage < self.photos.count - 1) || self.photos.count == 1) {
            tempF.origin.x = 0;
        }else{
            tempF.origin.x = -MLPhotoPickerCollectionViewPadding;
        }
        
        self.collectionView.frame = tempF;
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var currentPage = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
        if (currentPage == self.photos.count - 2) {
            currentPage = Int(round((scrollView.contentOffset.x) / (scrollView.frame.size.width)))
        }
        
        if (currentPage == self.photos.count - 1 && currentPage != self.currentPage && (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0) {
            self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x + MLPhotoPickerCollectionViewPadding, 0);
        }
        
        self.currentPage = currentPage;
        self.setPageLabelPage(currentPage)
        
        if self.delegate?.respondsToSelector("photoBrowser:scrollEndCurrentPage:") == true{
            self.delegate?.photoBrowser!(self, scrollEndCurrentPage: currentPage)
        }
    }
    
    func changeRotationDirection(noti:NSNotification){
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = MLPhotoPickerCollectionViewPadding
        flowLayout.itemSize = self.view.frame.size
        flowLayout.scrollDirection = .Horizontal
        
        self.collectionView.alpha = 0.0
        self.collectionView.setCollectionViewLayout(flowLayout, animated: true)
        self.isNowRotation = true
        
        if ((self.currentPage < self.photos.count - 1) || self.photos.count == 1) {
            self.collectionView.frame.origin.x = 0;
        }else{
            self.collectionView.frame.origin.x = -MLPhotoPickerCollectionViewPadding;
        }
        self.collectionView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.collectionView.frame.width, 0);
        var currentCell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: self.currentPage, inSection: 0))
        
        for (index,obj) in enumerate(self.collectionView.subviews) {
            var cell = obj as? UICollectionViewCell
            if (cell != nil && cell!.isKindOfClass(UICollectionViewCell.self) == true) {
                cell!.hidden = !cell!.isEqual(currentCell)
                if var scrollView:MLPhotoBrowserPhotoScrollView = cell!.contentView.viewWithTag(101) as? MLPhotoBrowserPhotoScrollView{
                    scrollView.photo = self.photos[self.currentPage]
                }
            }
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.collectionView.alpha = 1.0
        })
    }
    
    func setPageLabelPage(page:NSInteger){
        self.pageLabel.text = "\(page+1) / \(self.photos.count)"
        if (self.isPush != nil || self.isPush == true){
            self.setTitleStr(self.pageLabel.text)
        }
    }
    
    func delete(){
        // 准备删除
        var alertView = UIAlertView(title: "提醒", message: "确定要删除图片", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 1){
            if self.delegate?.respondsToSelector("photoBrowser:removePhotoAtIndexPath:") == true {
                self.delegate!.photoBrowser!(self, removePhotoAtIndexPath: NSIndexPath(forItem: self.currentPage, inSection: 0))
            }

            var page = self.currentPage
            // 删除
            if (self.photos.count > self.currentPage) {
                self.photos.removeAtIndex(self.currentPage)
            }
            
            if (page >= self.photos.count) {
                self.currentPage = self.currentPage - 1
            }
            
            self.status = MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusFade;
            var cell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: page, inSection: 0))
            if (cell != nil) {
                if(cell!.contentView.subviews.last!.isKindOfClass(UIView.self)){
                
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        var view = cell?.contentView.subviews.last as! UIView
                        view.alpha = 0.0
                    }, completion: { (flag) -> Void in
                        self.reloadData()
                    })
                }
            }
            
            if (self.photos.count < 1)
            {
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.dismissViewControllerAnimated(true, completion: nil)
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
            }

        }
    }
    
}

@objc protocol MLPhotoBrowserViewControllerDelegate: NSObjectProtocol {
    /**
    点击某个Item时候调用
    */
    optional func photoBrowser(photoBrowser:MLPhotoBrowserViewController,photoDidSelectAtIndexPath indexPath:NSIndexPath)
    
    /**
    删除某个Item时候调用
    */
    optional func photoBrowser(photoBrowser:MLPhotoBrowserViewController,removePhotoAtIndexPath indexPath:NSIndexPath)
    
    /**
    滚动某个Item时候调用
    */
    optional func photoBrowser(photoBrowser:MLPhotoBrowserViewController,scrollEndCurrentPage page:Int)
}
