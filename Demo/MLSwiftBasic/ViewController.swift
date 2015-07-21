//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//
//  ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/6.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit



class ViewController: MBBaseViewController {

    /// example list
    lazy var lists:NSArray = {
        return ["demo1_自定义按钮",
                "demo2_毛玻璃与透明导航栏",
                "demo3_多个Item",
                "demo4_下拉刷新/上拉加载更多（效果1）",
                "demo5_视觉动画",
                "demo6_渐变导航栏效果",
                "demo7_下拉刷新/上拉加载更多（效果2）"
               ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
    
    /**
    All Title
    
    :returns: 返回Navigation的Items文字/图片
    */
    override func leftImg() -> String {
        return "makezl.jpeg"
    }
    
    override func rightStr() -> String {
        return "^_^"
    }
    
    override func titleStr() -> String {
        return "ML"
    }
    
    /**
    All Event
    
    :returns: 监听点击事件
    */
    override func leftClick() {
        println("你点击了左边")
    }
    
    override func rightClick() {
        println("你点击了右边")
    }
    
    override func titleClick() {
        println("你点击了标题")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.lists[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(Demo1ViewController(), animated: true)
        }else if indexPath.row == 1 {
            self.navigationController?.pushViewController(Demo2ViewController(), animated: true)
        }else if indexPath.row == 2 {
            self.navigationController?.pushViewController(Demo3ViewController(), animated: true)
        }else if indexPath.row == 3 {
            self.navigationController?.pushViewController(Demo4ViewController(), animated: true)
        }else if indexPath.row == 4 {
            self.navigationController?.pushViewController(Demo5ViewController(), animated: true)
        }else if indexPath.row == 5 {
            self.navigationController?.pushViewController(Demo6ViewController(), animated: true)
        }else if indexPath.row == 6 {
            self.navigationController?.pushViewController(Demo7ViewController(), animated: true)
        }
    }
}

