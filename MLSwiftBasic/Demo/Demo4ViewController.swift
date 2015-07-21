//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//
//  Demo4ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/6.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

/// 上拉加载更多/下拉刷新Demo Refresh
class Demo4ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate{
    
    var listsCount = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavBarViewBackgroundColor(UIColor(rgba: "0c8eee"))
        self.setupTableView()
    }
    
    func setupTableView(){
        var tableView = UITableView(frame: self.view.frame, style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.insertSubview(tableView, atIndex: 0)
        
        // 进入下拉刷新状态
        tableView.nowRefresh { () -> Void in
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(2.0 * Double(NSEC_PER_SEC))
            ), dispatch_get_main_queue(), { () -> Void in
                // 结束动画
                tableView.doneRefresh()
            })
        }
        
        // 上拉加载更多
        tableView.toLoadMoreAction { () -> Void in
            // 结束动画
            tableView.doneRefresh()
            tableView.reloadData()
            // 假设服务器就100条数据
            if self.listsCount == 100{
                // 表示数据加载完毕
                tableView.endLoadMoreData()
            }else{
                self.listsCount += 20
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "Test \(indexPath.row)"
        return cell
    }
    
    override func titleStr() -> String {
        return "下拉刷新/上拉加载更多"
    }
}
