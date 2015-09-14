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

class MBExampleGroup: NSObject {
    var groupName:String?
    var examples:Array<MBExample>?
}

class MBExample: NSObject {
    var title:String!
    var vc:UIViewController?
}

class ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    /// example list
    var lists:Array<MBExampleGroup>{
        get{
            // Group1 : <Navigation 导航栏>
            var groupItem00:MBExample = MBExample()
            groupItem00.title = "Demo1 (导航栏.标题/图片.设置按钮宽度等)"
            groupItem00.vc = Demo1ViewController()
            // create Group
            var group0 = MBExampleGroup()
            group0.groupName = "导航栏"
            group0.examples = [groupItem00]
            
            // Group2 : <Photo Picker 相册多选>
            var groupItem10:MBExample = MBExample()
            groupItem10.title = "Demo2 (相册多选1/简单效果)"
            groupItem10.vc = Demo2ViewController()
            var groupItem11:MBExample = MBExample()
            groupItem11.title = "Demo3 (相册多选2/复杂效果)"
            groupItem11.vc = Demo3ViewController()
            var groupItem12:MBExample = MBExample()
            groupItem12.title = "Demo9 (相册多选3/选择视频)"
            groupItem12.vc = Demo9ViewController()
            // create Group
            var group1 = MBExampleGroup()
            group1.groupName = "相册多选"
            group1.examples = [groupItem10,groupItem11,groupItem12]
            
            // Group3 : <Visual 导航栏>
            var groupItem20:MBExample = MBExample()
            groupItem20.title = "Demo4 (导航视觉效果1)"
            groupItem20.vc = Demo4ViewController()
            var groupItem21:MBExample = MBExample()
            groupItem21.title = "Demo5 (导航视觉效果2)"
            groupItem21.vc = Demo5ViewController()
            // create Group
            var group2 = MBExampleGroup()
            group2.groupName = "导航视觉效果"
            group2.examples = [groupItem20,groupItem21]
            
            // Group4 : <Refresh 下拉刷新>
            var groupItem30:MBExample = MBExample()
            groupItem30.title = "Demo6 (下拉刷新/加载更多 效果1)"
            groupItem30.vc = Demo6ViewController()
            var groupItem31:MBExample = MBExample()
            groupItem31.title = "Demo7 (下拉刷新/加载更多 效果2)"
            groupItem31.vc = Demo7ViewController()
            var groupItem32:MBExample = MBExample()
            groupItem32.title = "Demo8 (下拉刷新/加载更多 自定义动画)"
            groupItem32.vc = Demo8ViewController()
            // create Group
            var group3 = MBExampleGroup()
            group3.groupName = "下拉刷新"
            group3.examples = [groupItem30,groupItem31,groupItem32]
            
            // Group5 : <Browser 图片浏览器>
            var groupItem40:MBExample = MBExample()
            groupItem40.title = "Demo10 (图片浏览器/放大缩小)"
            groupItem40.vc = Demo10ViewController()
            
            var groupItem41:MBExample = MBExample()
            groupItem41.title = "Demo11 (图片浏览器/淡入淡出)"
            groupItem41.vc = Demo11ViewController()
            
            var groupItem42:MBExample = MBExample()
            groupItem42.title = "Demo12 (图片浏览器/Push模式)"
            groupItem42.vc = Demo12ViewController()
            
            var group4 = MBExampleGroup()
            group4.groupName = "《图片浏览器》"
            group4.examples = [groupItem40,groupItem41,groupItem42]
            
            // Group6 : <HUD 提示器>
            var group5 = MBExampleGroup()
            group5.groupName = "《HUD》"
            group5.examples = []
            
            // Group7 : <Address 通讯录>
            var group6 = MBExampleGroup()
            group6.groupName = "《自定义通讯录》"
            group6.examples = []
            
            // Group8 : <Property 字典转模型>
            var groupItem70:MBExample = MBExample()
            groupItem70.title = "Demo13 字典转模型 - Meters"
            groupItem70.vc = Demo13ViewController()
            
            var group7 = MBExampleGroup()
            group7.groupName = "《字典转模型》"
            group7.examples = [groupItem70]
            
            // Group9 : <Property 字典转模型>
            var group8 = MBExampleGroup()
            group8.groupName = "《某某某》项目实践"
            group8.examples = []
            
            return [group7,group1,group4,group2,group3,group0,group5,group6,group8
            ]
        }
        
        set{
            
        }
    }
    
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
    
    // MARK: <UITableViewDataSource>
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.lists.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var group:MBExampleGroup = self.lists[section]
        return group.examples!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        
        var group:MBExampleGroup = self.lists[indexPath.section]
        var example:MBExample = group.examples![indexPath.row]
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = example.title
        return cell
    }
    
    // MARK: <UITableViewDelegate>
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var group:MBExampleGroup = self.lists[indexPath.section]
        var example:MBExample = group.examples![indexPath.row]
        self.navigationController?.pushViewController(example.vc!, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var group:MBExampleGroup = self.lists[section]
        return group.groupName
    }
}

