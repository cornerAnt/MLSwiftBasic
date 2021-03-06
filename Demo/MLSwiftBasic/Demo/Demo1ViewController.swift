//  github: https://github.com/MakeZL/MLSwiftBasic
//  author: @email <120886865@qq.com>
//
//  Demo1ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/6.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class Demo1ViewController: MBBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func titleImg() -> String {
        return "makezl.jpeg"
    }
    
    override func rightTitles() -> NSArray {
        return ["Make", "ZL"]
    }
    
    override func titleClick() {
        println("监听事件..")
    }
    
    override func rightClickAtIndexBtn(button: UIButton) {
        println("点击了btn")
        println(button)
    }
    
    override func rightItemWidth() -> CGFloat {
        // Default return 45
        return 50
    }
    
}
