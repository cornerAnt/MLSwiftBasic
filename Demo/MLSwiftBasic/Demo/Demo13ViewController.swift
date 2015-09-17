//
//  Demo13ViewController.swift
//  MLSwiftBasic
//
//  Created by 张磊 on 15/9/7.
//  Copyright (c) 2015年 MakeZL. All rights reserved.
//

import UIKit

/// 测试模型
class Dog: NSObject {
    var dogName: String?
    var age: NSNumber?
    var reflectKeyPath:[String:String] = {
        [
            "age":"dogAge"
        ]
    }()
}

class Person: NSObject {
    var name:String?
    var age:NSNumber?
    var person:Person!
    var dog:Dog!
    var peoples:Array<Person>!
}

class GitHubRepoModel:NSObject {
    
    var type:String?
    var created:String?
    var pushed_at:String?
    var watchers:NSNumber?
    var owner:String?
    var pushed:String?
    var forks:NSNumber?
    var username:String?
    var language:String?
    var fork:NSNumber?
    var size:NSNumber?
    var followers:NSNumber?
    var name:String?
    var created_at:String?
    
}

class ReposModel: NSObject {
    
    var repositories:Array<GitHubRepoModel>?
}

class Demo13ViewController: MBBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    var examples:Array<String> = [
        "简单字典 -》模型",
        "复杂的字典 -》模型 (模型里面包含了模型)",
        "复杂的字典 -》模型 (模型里面包含了模型，又包含了数组)",
        "测试100条数据+100条数组的字典 -》模型 (模型里面包含数组模型)",
        "反射字典的key值",
        "复杂的反射字典的key值",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return self.examples.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.examples[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            self.testMeters1()
        }else if indexPath.row == 1{
            self.testMeters2()
        }else if indexPath.row == 2{
            self.testMeters3()
        }else if indexPath.row == 3{
            self.testMeters4()
        }else if indexPath.row == 4{
            self.testMeters5()
        }else if indexPath.row == 5{
            self.testMeters6()
        }
    }
    
    func testMeters1(){
        var start = CFAbsoluteTimeGetCurrent()
        var p:Person = Person.mt_modelForWithDict(
            [
             "age":NSNumber(integer: 10),
             "name":"zhanglei","sex":"0"
            ]
            ) as! Person
        
        var end = CFAbsoluteTimeGetCurrent();
        println("消耗的时间：\(end - start)s");
        println("-------MakeZL--------");
        println("数据是：\(p) name = \(p.name), age = \(p.age)....")
    }
    
    func testMeters2(){
        
        var start = CFAbsoluteTimeGetCurrent()
        var p:Person = Person.mt_modelForWithDict(
            [
                "age":NSNumber(integer: 10),
                "name":"zhanglei",
                "person":
                    ["age":NSNumber(integer: 22),
                        "name":"makezl",
                        "dog":["dogName":"xxxx"]
                ]
                ,"dog":
                    ["dogName":"xiaogou"]
            ]
            ) as! Person
        
        var end = CFAbsoluteTimeGetCurrent();
        println("消耗的时间：\(end - start)s");
        println("-------MakeZL--------");
        println("数据是：\(p) name = \(p.name), Dog:\(p.dog) dogName:\(p.dog?.dogName)")
    }
    
    func testMeters3(){
        
        var start = CFAbsoluteTimeGetCurrent()
        var p:Person = Person.mt_modelForWithDict(
            [
                "age":NSNumber(integer: 10),
                "name":"zhanglei",
                "person":
                    ["age":NSNumber(integer: 22),
                        "name":"makezl",
                        "dog":["dogName":"xxxx"]
                ]
                ,"dog":
                    ["dogName":"xiaogou"]
                
                ,"peoples":
                    [
                        ["age":NSNumber(integer: 24),
                            "name":"testPeople1"
                        ],
                        ["age":NSNumber(integer: 30),
                            "name":"testPeople2"
                        ]
                ]
            ]
            ) as! Person
        
        var end = CFAbsoluteTimeGetCurrent();
        println("消耗的时间：\(end - start)s");
        println("-------MakeZL--------");
        println("\(p) name = \(p.name), Dog:\(p.dog) dogName:\(p.dog?.dogName)")
        
        for var i = 0; i < p.peoples?.count; i++ {
            var person = p.peoples![i] as Person
            println(person.name)
        }
    }
    
    func testMeters4(){
        var url = NSBundle.mainBundle().URLForResource("github-iphone.json", withExtension: nil)
        var data = NSData(contentsOfURL: url!)
        var dict: [NSObject: AnyObject] = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil) as! [NSObject: AnyObject]
        
        var start = CFAbsoluteTimeGetCurrent()
        for (var i = 0; i < 100; ++i) {
            ReposModel.mt_modelForWithDict(dict as [NSObject: AnyObject]) as! ReposModel
        }
        var end = CFAbsoluteTimeGetCurrent()
        println("100条数据消耗的时间：\(end - start)s")
        println("-------MakeZL--------")
    }
    
    func testMeters5(){
        var dog: AnyObject = Dog.mt_modelForWithDict([
                "dogName":"妞妞",
                "dogAge" : NSNumber(int: 10)
            ])
        println("\(dog.dogName) Age is \(dog.age)")
    }
    
    func testMeters6(){
        var person: Person = Person.mt_modelForWithDict(
            [
                "age":NSNumber(integer: 10),
                "name":"zhanglei",
                "sex":"0",
                "dog":[
                    "dogName":"妞妞",
                    "dogAge" : NSNumber(int: 10)
                ]
            ]
        ) as! Person
        println("personName:\(person.name) dog : < \(person.dog?.dogName) Age is \(person.dog?.age) >")
    }
    
    override func titleStr() -> String {
        return "字典转模型 - Meters"
    }
    
    override func rightItemWidth() -> CGFloat {
        return 100
    }
    
}
