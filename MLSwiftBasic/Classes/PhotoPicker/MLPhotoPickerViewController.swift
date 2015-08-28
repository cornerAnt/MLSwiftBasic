//
//  MLPhotoPickerViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/27.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLPhotoPickerViewController: MBBaseViewController {

    var maxCount:NSInteger!;
    var assetGroupType:NSInteger!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func titleStr() -> String {
        return "选择相册"
    }
    
    func showPickerVc(vc:UIViewController){
        if vc.isKindOfClass(UIViewController.self){
            vc.presentViewController(self, animated: true, completion: nil)
        }
    }

}
