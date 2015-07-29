//
//  MLProgressHUD.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/23.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

enum HUDStatus: Int{
    case Message = 0
    case Progress = 1
}

var hudView:MLProgressHUD!
var hudStatus:HUDStatus?
var timer:NSTimer?

class MLProgressHUD: UIView {
    
    // Init Data
    var progress:CGFloat? {
        willSet {
            if self.msgLbl != nil && self.msgView != nil {
                self.msgLbl!.frame.size.width = self.msgView!.frame.size.width * newValue!
            }
        }
    }
    var message:String?
    var duration:CGFloat?
    var timerIndex:Int!
    
    /// View Contatiner
    var msgView:UIView?
    var msgLbl:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(message:String){
        self.init()
        
        hudView = MLProgressHUD(frame: UIScreen.mainScreen().bounds)
        hudView.layer.cornerRadius = 5.0;
        hudView.alpha = 0
        hudView.backgroundColor = UIColor.clearColor()
        UIApplication.sharedApplication().keyWindow?.addSubview(hudView)

        var maskView = UIView()
        maskView.frame = UIScreen.mainScreen().bounds
        maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        hudView.addSubview(maskView)
        
        var width:CGFloat = 100
        var msgView = UIView(frame: CGRectMake(CGFloat(UIScreen.mainScreen().bounds.width - width) * 0.5, CGFloat(UIScreen.mainScreen().bounds.height - width) * 0.5, width, width))
        msgView.layer.cornerRadius = 5.0;
        msgView.backgroundColor = UIColor.lightGrayColor()
        msgView.clipsToBounds = true
        hudView.addSubview(msgView)
        self.msgView = msgView
        
        let tap = UITapGestureRecognizer(target: hudView, action: Selector("dismiss"))
        maskView.addGestureRecognizer(tap)
        
        var msgLbl = UILabel(frame: msgView.bounds)
        msgLbl.font = UIFont.systemFontOfSize(14)
        msgLbl.textColor = UIColor.whiteColor()
        msgLbl.textAlignment = .Center
        msgLbl.text = message
        msgView.addSubview(msgLbl)
        self.msgLbl = msgLbl
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            hudView.alpha = 1
        })
    }
    
    convenience init(message:String, duration:CGFloat){
        self.init(message:message)
        
        self.timerIndex = 0
        if duration > 0 {
            self.duration = duration
            self.addTimer()
        }
    }
    
    convenience init(progress:CGFloat!,message:String!){
        self.init(message:message)
        
        self.msgLbl?.text = ""
        self.msgView?.frame.size.width = 200
        self.msgLbl?.frame.size.width = self.msgView!.frame.size.width * progress
        self.msgLbl?.backgroundColor = UIColor.redColor()
        self.msgView?.center.x = self.msgView!.frame.size.width
    }
    
    convenience init(progress:CGFloat!,message:String!,duration:CGFloat!){
        self.init(progress:progress, message:message)
        
        self.timerIndex = 0
        if duration > 0 {
            self.duration = duration
            self.addTimer()
        }
    }
    
    func addTimer(){
        timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("startTimer"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func removeTimer(){
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    func startTimer(){
        self.timerIndex = self.timerIndex+1
        if hudStatus!.rawValue == HUDStatus.Progress.rawValue{
            self.msgLbl?.frame.size.width += 10
        }
        if CGFloat(self.timerIndex) > self.duration {
            hudView.dismiss()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showMessage(str:String!) -> MLProgressHUD {
        return MLProgressHUD(message: str)
    }
    
    class func showMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLProgressHUD {
        
        return MLProgressHUD(message: str, duration: duration)
    }
    
    class func showSuccessMessage(str:String!) -> MLProgressHUD {
        
        return MLProgressHUD(message: str)
    }
    
    class func showSuccessMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLProgressHUD {
        
        return MLProgressHUD(message: str, duration: duration)
    }
    
    class func showErrorMessage(str:String!) -> MLProgressHUD {
        
        return MLProgressHUD(message: str)
    }
    
    class func showErrorMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLProgressHUD {
        
        return MLProgressHUD(message: str, duration: duration)
    }
    
    class func showProgress(progress:CGFloat!,message:String!) -> MLProgressHUD {
        hudStatus = HUDStatus.Progress
        if (hudView != nil){
            hudView.progress = progress
            hudView.message = message
            return hudView
        }
        return MLProgressHUD(progress: progress, message: message)
    }
    
    class func showProgress(progress:CGFloat!,message:String!,durationAfterDismiss duration:CGFloat) -> MLProgressHUD {
        hudStatus = HUDStatus.Progress
        if (hudView != nil && hudView.superview != nil){
            hudView.progress = progress
            hudView.message = message
            hudView.duration = duration
            return hudView
        }
        return MLProgressHUD(progress: progress, message: message,duration: duration)
    }
    
    class func showWaiting() -> MLProgressHUD {
        
        return MLProgressHUD()
    }
    
    class func showWaiting(#duration:CGFloat) -> MLProgressHUD {
        
        return MLProgressHUD()
    }
    
    func dismiss() {
        hudStatus = HUDStatus.Message
        self.removeTimer()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            // 不是正在的移除, 只是alpha = 0
            hudView.alpha = 0
        })
//        self.removeFromSuperview()
    }
}
