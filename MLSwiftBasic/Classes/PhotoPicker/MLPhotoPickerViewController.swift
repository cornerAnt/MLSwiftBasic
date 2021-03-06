//
//  MLPhotoPickerViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/27.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

let MLPhotoTakeDone = "MLPhotoTakeDone"
let MLPhotoTakeRefersh = "MLPhotoTakeRefersh"

// 状态组
enum PhotoViewShowStatus:Int {
    case PhotoViewShowStatusGroup       = 0 // default groups .
    case PhotoViewShowStatusCameraRoll  = 1
    case PhotoViewShowStatusSavePhotos  = 2
    case PhotoViewShowStatusPhotoStream = 3
    case PhotoViewShowStatusVideo       = 4
}

protocol MLPhotoPickerViewControllerDelegate: NSObjectProtocol{
    func photoPickerViewControllerDoneAssets(assets:Array<MLPhotoAssets>)
}

class MLPhotoPickerViewController: MBBaseViewController {
    
    var pickerGroupVc:MLPhotoGruopViewController!
    
    /// Select Photo maxCount , default is 9
    var maxCount:NSInteger!{
        willSet{
            pickerGroupVc.maxCount = newValue
        }
    }
    
    var status:PhotoViewShowStatus!{
        willSet{
            pickerGroupVc.status = newValue
        }
    }
    
    var selectPickers:Array<MLPhotoAssets>?{
        willSet{
            if newValue != nil {
                pickerGroupVc.selectPickers = newValue
            }
        }
    }
    
    var topShowPhotoPicker:Bool!{
        willSet{
            pickerGroupVc.topShowPhotoPicker = newValue
        }
    }
    
    // callback
    weak var delegate:MLPhotoPickerViewControllerDelegate?
    var callBackBlock: ((assets:Array<MLPhotoAssets>) -> Void)!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil) 
        self.createNavigationController()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func rightStr() -> String {
        return "取消"
    }
    
    override func rightClick() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotification()
    }
    
    func createNavigationController(){
        pickerGroupVc = MLPhotoGruopViewController()
        var navigationVc = MBNavigationViewController(rootViewController: pickerGroupVc)
        navigationVc.view.frame = self.view.frame
        self.addChildViewController(navigationVc)
        self.view.addSubview(navigationVc.view)
    }
    
    func showPickerVc(vc:UIViewController){
        weak var viewController = vc
        if viewController!.isKindOfClass(UIViewController.self){
            viewController!.presentViewController(self, animated: true, completion: nil)
        }
    }
    
    func addNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "done:", name: MLPhotoTakeDone, object: nil)
    }
    
    func done(noti:NSNotification){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var userInfo = noti.userInfo as! [NSObject: Array<MLPhotoAssets>]
            var assets = userInfo["selectAssets"]
            if (self.delegate?.respondsToSelector("photoPickerViewControllerDoneAssets:") != nil) {
                self.delegate?.photoPickerViewControllerDoneAssets(assets!)
            }else if(self.callBackBlock != nil){
                self.callBackBlock(assets:assets!)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    deinit{
        self.removeFromParentViewController()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
