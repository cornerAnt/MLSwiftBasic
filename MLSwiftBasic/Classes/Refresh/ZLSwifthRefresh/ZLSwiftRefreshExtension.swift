//
//  ZLSwiftRefreshExtension.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

enum RefreshStatus{
    case Normal, Refresh, LoadMore
}

enum HeaderViewRefreshAnimationStatus{
    case headerViewRefreshPullAnimation, headerViewRefreshLoadingAnimation, headerViewRefreshArrowAnimation
}

var loadMoreAction: (() -> ()) = {}
var refreshStatus:RefreshStatus = .Normal
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero

extension UIScrollView: UIScrollViewDelegate {
    
    public var headerRefreshView: ZLSwiftHeadView? {
        get {
            var headerRefreshView = viewWithTag(ZLSwiftHeadViewTag)
            return headerRefreshView as? ZLSwiftHeadView
        }
    }
    
    public var footerRefreshView: ZLSwiftFootView? {
        get {
            var footerRefreshView = viewWithTag(ZLSwiftFootViewTag)
            return footerRefreshView as? ZLSwiftFootView
        }
    }
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(action :(() -> Void)){
        
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil{
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
    }
    
    //MARK: LoadMore
    //上拉加载更多
    func toLoadMoreAction(action :(() -> Void)){
        if (refreshStatus == .LoadMore){
            refreshStatus = .Normal
        }
        
        self.addLoadMoreView(action)
    }
    
    func addLoadMoreView(action :(() -> Void)){
        self.alwaysBounceVertical = true
        loadMoreAction = action
        if self.footerRefreshView == nil {
            var footView = ZLSwiftFootView(action: action, frame: CGRectMake( 0 , UIScreen.mainScreen().bounds.size.height - ZLSwithRefreshFootViewHeight, self.frame.size.width, ZLSwithRefreshFootViewHeight))
            footView.scrollView = self
            footView.tag = ZLSwiftFootViewTag
            self.addSubview(footView)
        }
    }
    
    //MARK: nowRefresh
    //立马上拉刷新
    func nowRefresh(action :(() -> Void)){
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil {
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }else{
            self.headerRefreshView?.action = action
        }
        
        self.headerRefreshView?.nowLoading = true
        self.headerRefreshView?.nowAction = action
    }

    func headerViewRefreshAnimationStatus(status:HeaderViewRefreshAnimationStatus, images:[UIImage]){
        // 箭头动画是自带的效果
        if self.headerRefreshView == nil {
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: {},frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
        
        if (status != .headerViewRefreshArrowAnimation){
            self.headerRefreshView?.customAnimation = true
        }
        
        self.headerRefreshView?.animationStatus = status
        
        if (status == .headerViewRefreshLoadingAnimation){
            self.headerRefreshView?.headImageView.animationImages = images
        }else{
            self.headerRefreshView?.headImageView.image = images.first
            self.headerRefreshView?.pullImages = images
        }
        
    }
    
    //MARK: endLoadMoreData
    //数据加载完毕
    func endLoadMoreData() {
        var footView:ZLSwiftFootView = self.viewWithTag(ZLSwiftFootViewTag) as! ZLSwiftFootView
        footView.isEndLoadMore = true
    }
    
    //MARK: doneRefersh
    //完成刷新
    func doneRefresh(){
        if var headerView:ZLSwiftHeadView = self.viewWithTag(ZLSwiftHeadViewTag) as? ZLSwiftHeadView {
            headerView.stopAnimation()
        }
        refreshStatus = .Normal
        
//        if (loadMoreAction != nil){
//            toLoadMoreAction(loadMoreAction)
//        }
    }
    
}

