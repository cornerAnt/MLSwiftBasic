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

class MBExample: NSObject {
    var title:String!
    var vc:UIViewController?
}

class ViewController: MBBaseViewController {
    
    /// example list
    var lists:NSArray {
        get {
            var example1:MBExample = MBExample()
            example1.title = "Demo1 (导航栏.标题/图片.设置按钮宽度等)"
            example1.vc = Demo1ViewController()
            
            var example2:MBExample = MBExample()
            example2.title = "Demo2 (图片浏览器待完成)"
            example2.vc = Demo2ViewController()
            
            var example3:MBExample = MBExample()
            example3.title = "Demo3 (相册多选)"
            example3.vc = Demo3ViewController()
            
            var example4:MBExample = MBExample()
            example4.title = "Demo4 (导航视觉效果1)"
            example4.vc = Demo4ViewController()
            
            var example5:MBExample = MBExample()
            example5.title = "Demo5 (导航视觉效果2)"
            example5.vc = Demo5ViewController()
            
            var example6:MBExample = MBExample()
            example6.title = "Demo6 (下拉刷新/加载更多 效果1)"
            example6.vc = Demo6ViewController()
            
            var example7:MBExample = MBExample()
            example7.title = "Demo7 (下拉刷新/加载更多 效果2)"
            example7.vc = Demo7ViewController()
            
            var example8:MBExample = MBExample()
            example8.title = "Demo8 (下拉刷新/加载更多 自定义动画)"
            example8.vc = Demo8ViewController()
            
            return [example1,example2,example3,example4,example5,example6,example7,example8]
        }
        
        set{
            
        }
    };
    
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
        return "MLSwiftBasic Framework!"
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
        var example:MBExample = self.lists[indexPath.row] as! MBExample
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = example.title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var example:MBExample = self.lists[indexPath.row] as! MBExample
        self.navigationController?.pushViewController(example.vc!, animated: true)
    }
}

