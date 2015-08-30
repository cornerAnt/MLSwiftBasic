//
//  MLPhotoAssetsFooterView.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/30.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLPhotoAssetsFooterView: UICollectionReusableView {
    
    var count:Int!{
        willSet{
            if newValue > 0 {
                self.footerLbl.text = "有 \(newValue) 张图片"
            }
        }
    }
    
    private lazy var footerLbl:UILabel = {
        var footerLbl = UILabel(frame: self.bounds)
        footerLbl.textAlignment = .Center;
        self.addSubview(footerLbl)
        return footerLbl
    }()
    
}
