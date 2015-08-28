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
    var pickerGroupVc:MLPhotoGruopViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil) 
        self.createNavigationController()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createNavigationController(){
        pickerGroupVc = MLPhotoGruopViewController()
        var navigationVc = MBNavigationViewController(rootViewController: pickerGroupVc)
        navigationVc.view.frame = self.view.frame
        self.addChildViewController(navigationVc)
        self.view.addSubview(navigationVc.view)
    }
    
    func showPickerVc(vc:UIViewController){
        if vc.isKindOfClass(UIViewController.self){
            vc.presentViewController(self, animated: true, completion: nil)
        }
    }

}
