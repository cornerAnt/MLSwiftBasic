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

class MLPhotoPickerBrowserViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    var photos:Array<MLPhotoAssets>!{
        willSet{
            
        }
    }
    var isEditing:Bool!
    var currentPage:Int?
    
    /// lazy
    lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = MLPhotoPickerBrowserCellPadding
        flowLayout.itemSize = self.view.frame.size
        flowLayout.scrollDirection = .Horizontal
        
        var collectionView:UICollectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.width + MLPhotoPickerBrowserCellPadding, self.view.frame.height), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: MLPhotoPickerBrowserCellIdentifier)
        self.view.addSubview(collectionView)

        if self.isEditing == true {
            self.maskView.hidden = !(self.photos.count > 0 && self.isEditing == true)
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

    func setupToolBar(){
        var toolbar = UIToolbar(frame: CGRectMake(0, self.view.frame.height - CGFloat(KMLPhotoAssetsToolBarHeight), self.view.frame.width, CGFloat(KMLPhotoAssetsToolBarHeight)))
        toolbar.barTintColor = UIColor(rgba: "999999")
        // 中间距 右视图
        var fiexItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var rightItem:UIBarButtonItem = UIBarButtonItem(customView: self.doneBtn)
        self.setBarButtonItemState(false)
        
        toolbar.setItems([fiexItem,rightItem], animated: false)
        self.view.addSubview(toolbar)
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
        
        return cell
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
