//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//
//  Demo7ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/6.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

/// 上拉加载更多/下拉刷新Demo Refresh
class Demo7ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate{
    
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
        
        // 上拉动画
       tableView.headerViewRefreshAnimationStatus(.headerViewRefreshArrowAnimation, images: [])
        
        // 上啦加载更多
        tableView.toLoadMoreAction({[weak tableView] () -> () in
            println("toLoadMoreAction success")
            if self.listsCount == 100{
                // 表示数据加载完毕
                tableView!.endLoadMoreData()
            }else{
                self.listsCount += 20
            }
            
            // 结束动画
            tableView!.doneRefresh()
            tableView!.reloadData()
        })
        
        // 及时上拉刷新
        tableView.nowRefresh({ [weak tableView]() -> Void in
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(2.0 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(), { () -> Void in
                    // 结束动画
                    tableView!.doneRefresh()
            })
        })
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        return "下拉刷新/上拉加载更多 效果2"
    }
}
