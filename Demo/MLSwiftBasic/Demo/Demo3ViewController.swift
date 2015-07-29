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

class Demo3ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate {

    lazy var lists = {
       return ["提示成功","提示成功延时2秒","提示失败","提示失败延时2秒","提示进度条","提示进度条延时2秒","等待"]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
    }
    
    func setupTableView(){
        var tableView = UITableView(frame: self.view.frame, style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.insertSubview(tableView, atIndex: 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = lists[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == 0){
            MLProgressHUD.showSuccessMessage("请求成功..")
        }else if (indexPath.row == 1){
            MLProgressHUD.showSuccessMessage("请求成功..", durationAfterDismiss: 2.0)
        }else if (indexPath.row == 2){
            MLProgressHUD.showErrorMessage("请求失败..")
        }else if (indexPath.row == 3){
            MLProgressHUD.showErrorMessage("请求失败..", durationAfterDismiss: 2.0)
        }else if (indexPath.row == 4){
            MLProgressHUD.showProgress(0.5, message: "已经缓冲到\(0.5 * 100)%")
        }else if (indexPath.row == 5){
            MLProgressHUD.showProgress(0.9, message: "已经缓冲到\(0.9 * 100)%", durationAfterDismiss: 2.0)
        }else if (indexPath.row == 6){
            MLProgressHUD.showWaiting()
        }
    }
    
    override func titleStr() -> String {
        return "Demo3 HUD"
    }
}
