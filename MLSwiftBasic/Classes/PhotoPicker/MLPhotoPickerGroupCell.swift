//
//  MLPhotoPickerGroupCell.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/8/28.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MLPhotoPickerGroupCell: UITableViewCell {
    
    var imgView:UIImageView!
    var nameLabel:UILabel!
    var countLabel:UILabel!
    var lineView:UIView!
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        // UI
        imgView = UIImageView(frame: CGRectMake(GroupCellMargin, GroupCellMargin, GroupCellRowHeight - GroupCellMargin, GroupCellRowHeight - GroupCellMargin * 2))
        self.contentView.addSubview(imgView)
        
        nameLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(imgView.frame) + MARGIN_8 * 2, MARGIN_8 * 2, self.frame.width - CGRectGetMaxX(imgView.frame), MARGIN_8 * 2))
        self.contentView.addSubview(nameLabel)
        
        countLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(imgView.frame) + MARGIN_8 * 2, CGRectGetMaxY(nameLabel.frame) + MARGIN_8, self.frame.width - CGRectGetMaxX(imgView.frame), MARGIN_8 * 2))
        countLabel.font = UIFont.systemFontOfSize(13)
        self.contentView.addSubview(countLabel)
        
        lineView = UIView(frame: CGRectMake(0, GroupCellRowHeight - ONE_PX, self.frame.width, ONE_PX))
        lineView.tag = 101
        lineView.backgroundColor = UIColor(rgba: "e1e1e1")
        self.contentView.addSubview(lineView)
    }
    
    var currentGroup:MLPhotoGroup!
    var group:MLPhotoGroup {
        set{
            imgView.image = newValue.thumbImage
            nameLabel.text = newValue.groupName;
            countLabel.text = "\(newValue.assetsCount)";
            currentGroup = newValue
        }
        
        get{
            return currentGroup
        }
    }


}
