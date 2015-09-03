# MLSwiftBasic
集合`自定义导航栏`、`下拉刷新/上拉加载更多`、`视觉效果`、`好用分类`等等一系列，却耦合性很低的Swift库!

### Demo or Gif
##### New Gif
![image](https://github.com/MakeZL/MLSwiftBasic/blob/master/ScreenShots/Demo4.gif)

![image](https://github.com/MakeZL/MLSwiftBasic/blob/master/ScreenShots/Demo1.gif)
![image](https://github.com/MakeZL/MLSwiftBasic/blob/master/ScreenShots/Demo2.gif)
![image](https://github.com/MakeZL/MLSwiftBasic/blob/master/ScreenShots/Demo3.gif)

### 新特性

`图片多选`

`下拉刷新\上拉加载更多`

`懒人Swift基本框架，正提供各种简单，方便的接口 `

目前支持的功能：

`1> 自定义导航栏、监听事件`

`2> 滚动效果`

`3> 正在筹备一些分类，期待您的PullRequest`

`4> 正在准备滑动渐变的导航栏效果`

`5> 下拉刷新\上拉加载更多(支持自定义动画/自带箭头动画/娃娃脸动画)`

`6> 相册多选图片(支持记录选择图片、置顶类似微博、预览选择等等)` 

准备迭代：

6> 提示框HUD

7> iOS7的手势

8> 图片浏览器

9> 字典转模型

10> CoreText解析HTML库

11> 联系通讯录


# Installation

Use cocoapods  

``` ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'MLSwiftBasic', '~> 1.1.1'
``` 


# Use
import Class
######  
UINavigationController 继承一个MBNavigationViewController 即可
UIViewController 继承一个MBBaseViewController 即可

### ViewController Code
#### Item Title
	override func titleStr() -> String {
        return "Title"
    }
    
    override func rightStr() -> String {
        return "rightTitle"
    }
    
    override func leftStr() -> String {
        return "leftTitle"
    }

#### RightTitleArray
	override func rightTitles() -> NSArray {
        return ["右边按钮1", "右边按钮2"]
    }
    
#### Item Event
    override func rightClick() {
        
    }
    
    override func leftClick() {
        
    } 
    
    override func titleClick() {
        
    }
    
#### Item ArrayEvent
	override func rightClickAtIndexBtn(button: UIButton) {
        println("点击了btn")
        println(button)
    }
#### Item Image
	override func rightImg() -> String {
        return "xx.jpg"
    }
    
    override func leftImg() -> String {
        return return "xx.jpg"
    }
    
    override func titleImg() -> String {
        return "xx.jpg"
    }

### Config
MBBaseCommon.swift

    // 背景色
    let BG_COLOR = UIColor(rgba: "e6e6e6")
 	// 返回按钮的图片名
	let BACK_NAME = "nav_back"
	// 自定义导航高度
	let NAV_BAR_HEIGHT:CGFloat = 44
	// 顶部的Y值
	let NAV_BAR_Y:CGFloat = 20
	// 按钮的宽度
	let NAV_ITEM_LEFT_W:CGFloat = 45
	let NAV_ITEM_RIGHT_W:CGFloat = 45
	// 按钮的字体
	let NAV_ITEM_FONT:UIFont = UIFont.systemFontOfSize(16)
	// 标题的字体
	let NAV_TITLE_FONT:UIFont = UIFont.systemFontOfSize(18)
	// 字体的颜色
	let NAV_TEXT_COLOR:UIColor = UIColor.whiteColor()
	// 导航栏的颜色
	let NAV_BG_COLOR = UIColor(rgba: "ff9814")
	// 顶部的Y
	let TOP_Y:CGFloat = 	(CGFloat((UIDevice.currentDevice().systemVersion as NSString).floatValue) >= 7.0) ? 64.0 : 44.0
	// Margin
	let MARGIN_8:CGFloat = 8.0

# Contact
@weibo : [我的微博](http://weibo.com/makezl/)

# License

MLSwiftBasic is published under MIT License

    Copyright (c) 2015 MakeZL (@MakeZL)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.