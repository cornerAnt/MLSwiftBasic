//
//  MLPhotoPickerBrowserScrollView.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/31.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

@objc protocol MLPhotoPickerBrowserScrollViewDelegate: NSObjectProtocol{
    func pickerPhotoScrollViewDidSingleClick()
}

class MLPhotoPickerBrowserScrollView: UIScrollView,MLPhotoPickerBrowserPhotoViewDelegate,MLPhotoPickerBrowserPhotoImageViewDelegate,UIActionSheetDelegate {

    var photoImageView:MLPhotoPickerBrowserPhotoImageView?
    var isHiddenShowSheet:Bool?
    var photo:MLPhotoAssets?{
        willSet{
            if newValue!.isKindOfClass(UIImage.self) == true{
                photoImageView!.image = newValue as? UIImage
                self.displayImage()
            }else if ((newValue!.originalImage) != nil){
                photoImageView!.image = newValue?.originalImage
                self.displayImage()
            }
        }
    }
    var sheet:UIActionSheet?
    weak var photoScrollViewDelegate:MLPhotoPickerBrowserScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupInit()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInit(){
        
        var tapView = MLPhotoPickerBrowserPhotoView(frame: self.bounds)
        tapView.delegate = self
        tapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tapView.backgroundColor = UIColor.blackColor()
        self.addSubview(tapView)
        
        photoImageView = MLPhotoPickerBrowserPhotoImageView(frame: self.bounds)
        photoImageView!.delegate = self
        photoImageView?.userInteractionEnabled = true
        photoImageView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        photoImageView!.backgroundColor = UIColor.blackColor()
        self.addSubview(photoImageView!)
        
        // Setup
        self.backgroundColor = UIColor.redColor()
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
    
    func setMaxMinZoomScalesForCurrentBounds(){
        // Reset
        self.maximumZoomScale = 1
        self.minimumZoomScale = 1
        self.zoomScale = 1
        // Bail if no image
        if (photoImageView?.image == nil) {
            return
        }
        // Reset position
//        photoImageView!.frame = CGRectMake(0, 0, photoImageView!.frame.width, photoImageView!.frame.height)
        
        // Sizes
        var boundsSize = self.bounds.size
        var imageSize = photoImageView!.image!.size
        
        // Calculate Min
        var xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        var yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        var minScale:CGFloat = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        
        // Calculate Max
        var maxScale:CGFloat = 3
        // Image is smaller than screen so no zooming!
        if (xScale >= 1 && yScale >= 1) {
            minScale = min(xScale, yScale)
        }
        if (minScale >= 3) {
            minScale = 1
        }
    
        // Set min/max zoom
        self.maximumZoomScale = max(xScale,yScale)
        self.minimumZoomScale = minScale
        
        // Initial zoom
        self.zoomScale = minScale
        
        // If we're zooming to fill then centralise
        if (self.zoomScale != minScale) {
            // Centralise
            self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                (imageSize.height * self.zoomScale - boundsSize.height) / 2.0)
            // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
            self.scrollEnabled = false
        }
        
        // Layout
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
        if self.photoScrollViewDelegate?.respondsToSelector("pickerPhotoScrollViewDidSingleClick") == true {
            self.photoScrollViewDelegate?.pickerPhotoScrollViewDidSingleClick()
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
    
//    - (void) disMissTap:(UITapGestureRecognizer *)tap{
//    if (self.callback){
//    self.callback(nil);
//    }else if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
//    [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
//    }
//    }
    
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

@objc protocol MLPhotoPickerBrowserPhotoViewDelegate: NSObjectProtocol {
    func photoPickerBrowserPhotoViewSingleTapDetected(touch:UITouch)
    func photoPickerBrowserPhotoViewDoubleTapDetected(touch:UITouch)
}

class MLPhotoPickerBrowserPhotoView: UIView {
    
    var delegate:MLPhotoPickerBrowserPhotoViewDelegate?
    
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

@objc protocol MLPhotoPickerBrowserPhotoImageViewDelegate: NSObjectProtocol {
    func photoPickerBrowserPhotoImageViewSingleTapDetected(touch:UITouch)
    func photoPickerBrowserPhotoImageViewDoubleTapDetected(touch:UITouch)
}

class MLPhotoPickerBrowserPhotoImageView: UIImageView {
    
    var delegate:MLPhotoPickerBrowserPhotoImageViewDelegate?
    
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
