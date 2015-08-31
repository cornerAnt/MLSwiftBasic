//
//  MLPhotoPickerDAO.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/27.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit
import AssetsLibrary

let MLPhotoPickerBundleName = "MLPhotoPicker.bundle"

class MLPhotoGroup: NSObject {
    /// ALAssetsGroup
    var group:ALAssetsGroup?
    /// ALAssetsGroup Name
    lazy var groupName:String = {
        return self.group?.valueForProperty("ALAssetsGroupPropertyName") as! String
    }()
    /// ALAssetsGroup ThumbImage
    lazy var thumbImage:UIImage = {
        return UIImage(CGImage: self.group?.posterImage().takeUnretainedValue())!
    }()
    /// ALAssetsGroup subAssetsCount
    lazy var assetsCount:NSInteger = {
        return self.group?.numberOfAssets()
    }()!

}

class MLPhotoPickerDAO: NSObject {
    /// Signle AssetsLibrary Object.
//    class var sharedDAO:MLPhotoPickerDAO{
//        struct staic {
//            static var onceToken:dispatch_once_t = 0
//            static var instance:MLPhotoPickerDAO?
//        }
//        dispatch_once(&staic.onceToken, { () -> Void in
//            staic.instance = MLPhotoPickerDAO()
//        })
//        return staic.instance!
//    }
    
    class var sharedAssetsLibrary:ALAssetsLibrary{
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
    func getAllGroups(groupsCallBack :((groups:Array<MLPhotoGroup>) -> Void)){
        var groups:NSMutableArray = NSMutableArray()
        var resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                var gp = MLPhotoGroup()
                gp.group = group
                groups.addObject(gp)
            }else{
                var gps = NSMutableArray(array: groups)
                groups.removeAllObjects()
                var tempGroups = NSArray(array: gps)
                groupsCallBack(groups:tempGroups as! Array<MLPhotoGroup>)
            }
        }
        MLPhotoPickerDAO.sharedAssetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:resultBlock, failureBlock: nil)
    }
    
    /**
    获取所有的Group模型
    
    :param: groups 数组
    */
    func getAllAssetsWithGroup(group:MLPhotoGroup, assetsCallBack :((assets:Array<MLPhotoAssets>) -> Void)){
        var assets:NSMutableArray = NSMutableArray()
        var resultBlock:ALAssetsGroupEnumerationResultsBlock = { (asset, index, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if (asset != nil) {
                var photoAssets = MLPhotoAssets()
                photoAssets.asset = asset
                assets.addObject(photoAssets)
            }else{
                var realAssets = NSMutableArray(array: assets)
                assets.removeAllObjects()
                var tempAssets = NSArray(array: realAssets)
                assetsCallBack(assets: tempAssets as! Array<MLPhotoAssets>)
            }
        }
        group.group?.enumerateAssetsUsingBlock(resultBlock)
    }
}

class MLPhotoAssets: NSObject{
    var asset:ALAsset!
    lazy var thumbImage:UIImage? = {
        if self.asset != nil {
            return UIImage(CGImage: self.asset!.thumbnail().takeUnretainedValue())!
        }else{
            return nil
        }
    }()
    
    lazy var originalImage:UIImage? = {
        if self.asset != nil {
            return UIImage(CGImage: self.asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        }else{
            return nil
        }
    }()
}
