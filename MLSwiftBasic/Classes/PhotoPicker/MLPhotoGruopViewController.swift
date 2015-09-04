//
//  MLPhotoGruopViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/28.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import AssetsLibrary

let GroupCellRowHeight:CGFloat = 80
let GroupCellMargin   :CGFloat = 5

class MLPhotoGruopViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate{
    
    /// DAO
    var groups:Array<MLPhotoGroup>!{
        willSet{
            if (newValue == nil) {
                return
            }
            self.groups = newValue
            if ((self.status) != nil) {
                self.jumpToStatusVc()
            }
        }
    }
    
    /// MLPhotoPickerViewController to content Code condition value.
    var maxCount:NSInteger!
    var status:PhotoViewShowStatus!
    var selectPickers:Array<MLPhotoAssets>!
    var topShowPhotoPicker:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupGroups()
    }
    
    func setupGroups(){
        weak var tableView = self.setupTableView()
        // 获取视频
        if self.status == PhotoViewShowStatus.PhotoViewShowStatusVideo{
            MLPhotoPickerDAO().getAllVideoGroups({ [weak self](groups) -> Void in
                self!.groups = groups
                tableView!.reloadData()
            })
        }else{
            // 获取普通的组
            MLPhotoPickerDAO().getAllGroups({ [weak self](groups) -> Void in
                self!.groups = groups
                tableView!.reloadData()
            })
        }
    }
    
    func jumpToStatusVc(){
        // 如果是相册
        var gp:MLPhotoGroup?
        for group in self.groups {
            if ((self.status == PhotoViewShowStatus.PhotoViewShowStatusCameraRoll || self.status == PhotoViewShowStatus.PhotoViewShowStatusVideo) && (group.groupName == "Camera Roll" || group.groupName == "相机胶卷")) {
                gp = group
                break
            }else if (self.status == PhotoViewShowStatus.PhotoViewShowStatusSavePhotos && (group.groupName == "Saved Photos" || group.groupName == "保存相册")){
                gp = group
                break
            }else if (self.status == PhotoViewShowStatus.PhotoViewShowStatusPhotoStream &&  (group.groupName == "Stream" || group.groupName == "我的照片流")){
                gp = group
                break
            }
        }
        
        if (gp == nil) {
            return
        }
        
        var assetsVc = MLPhotoAssetsViewController()
        if var selectPickers = self.selectPickers {
            assetsVc.selectPickerAssets = selectPickers
        }
        assetsVc.status = self.status
        assetsVc.group = gp
        assetsVc.topShowPhotoPicker = self.topShowPhotoPicker
        assetsVc.groupVc = self
        assetsVc.maxCount = self.maxCount
        self.navigationController?.pushViewController(assetsVc, animated: false)
    }
    
    override func titleStr() -> String {
        return "相册组"
    }
    
    override func rightStr() -> String {
        return "取消"
    }
    
    override func rightClick() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupTableView()-> UITableView{
        var tableView = UITableView(frame: self.view.frame, style: .Plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = GroupCellRowHeight
        tableView.separatorStyle = .None
        tableView.registerClass(MLPhotoPickerGroupCell.self, forCellReuseIdentifier: "MLPhotoPickerGroupCell")
        tableView.tableFooterView = UIView()
        self.view.insertSubview(tableView, atIndex: 0)
        return tableView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups == nil ? 0 : self.groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "MLPhotoPickerGroupCell"
        var cell:MLPhotoPickerGroupCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! MLPhotoPickerGroupCell
        // setData
        cell.group = self.groups[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Jump AssetsVc
        var assetsVc = MLPhotoAssetsViewController()
        assetsVc.status = self.status
        if var selectPickers = self.selectPickers {
            assetsVc.selectPickerAssets = selectPickers
        }
        if self.topShowPhotoPicker != nil{
            assetsVc.topShowPhotoPicker = self.topShowPhotoPicker
        }
        assetsVc.groupVc = self
        if self.maxCount != nil{
            assetsVc.maxCount = self.maxCount
        }
        assetsVc.group = self.groups[indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(assetsVc, animated: true)
        
    }
}
