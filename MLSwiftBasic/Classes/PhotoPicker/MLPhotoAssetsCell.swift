//
//  MLPhotoAssetsCell.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/28.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLPhotoAssetsCell: UICollectionViewCell {
    /// Lazy
    lazy var thumbImageView:MLPhotoPickerCellImageView = {
        var thumbImageView = MLPhotoPickerCellImageView(frame: self.bounds)
        self.contentView.addSubview(thumbImageView)
        return thumbImageView
    }()
    
    var assets:MLPhotoAssets?{
        willSet{
            if var asset:MLPhotoAssets = newValue {
                thumbImageView.image = asset.thumbImage
            }
        }
    }
}

class MLPhotoPickerCellImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMaskSelected = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var maskImageView:UIImageView = {
        var maskImageView = UIImageView(frame: CGRectMake(self.frame.width - 30, 0, 30, 30))
        if var image = UIImage(named: MLPhotoPickerBundleName.stringByAppendingPathComponent("AssetsPickerChecked")){
            maskImageView.image = image
        }
        self.addSubview(maskImageView)
        return maskImageView
    }()
    
    var isMaskSelected:Bool!{
        willSet{
            self.maskImageView.hidden = !newValue
            
            if newValue == true {
                self.maskImageView.layer.removeAllAnimations()
                var scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                scaleAnimation.duration = 0.25
                scaleAnimation.autoreverses = true
                scaleAnimation.values = [
                    NSNumber(float: 1.0),
                    NSNumber(float: 1.2),
                    NSNumber(float: 1.0)
                ]
                scaleAnimation.fillMode = kCAFillModeForwards
                self.maskImageView.layer.addAnimation(scaleAnimation, forKey: "transform.rotate")
            }
            
        }
    }
}
