//
//  Meters.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/7.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

extension NSObject{
    
    class func mt_modelForWithDict(dict:[NSObject: AnyObject])->AnyObject{
        var object = self.new()
        return NSObject.mt_modelValueForDict(object,dict: dict)
    }
    
    class func mt_modelValueForDict(object:AnyObject, dict: [NSObject: AnyObject])->AnyObject{
    
        let mirror = Mirror(object)
        var ivarCount:UInt32 = 0
        let ivars = class_copyIvarList(object_getClass(object), &ivarCount)
        
        for var i = 0; i < Int(ivarCount); i++ {
            var keys:String = String.fromCString(ivar_getName(ivars[i]))!
            
            if mirror.types.count > i+1{
                var type:Any.Type = mirror.types[i+1]
                if dict[keys] != nil {
                    if let array = dict[keys] as? [AnyObject]{
                        var optional = "\(type)".convertOptionals()
                        var swiftObj = optional
                        var vals:Array<AnyObject> = Array()
                        var mm = NSObject.cutForArrayString(swiftObj)
                        if count(mm) > 0 {
                            if let obj: AnyClass = NSClassFromString(mm) {
                                for var i = 0; i < count(array); i++ {
                                    let di: AnyObject = array[i]
                                    if let oc = obj.new() as? NSObject {
                                        if (di.allKeys.count > 0) {
                                            var iCount:UInt32 = 0
                                            var iss = class_copyIvarList(object_getClass(oc), &iCount)
                                            
                                            for var n = 0; n < Int(iCount); n++ {
                                                let k:String = String.fromCString(ivar_getName(iss[n]))!
//                                                    if let value: AnyObject? = di[k] {
                                                        oc.setValue(di[k], forKeyPath: k)
//                                                    }
                                            }
                                        }
                                        vals.append(oc)
                                    }
                                }
                                object.setValue(vals, forKey:keys)
                            }else{
                                
                                object.setValue(dict[keys], forKey:keys)
                            }
                        }
                    }else{
                        if let newObj: AnyObject = NSObject.customObject(mirror, keyValue: mirror.typesShortName[i+1],index: i+1){
                            var di:[NSObject: AnyObject] = (dict[keys] as? [NSObject: AnyObject])!
                            NSObject.mt_modelValueForDict(newObj as! NSObject, dict: di)
                            object.setValue(newObj, forKey:keys)
                        }
                        else {
                            if (dict[keys]?.isKindOfClass(NSNull.self) != nil){
                                object.setValue(dict[keys], forKey:keys)
                            }else{
                                object.setValue("", forKey:keys)
                            }
                        }
                    }
                }
            }

            
        }
        return object
    }
    
    class func customObject(mirror:Mirror<AnyObject>,keyValue key:AnyObject,index:Int)->AnyObject?{
        var ocKey = NSMutableString(string: "\(mirror.firstName).\(key as! String)")

        ocKey.replaceOccurrencesOfString("?", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, ocKey.length))
        
        if NSClassFromString(ocKey as String) == nil {
            return nil
        }
        return NSClassFromString(ocKey as String).new() as? NSObject
    }
    
    class func isArrayForString(str:String) -> Bool {
        return str.hasPrefix("Swift.Array<")
    }
    
    class func cutForArrayString(str:String) -> String {
        var strM = NSMutableString(string: str)
        if NSObject.isArrayForString(str) {
            strM.replaceOccurrencesOfString("Swift.Array<", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, strM.length))
            strM.replaceOccurrencesOfString("?", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, strM.length))
            strM.replaceOccurrencesOfString(">", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, strM.length))
        }
        return strM as String
    }
}