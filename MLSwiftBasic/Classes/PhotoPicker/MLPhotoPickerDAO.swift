//
//  MLPhotoPickerDAO.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/27.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import AssetsLibrary

class MLPhotoPickerDAO: NSObject {
    
    /// Signle AssetsLibrary Object.
    var sharedAssetsLibrary:ALAssetsLibrary{
        struct staic {
            static var onceToken:dispatch_once_t = 0
            static var instance:ALAssetsLibrary?
        }
        dispatch_once(&staic.onceToken, { () -> Void in
            staic.instance = ALAssetsLibrary()
        })
        return staic.instance!
    }
    
    /**
    获取所有的Group模型
    
    :param: groups 数组
    */
    func getAllAsstGroup(groupsCallBack :((groups:Array<ALAssetsGroup>) -> Void)){
        var groups:NSMutableArray = NSMutableArray()
        var resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if group == nil {
                groups.addObject(group)
            }else{
                var gps = NSArray(array: groups)
                groupsCallBack(groups:gps as! Array<ALAssetsGroup>)
            }
        }

        self.sharedAssetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:resultBlock, failureBlock: nil)
    }
    
    
    
}
