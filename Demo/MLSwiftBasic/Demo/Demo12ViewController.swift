//
//  Demo12ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/4.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import Kingfisher

class Demo12ViewController: MBBaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,MLPhotoBrowserViewControllerDelegate {
    
    var imgUrls:Array<String>!{
        willSet{
            self.collectionView.reloadData()
        }
    }
    
    lazy var photos:Array<MLPhotoBrowser>! = {
        return [
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser(),
            MLPhotoBrowser()
        ]
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgUrls = [
            "http://pic.yupoo.com/hanapp/EUmV5z6n/custom.jpg",
            "http://pic.yupoo.com/hanapp/EUwzhzMl/custom.jpg",
            "http://pic.yupoo.com/hanapp/EUmWibRk/custom.jpg",
            "http://pic.yupoo.com/hanapp/EUlRMpa3/custom.jpg",
            "http://caodan.org/wp-content/uploads/vol/1057.jpg",
            "http://caodan.org/wp-content/uploads/vol/1055.jpg",
            "http://caodan.org/wp-content/uploads/vol/1053.jpg",
            "http://caodan.org/wp-content/uploads/vol/1051.jpg",
            "http://caodan.org/wp-content/uploads/vol/1050.jpg"
        ]
    }
    
    lazy var collectionView:UICollectionView = {
        var flowLayout = UICollectionViewFlowLayout()
        var showColumn:CGFloat = 3
        var margin:CGFloat = 10
        var width = (self.view.frame.width - showColumn * margin) / showColumn
        flowLayout.itemSize = CGSizeMake(width, width)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.scrollDirection = .Vertical
        
        var collectionView:UICollectionView = UICollectionView(frame: CGRectMake(0, TOP_Y + margin, self.view.frame.width, self.view.frame.height - TOP_Y), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(collectionView)
        return collectionView
        }()
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var imageBtn:UIButton = UIButton(frame: cell.bounds)
        imageBtn.clipsToBounds = true
        imageBtn.tag = indexPath.row
        imageBtn.imageView!.contentMode = .ScaleAspectFill
        imageBtn.kf_setImageWithURL(NSURL(string: self.imgUrls[indexPath.row])!, forState: .Normal)
        imageBtn.addTarget(self, action: "openPhotoBrowser:", forControlEvents: .TouchUpInside)
        cell.contentView.addSubview(imageBtn)
        
        var photo = self.photos[indexPath.row]
        photo.photoURL = NSURL(string: self.imgUrls[indexPath.row])!
        photo.toView = imageBtn.imageView!
        
        return cell
    }
    
    func openPhotoBrowser(imageBtn:UIButton){
        var photoBrowserVc = MLPhotoBrowserViewController()
        // 代理(删除/点击/滑动Item调用)
        photoBrowserVc.delegate = self
        // 动画模式
        photoBrowserVc.status = MLPhotoBrowserAnimationAnimationStatus.MLPhotoBrowserAnimationAnimationStatusFade
        // 需要的图片数组 Array<MLPhotoBrowser>
        photoBrowserVc.photos = self.photos
        // 是否可以删除图片
        photoBrowserVc.isDeletePhotoMode = true
        // 当前展示的第几页
        photoBrowserVc.currentPage = imageBtn.tag
        // Push展示
        photoBrowserVc.showPushVc(self)
    }
    
    override func titleStr() -> String {
        return "图片浏览器/Push模式"
    }
    
    func photoBrowser(photoBrowser: MLPhotoBrowserViewController, removePhotoAtIndexPath indexPath: NSIndexPath) {
        self.imgUrls.removeAtIndex(indexPath.row)
        self.photos.removeAtIndex(indexPath.row)
        self.collectionView.reloadData()
    }
}
