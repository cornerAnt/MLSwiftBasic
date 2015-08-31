//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//
//  Demo3ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/6.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class Demo3ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate,MLPhotoPickerViewControllerDelegate {
    
    var assets:Array<MLPhotoAssets>!
    lazy var tableView:UITableView = {
        var tableView:UITableView = UITableView(frame: CGRectMake(0, TOP_Y, self.view.frame.width, self.view.frame.height - TOP_Y), style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        // Test Show
        var asset:MLPhotoAssets = self.assets[indexPath.row]
        cell.imageView?.contentMode = .ScaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.image = asset.thumbImage
        
        return cell
    }
    
    override func rightStr() -> String {
        return "选择相册"
    }
    
    override func rightItemWidth() -> CGFloat {
        return 85
    }
    
    /**
    RightClick
    */
    override func rightClick() {
        var pickerVc = MLPhotoPickerViewController()
        // Jumop to CameraRoll Group.
        pickerVc.status = .PhotoViewShowStatusCameraRoll
        // Show Camera. Default false
        pickerVc.topShowPhotoPicker = true
        pickerVc.selectPickers = self.assets
        // MakeZL :CallBack delegate or block 👇 block
        /**
            block:
            pickerVc.callBackBlock = {(assets:Array<MLPhotoAssets>) -> Void in
                // like this .
                self.assets = assets
                self.tableView.reloadData()
            }
        */
        pickerVc.delegate = self
        // 限制选择图片的个数,不传是默认是9
        pickerVc.maxCount = 5
        pickerVc.showPickerVc(self)
    }
    
    // MARK:: <MLPhotoPickerViewControllerDelegate>
    func photoPickerViewControllerDoneAssets(assets: Array<MLPhotoAssets>) {
        self.assets = assets
        self.tableView.reloadData()
    }
    
    override func titleStr() -> String {
        return "图片选择--未完成/更新中"
    }
}
