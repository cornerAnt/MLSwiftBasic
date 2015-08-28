//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//  
//  Demo8ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/23.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

/// 上拉加载更多/下拉刷新Demo Refresh
class Demo8ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate{
    
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
        
        
        
        // 自定义动画，需要传个数组
        var animationImages = [UIImage]()
        for i in 0..<73{
            var str = "PullToRefresh_00\(i)"
            if (i > 9){
                str = "PullToRefresh_0\(i)"
            }
            
            if var image = UIImage(named: ZLSwiftRefreshBundleName.stringByAppendingPathComponent(str)) {
                animationImages.append(image)
            }
        }
        // 上拉动画
        tableView.headerViewRefreshAnimationStatus(.headerViewRefreshPullAnimation, images: animationImages)
        
        // 加载动画
        var loadAnimationImages = [UIImage]()
        for i in 73..<141{
            var str = "PullToRefresh_0\(i)"
            if (i > 99){
                str = "PullToRefresh_\(i)"
            }
            if var image = UIImage(named: ZLSwiftRefreshBundleName.stringByAppendingPathComponent(str)){
                loadAnimationImages.append(image)
            }
        }
        tableView.headerViewRefreshAnimationStatus(.headerViewRefreshLoadingAnimation, images: loadAnimationImages)
        
        // 上啦加载更多
        tableView.toLoadMoreAction({ () -> () in
            println("toLoadMoreAction success")
            if (self.listsCount < 100){
                self.listsCount += 20
                tableView.reloadData()
                tableView.doneRefresh()
            }else{
                tableView.endLoadMoreData()
            }
        })
        
        // 及时上拉刷新
        tableView.nowRefresh({ () -> Void in
            println(" --- ")
            dispatch_after(dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(2.0 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(), { () -> Void in
                    // 结束动画
                    tableView.doneRefresh()
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
