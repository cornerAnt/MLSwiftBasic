//
//  MLPhotoBrowserPhotoScrollView.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/31.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

@objc protocol MLPhotoBrowserPhotoScrollViewDelegate: NSObjectProtocol{
    func photoBrowserPhotoScrollViewDidSingleClick()
}

class MLPhotoBrowserPhotoScrollView: UIScrollView,MLPhotoBrowserPhotoViewDelegate,MLPhotoPickerBrowserPhotoImageViewDelegate,UIActionSheetDelegate {
    
    var photoImageView:MLPhotoBrowserPhotoImageView?
    var isHiddenShowSheet:Bool?
    var photo:MLPhotoBrowser?{
        willSet{
            
            var thumbImage = newValue!.thumbImage
            if (thumbImage == nil) {
                self.photoImageView!.image = newValue?.toView?.image
                thumbImage = self.photoImageView!.image
            }else{
                self.photoImageView!.image = thumbImage;
            }
            
            self.photoImageView!.contentMode = .ScaleAspectFit;
            self.photoImageView!.frame = ZLPhotoRect.setMaxMinZoomScalesForCurrentBoundWithImageView(self.photoImageView!)
//            if (self.photoImageView.image == nil) {
//                [self setProgress:0.01];
//            }
            
            // 网络URL
          self.photoImageView?.kf_setImageWithURL(newValue!.photoURL!, placeholderImage: thumbImage, optionsInfo: nil, progressBlock: { (receivedSize, totalSize) -> () in
                
            }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if ((image) != nil) {
                    self.photoImageView!.image = image
                    self.displayImage()
                }else{
                    self.photoImageView?.removeScaleBigTap()
                }
            })
        }
    }
    var sheet:UIActionSheet?
    weak var photoScrollViewDelegate:MLPhotoBrowserPhotoScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInit(){
        
        var tapView = MLPhotoBrowserPhotoView(frame: self.bounds)
        tapView.delegate = self
        tapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tapView.backgroundColor = UIColor.blackColor()
        self.addSubview(tapView)
        
        photoImageView = MLPhotoBrowserPhotoImageView(frame: self.bounds)
        photoImageView!.delegate = self
        photoImageView?.userInteractionEnabled = true
        photoImageView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        photoImageView!.backgroundColor = UIColor.blackColor()
        self.addSubview(photoImageView!)
        
        // Setup
        self.backgroundColor = UIColor.blackColor()
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        
        var longGesture = UILongPressGestureRecognizer(target: self, action: "longGesture:")
        self.addGestureRecognizer(longGesture)
    }
    
    func displayImage(){
        // Reset
        self.maximumZoomScale = 1
        self.minimumZoomScale = 1
        self.zoomScale = 1
        self.contentSize = CGSizeMake(0, 0)
        
        // Get image from browser as it handles ordering of fetching
        var img = photoImageView?.image
        if img != nil {
            photoImageView?.hidden = false
            // Set ImageView Frame
            // Sizes
            var boundsSize = self.bounds.size
            var imageSize = photoImageView!.image!.size
            
            var xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
            var yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
            var minScale:CGFloat = min(xScale, yScale);
            if (xScale >= 1 && yScale >= 1) {
                minScale = min(xScale, yScale);
            }
            
            var frameToCenter = CGRectZero;
            if (minScale >= 3) {
                minScale = 3;
            }
            
            photoImageView?.frame = CGRectMake(0, 0, imageSize.width * minScale, imageSize.height * minScale)
            
            self.maximumZoomScale = 3
            self.minimumZoomScale = 1.0
            self.zoomScale = 1.0
        }
        
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center the image as it becomes smaller than the size of the screen
        var boundsSize = self.bounds.size
        var frameToCenter = photoImageView!.frame
        
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0);
        } else {
            frameToCenter.origin.x = 0;
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0);
        } else {
            frameToCenter.origin.y = 0;
        }
        
        // Center
        if (!CGRectEqualToRect(photoImageView!.frame, frameToCenter)){
            photoImageView!.frame = frameToCenter;
        }
    }
    
    // MARK:: Tap Detection
    func handleDoubleTap(touchPoint:CGPoint){
        // Zoom
        if (self.zoomScale != self.minimumZoomScale) {
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
            self.contentSize = CGSizeMake(self.frame.size.width, 0)
        } else {
            // Zoom in to twice the size
            var newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2)
            var xsize = self.bounds.size.width / newZoomScale
            var ysize = self.bounds.size.height / newZoomScale
            self.zoomToRect(CGRectMake(touchPoint.x - xsize/2.0, touchPoint.y - ysize/2, xsize, ysize), animated: true)
        }
    }
    
    func photoPickerBrowserPhotoViewDoubleTapDetected(touch:UITouch) {
        var touchX = touch.locationInView(touch.view).x;
        var touchY = touch.locationInView(touch.view).y;
        touchX *= 1/self.zoomScale;
        touchY *= 1/self.zoomScale;
        touchX += self.contentOffset.x;
        touchY += self.contentOffset.y;
        self.handleDoubleTap(CGPointMake(touchX, touchY))
    }
    
    func photoPickerBrowserPhotoImageViewSingleTapDetected(touch: UITouch) {
        self.disMissTap(nil)
    }
    
    func disMissTap(tap:UITapGestureRecognizer?){
        if self.photoScrollViewDelegate?.respondsToSelector("photoBrowserPhotoScrollViewDidSingleClick") == true {
            self.photoScrollViewDelegate?.photoBrowserPhotoScrollViewDidSingleClick()
        }
    }
    
    func longGesture(gesture:UILongPressGestureRecognizer){
        if gesture.state == .Began{
            if self.isHiddenShowSheet == false{
                self.sheet = UIActionSheet(title: "提示", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
                self.sheet?.showInView(self)
            }
        }
    }
    
    // Image View
    func photoPickerBrowserPhotoImageViewDoubleTapDetected(touch: UITouch) {
        self.handleDoubleTap(touch.locationInView(touch.view))
    }
    
    func photoPickerBrowserPhotoViewSingleTapDetected(touch: UITouch) {
        self.disMissTap(nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

@objc protocol MLPhotoBrowserPhotoViewDelegate: NSObjectProtocol {
    func photoPickerBrowserPhotoViewSingleTapDetected(touch:UITouch)
    func photoPickerBrowserPhotoViewDoubleTapDetected(touch:UITouch)
}

class MLPhotoBrowserPhotoView: UIView {
    
    var delegate:MLPhotoBrowserPhotoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGesture()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addGesture(){
        // 双击放大
        var scaleBigTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        scaleBigTap.numberOfTapsRequired = 2
        scaleBigTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(scaleBigTap)
        
        // 单击缩小
        var disMissTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        disMissTap.numberOfTapsRequired = 1
        disMissTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(disMissTap)
        // 只能有一个手势存在
        disMissTap.requireGestureRecognizerToFail(scaleBigTap)
    }
    
    func handleDoubleTap(touch:UITouch){
        if self.delegate?.respondsToSelector("photoPickerBrowserPhotoViewDoubleTapDetected") == false {
            self.delegate?.photoPickerBrowserPhotoViewDoubleTapDetected(touch)
        }
    }
    
    func handleSingleTap(touch:UITouch){
        if self.delegate?.respondsToSelector("photoPickerBrowserPhotoViewSingleTapDetected") == false {
            self.delegate?.photoPickerBrowserPhotoViewSingleTapDetected(touch)
        }
    }
}

@objc protocol MLPhotoBrowserPhotoImageViewDelegate: NSObjectProtocol {
    func photoPickerBrowserPhotoImageViewSingleTapDetected(touch:UITouch)
    func photoPickerBrowserPhotoImageViewDoubleTapDetected(touch:UITouch)
}

class MLPhotoBrowserPhotoImageView: UIImageView {
    
    var scaleBigTap:UITapGestureRecognizer?
    var delegate:MLPhotoPickerBrowserPhotoImageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGesture()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeScaleBigTap(){
        self.scaleBigTap?.removeTarget(self, action: "handleDoubleTap:")
    }
    
    func addGesture(){
        // 双击放大
        var scaleBigTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        scaleBigTap.numberOfTapsRequired = 2
        scaleBigTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(scaleBigTap)
        self.scaleBigTap = scaleBigTap
        
        // 单击缩小
        var disMissTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        disMissTap.numberOfTapsRequired = 1
        disMissTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(disMissTap)
        // 只能有一个手势存在
        disMissTap.requireGestureRecognizerToFail(scaleBigTap)
    }
    
    func handleDoubleTap(touch:UITouch){
        if self.delegate?.respondsToSelector("photoPickerBrowserPhotoImageViewDoubleTapDetected") == false {
            self.delegate?.photoPickerBrowserPhotoImageViewDoubleTapDetected(touch)
        }
    }
    
    func handleSingleTap(touch:UITouch){
        if self.delegate?.respondsToSelector("photoPickerBrowserPhotoImageViewSingleTapDetected") == false {
            self.delegate?.photoPickerBrowserPhotoImageViewSingleTapDetected(touch)
        }
    }
}
