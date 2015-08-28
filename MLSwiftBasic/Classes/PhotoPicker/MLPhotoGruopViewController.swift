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
    var groups:Array<MLPhotoGroup>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableView = self.setupTableView()
        MLPhotoPickerDAO.sharedDAO.getAllAsstGroup({ (groups) -> Void in
            self.groups = groups
            tableView.reloadData()
        })
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
