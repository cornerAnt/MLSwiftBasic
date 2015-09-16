//
//  Meters.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/7.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

var KStaticOcKeys:[String:String]?
var KStaticLastClassName:String?

var KLastMirror:Mirror<NSObject>?
var KLastMirrorType:MirrorType?
var kLastArrAny:[Any.Type]?
var KLastFirstN:NSString?

extension NSObject{
    
    class func mt_modelForWithDict(dict:[NSObject: AnyObject])->AnyObject{
        var object = self.new()
        return NSObject.mt_modelValueForDict(object,dict: dict)
    }
    
    class func mt_modelValueForDict(object:NSObject, dict: [NSObject: AnyObject])->AnyObject{
        let mirror = Mirror(object)
        var ivarCount:UInt32 = 0
        let ivars = class_copyIvarList(object_getClass(object), &ivarCount)
        
        for var i = 0; i < Int(ivarCount); i++ {
            var keys:String = String.fromCString(ivar_getName(ivars[i]))!
            var type:Any.Type = mirror.types[i+1]

            if dict[keys] != nil {
                if let array = dict[keys] as? [AnyObject]{
                    var arrayModelFromString = NSObject.cutForArrayString("\(type)".convertOptionals())
                    NSObject.arrayWithModel(object, array: array, fromString: arrayModelFromString, dataDictionary: dict, withDictKey: keys)
                }else{
                    if let newObj: AnyObject = NSObject.customObject(mirror, keyValue: mirror.typesShortName[i+1],index: i+1){
                        var di:[NSObject: AnyObject] = (dict[keys] as? [NSObject: AnyObject])!
                        NSObject.mt_modelValueForDict(newObj as! NSObject, dict: di)
                        object.setValue(newObj, forKey:keys)
                    }
                    else if (dict[keys] != nil){
                        object.setValue(dict[keys], forKey:keys)
                    }else{
                        object.setValue("", forKey:keys)
                    }
                }
            }
        }
        return object
    }
    
    class func arrayWithModel(object:AnyObject,array:Array<AnyObject>, fromString string:String, dataDictionary dict:[NSObject: AnyObject], withDictKey key:String){
        var vals:Array<AnyObject> = Array()
        if let obj: AnyClass = NSClassFromString(string) {
            for var i = 0; i < count(array); i++ {
            let di: AnyObject = array[i]
            
            if let oc = obj.new() as? NSObject {
                if (KStaticLastClassName == nil || KStaticLastClassName != string){
                    
                    KLastMirrorType = reflect(oc)
                    KLastMirror = Mirror(oc)
                    kLastArrAny = KLastMirror!.types
                    KLastFirstN = ("\(KLastMirror!.firstName)" as NSString)
                    
                    KStaticLastClassName = string
                }
                
                var iCount:UInt32 = 0
                let iss = class_copyIvarList(object_getClass(oc), &iCount)
                for var n = 0; n < Int(iCount); n++ {
                    let ivar = iss[n]
                    let k:String = String.fromCString(ivar_getName(ivar))!
                    let type = (KLastMirrorType![n+1].1.valueType)
                    
                    switch type {
                        case _ as Swift.Optional<String>.Type, _ as Swift.Optional<NSNumber>.Type:
                            oc.setValue(di[k], forKey:k)
                            break
                        case _ as
                            Swift.Optional<Int>.Type,_ as Swift.Optional<Int64>.Type,_ as Swift.Optional<Float>.Type,_ as Swift.Optional<Double>.Type,_ as Swift.Optional<Bool>.Type :
                            oc.setValue("\(di[k])", forKey:k)
                            break
                        default :
                            if let newObj: AnyObject = NSObject.customObject(KLastMirror!, keyValue: k, index: i+1) {
                                var dataDict:[NSObject: AnyObject] = (di[key] as? [NSObject: AnyObject])!
                                NSObject.mt_modelValueForDict(newObj as! NSObject, dict: dataDict)
                                oc.setValue(newObj, forKey:k)
                            }
                            break
                    }
                }
                vals.append(oc)
            }
        }
            object.setValue(vals, forKey:key)
        }else{
            object.setValue(dict[key], forKey:key)
        }
    }
    
    /// Return Instance Custom Object or nil object.
    class func customObject(mirror:Mirror<NSObject>,keyValue key:String,index:Int)->AnyObject?{
        if (KStaticOcKeys != nil && KStaticOcKeys![key] != nil){
            return nil
        }
        
        var ocKey = NSMutableString(string: "\(mirror.firstName).\(key)")
        ocKey.replaceOccurrencesOfString("?", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, ocKey.length))
        
        if NSClassFromString(ocKey as String) == nil {
            KStaticOcKeys?[key] = key
            return nil
        }
        
        KStaticOcKeys?.removeValueForKey(key)
        return NSClassFromString(ocKey as String).new() as? NSObject
    }
    
    /// Flag String Is Array Object.
    class func isArrayForString(str:String) -> Bool {
        return str.hasPrefix("Swift.Array<")
    }
    
    /// Cut Swift ArrayModel to String. ---> convert SwiftObject
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