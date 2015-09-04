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

class MLPhotoPickerDAO: NSObject {
    /// Signle AssetsLibrary Object.
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
    获取所有的Group视频模型
    
    :param: groups 数组
    */
    func getAllVideoGroups(groupsCallBack :((groups:Array<MLPhotoGroup>) -> Void)){
        var groups:Array = Array<MLPhotoGroup>()
        var resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                group.setAssetsFilter(ALAssetsFilter.allVideos())
                var gp = MLPhotoGroup()
                gp.isVideo = true
                gp.group = group
                groups.append(gp)
            }else{
                groupsCallBack(groups:groups)
            }
        }
        MLPhotoPickerDAO.sharedAssetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:resultBlock, failureBlock: nil)
    }
    
    /**
    获取所有的Group模型
    
    :param: groups 数组
    */
    func getAllGroups(groupsCallBack :((groups:Array<MLPhotoGroup>) -> Void)){
        var groups:Array = Array<MLPhotoGroup>()
        var resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = { (group, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                var gp = MLPhotoGroup()
                gp.group = group
                gp.isVideo = false
                groups.append(gp)
            }else{
                groupsCallBack(groups:groups)
            }
        }
        MLPhotoPickerDAO.sharedAssetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:resultBlock, failureBlock: nil)
    }
    
    /**
    获取Group中所有Assets模型
    
    :param: groups 数组
    */
    func getAllAssetsWithGroup(group:MLPhotoGroup, assetsCallBack :((assets:Array<MLPhotoAssets>) -> Void)){
        var assets:Array = Array<MLPhotoAssets>()
        var resultBlock:ALAssetsGroupEnumerationResultsBlock = { (asset, index, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if (asset != nil) {
                
                var photoAssets = MLPhotoAssets()
                /**
                *  ALAssetTypePhoto, ALAssetTypeVideo or ALAssetTypeUnknown.
                */
                if (asset.valueForProperty(ALAssetPropertyType).isEqual(ALAssetTypePhoto)){
                    photoAssets.isVideo = false
                }else if (asset.valueForProperty(ALAssetPropertyType).isEqual(ALAssetTypeVideo)){
                    photoAssets.isVideo = true
                }else{
                    photoAssets.isVideo = group.isVideo
                }
                photoAssets.asset = asset
                assets.append(photoAssets)
            }else{
                assetsCallBack(assets: assets)
            }
        }
        group.group?.enumerateAssetsUsingBlock(resultBlock)
    }
}

class MLPhotoGroup: NSObject {
    /// ALAssetsGroup
    var group:ALAssetsGroup?
    var isVideo:Bool?
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

class MLPhotoAssets: NSObject{
    var asset:ALAsset!
    // 包装的Image
    var image:UIImage!
    var isVideo:Bool?
    
    lazy var thumbImage:UIImage? = {
        if self.asset != nil {
            var imgRef = self.asset!.thumbnail().takeUnretainedValue()
            let img = UIImage(CGImage: imgRef)
            return img!
        }else{
            return self.image
        }
    }()
    
    lazy var originalImage:UIImage? = {
        if self.asset != nil {
            return UIImage(CGImage: self.asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        }else{
            return self.image
        }
    }()
}
