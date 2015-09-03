//
//  MB+Array.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/2.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.removeAtIndex(index!)
        }
    }
    
    mutating func containsObject<U: Equatable>(object: U) -> Bool{
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            return true
        }
        return false
    }
}