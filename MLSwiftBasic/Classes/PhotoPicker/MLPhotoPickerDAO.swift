//
//  MLPhotoPickerDAO.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/27.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import AssetsLibrary

class MLPhotoGroup: NSObject {
    /// ALAssetsGroup
    var group:ALAssetsGroup!
    /// ALAssetsGroup Name
    lazy var groupName:String = {
        return self.group.valueForProperty("ALAssetsGroupPropertyName") as! String
    }()
    /// ALAssetsGroup ThumbImage
    lazy var thumbImage:UIImage = {
        return UIImage(CGImage: self.group.posterImage().takeUnretainedValue())!
    }()
    /// ALAssetsGroup subAssetsCount
    lazy var assetsCount:NSInteger = {
        return self.group.numberOfAssets()
    }()

    /// Init
    init(group:ALAssetsGroup) {
        super.init()
        self.group = group
    }
}

class MLPhotoPickerDAO: NSObject {
    /// Signle AssetsLibrary Object.
    class var sharedDAO:MLPhotoPickerDAO{
        struct staic {
            static var onceToken:dispatch_once_t = 0
            static var instance:MLPhotoPickerDAO?
        }
        dispatch_once(&staic.onceToken, { () -> Void in
            staic.instance = MLPhotoPickerDAO()
        })
        return staic.instance!
    }
    
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
    func getAllAsstGroup(groupsCallBack :((groups:Array<MLPhotoGroup>) -> Void)){
        var groups:NSMutableArray = NSMutableArray()
        var resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                var gp = MLPhotoGroup(group: group)
                groups.addObject(gp)
            }else{
                var tempGroups = NSArray(array: groups)
                groupsCallBack(groups:tempGroups as! Array<MLPhotoGroup>)
            }
        }
        self.sharedAssetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:resultBlock, failureBlock: nil)
    }
}
