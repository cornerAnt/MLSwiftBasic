//
//  MLPhotoBrowser.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/5.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLPhotoBrowser: NSObject {
    /// URL
    var photoURL:NSURL?
    /// Image
    var photoImage:UIImage?
    /// ThumbImage
    var thumbImage:UIImage?
    /// toView
    var toView:UIImageView?
}

class ZLPhotoRect: NSObject {
    class func setMaxMinZoomScalesForCurrentBoundWithImage(image:UIImage) -> CGRect{
        if (image.isKindOfClass(UIImage.self) == false){
            return CGRectZero
        }
        
        // Sizes
        var boundsSize = UIScreen.mainScreen().bounds.size
        var imageSize = image.size
        if (imageSize.width == 0 && imageSize.height == 0) {
            return CGRectZero;
        }
        
        var xScale = boundsSize.width / imageSize.width
        var yScale = boundsSize.height / imageSize.height
        var minScale = min(xScale, yScale)
        
        if (xScale >= 1 && yScale >= 1) {
            minScale = min(xScale, yScale);
        }
        
        var frameToCenter = CGRectZero
        if (minScale >= 3) {
            minScale = 3;
        }
        frameToCenter = CGRectMake(0, 0, imageSize.width * minScale, imageSize.height * minScale)
        
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
        } else {
            frameToCenter.origin.y = 0
        }
        
        return frameToCenter
    }
    
    class func setMaxMinZoomScalesForCurrentBoundWithImageView(imageView:UIImageView) -> CGRect{
        return self.setMaxMinZoomScalesForCurrentBoundWithImage(imageView.image!)
    }
}