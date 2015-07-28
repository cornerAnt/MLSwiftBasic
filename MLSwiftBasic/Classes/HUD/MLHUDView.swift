//
//  MLHUDView.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/23.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLHUDView: UIView {
    
    var progress:CGFloat?
    var strMsg:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(message:String){
        self.init()
        
    }
    
    convenience init(message:String, duration:CGFloat){
        self.init(message:message)
        
        var maskView = UIView()
        maskView.frame = UIScreen.mainScreen().bounds
        maskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(maskView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func ShowMessage(str:String!) -> MLHUDView {
        return MLHUDView(message: str)
    }
    
    class func ShowMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowSuccessMessage(str:String!) -> MLHUDView {
        
        return MLHUDView(message: str)
    }
    
    class func ShowSuccessMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowErrorMessage(str:String!) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowErrorMessage(str:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowProgress(progress:CGFloat!) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowProgress(progress:CGFloat!,message:String!) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowProgress(progress:CGFloat!,message:String!,durationAfterDismiss duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowWaiting() -> MLHUDView {
        
        return MLHUDView()
    }
    
    class func ShowWaiting(#duration:CGFloat) -> MLHUDView {
        
        return MLHUDView()
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
}
