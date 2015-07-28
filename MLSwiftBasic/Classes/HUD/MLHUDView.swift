//
//  MLHUDView.swift
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

var hudView:MLHUDView!
var hudStatus:HUDStatus?

class MLHUDView: UIView {
    
    // Init Data
    var progress:CGFloat? {
        willSet {
            if self.msgLbl != nil && self.msgView != nil {
                self.msgLbl!.frame.size.width = self.msgView!.frame.size.width * newValue!
            }
        }
    }
    var message:String?
    var timer:NSTimer?
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
        
        hudView = MLHUDView(frame: UIScreen.mainScreen().bounds)
        hudView.layer.cornerRadius = 5.0;
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
        timer?.invalidate()
        timer = nil
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
    
    class func ShowMessage(str:String!) -> MLHUDView {
        return MLHUDView(message: str)
    }
    
    class func ShowMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView(message: str, duration: duration)
    }
    
    class func ShowSuccessMessage(str:String!) -> MLHUDView {
        
        return MLHUDView(message: str)
    }
    
    class func ShowSuccessMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView(message: str, duration: duration)
    }
    
    class func ShowErrorMessage(str:String!) -> MLHUDView {
        
        return MLHUDView(message: str)
    }
    
    class func ShowErrorMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView(message: str, duration: duration)
    }
    
    class func ShowProgress(progress:CGFloat!,message:String!) -> MLHUDView {
        hudStatus = HUDStatus.Progress
        if (hudView != nil){
            hudView.progress = progress
            hudView.message = message
            return hudView
        }
        return MLHUDView(progress: progress, message: message)
    }
    
    class func ShowProgress(progress:CGFloat!,message:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        hudStatus = HUDStatus.Progress
        if (hudView != nil && hudView.superview != nil){
            hudView.progress = progress
            hudView.message = message
            hudView.duration = duration
            return hudView
        }
        return MLHUDView(progress: progress, message: message,duration: duration)
    }
    
    class func ShowWaiting() -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowWaiting(#duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    func dismiss() {
        hudStatus = HUDStatus.Message
        self.removeTimer()
        self.removeFromSuperview()
    }
}
