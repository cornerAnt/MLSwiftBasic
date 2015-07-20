//
//  Demo6ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/7/19.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

class Demo6ViewController: MBBaseVisualViewController,UITableViewDataSource,UITableViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavBarViewBackgroundColor(UIColor(rgba: "0c8eee"))
        self.setNavBarGradient(true)
        self.setupTableView()
    }
    
    func setupTableView(){
        var tableView = UITableView(frame: self.view.frame, style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.insertSubview(tableView, atIndex: 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "Test \(indexPath.row)"
        return cell
    }
    

}
