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

class Demo3ViewController: MBBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func rightStr() -> String {
        return "选择相册"
    }
    
    override func rightItemWidth() -> CGFloat {
        return 85
    }
    
    override func titleClick() {
        println("---")
    }
    
    override func rightClick() {
        var pickerVc = MLPhotoPickerViewController()
        pickerVc.showPickerVc(self)
    }
    
    override func titleStr() -> String {
        return "图片选择--未完成/更新中"
    }
}
