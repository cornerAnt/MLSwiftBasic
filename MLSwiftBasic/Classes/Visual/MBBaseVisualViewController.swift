//
//  MBBaseVisualViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/19.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class MBBaseVisualViewController: MBBaseViewController {

    var tableView:UITableView?
    var gradient:Bool?
    var lastY:CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        var  scrollOffset:CGFloat = scrollView.contentOffset.y;
        if (self.gradient == true){
            // 渐变导航栏
            if (scrollOffset <= 0) {
                if(!(self.lastY > scrollOffset && self.navBar.alpha == 1.0)){
                    self.navBar.alpha = (abs(scrollOffset) / TOP_Y > 1.0) ? 1.0 : abs(scrollOffset) / TOP_Y
                }
            }else{
                if(self.lastY > scrollOffset && scrollView.dragging == true && scrollOffset + scrollView.frame.height < scrollView.contentSize.height){
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        self.navBar.alpha = 1.0
                    })
                }else if(scrollView.dragging == true){
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        self.navBar.alpha = 0.0
                    })
                }
            }
            self.lastY = scrollOffset
        }else{
            let hv = tableView!.tableHeaderView as! MBBaseVisualHeaderView
            if (scrollOffset < 0) {
                hv.height = hv.minimumHeight! - scrollOffset;
            } else {
                hv.height = hv.minimumHeight!
            }
            hv.setNeedsUpdateConstraints()
        }
    }
    
    func setNavBarGradient(flag:Bool){
        self.gradient = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
