//
//  MLPhotoPickerBrowserViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/31.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

let MLPhotoPickerBrowserCellPadding:CGFloat = 20
let MLPhotoPickerBrowserCellIdentifier = "MLPhotoPickerCellIdentifier"

class MLPhotoPickerBrowserViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,MLPhotoPickerBrowserScrollViewDelegate {

    var doneAssets:Array<MLPhotoAssets>!
    var photos:Array<MLPhotoAssets>!{
        willSet{
            self.doneAssets = newValue
            self.reloadData()
        }
    }
    
    var isShowShowSheet:Bool?
    var sheet:UIActionSheet?
    var isEditing:Bool!
    var currentPage:Int?
    
    /// lazy
    lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = MLPhotoPickerBrowserCellPadding
        flowLayout.itemSize = self.view.frame.size
        flowLayout.scrollDirection = .Horizontal
        
        var collectionView:UICollectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width + MLPhotoPickerBrowserCellPadding, self.view.frame.height), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: MLPhotoPickerBrowserCellIdentifier)
        self.view.addSubview(collectionView)

        if self.isEditing == true {
            self.maskView.hidden = !(self.photos != nil && self.photos.count > 0)
            // 初始化底部ToolBar
            self.setupToolBar()
        }
        return collectionView
    }()
    
    lazy var maskView:UIView = {
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
    
    var toolBar:UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupToolBar(){
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.height - CGFloat(KMLPhotoAssetsToolBarHeight), self.view.frame.width, CGFloat(KMLPhotoAssetsToolBarHeight)))
        toolBar.barTintColor = UIColor(rgba: "999999")
        // 中间距 右视图
        var fiexItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var rightItem:UIBarButtonItem = UIBarButtonItem(customView: self.doneBtn)
        self.setBarButtonItemState(false)
        
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
            
            var scrollBoxView = UIView(frame: UIScreen.mainScreen().bounds)
            cell.contentView.addSubview(scrollBoxView)
            
            var scrollView = MLPhotoPickerBrowserScrollView(frame: UIScreen.mainScreen().bounds)
            if (self.sheet != nil || self.isShowShowSheet == true) {
                scrollView.sheet = self.sheet;
            }
            scrollView.backgroundColor = UIColor.clearColor()
            // 为了监听单击photoView事件
            scrollView.photoScrollViewDelegate = self
            scrollView.photo = photo
            scrollBoxView.addSubview(scrollView)
            scrollView.autoresizingMask = .FlexibleHeight | .FlexibleWidth;
        }
        
        return cell
    }
    
    func pickerPhotoScrollViewDidSingleClick() {
        self.navigationController!.navigationBar.hidden = !self.navigationController!.navigationBar.hidden
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
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var currentPage:Int = Int(scrollView.contentOffset.x / (scrollView.frame.width - MLPhotoPickerBrowserCellPadding))
        var isGtSystem8:Bool = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0
        
        if (currentPage == self.photos.count - 1 && currentPage != self.currentPage && isGtSystem8 == true) {
            self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
        }
        self.currentPage = currentPage;
//        [self setPageLabelPage:currentPage];
    }
}
