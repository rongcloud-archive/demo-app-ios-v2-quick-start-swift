//
//  AppDelegate.swift
//  demo-app-ios-v2-quick-start-swift
//
//  Created by 岑裕 on 15/11/25.
//  Copyright © 2015年 岑裕. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RCIMConnectionStatusDelegate, RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMReceiveMessageDelegate {
    
    //融云SDK推送说明：
    //我们在知识库里还有推送调试页面加了很多说明，当遇到推送问题时可以去知识库里搜索还有查看推送测试页面的说明。
    //首先必须设置deviceToken，可以搜索本文件关键字“推送处理”。模拟器是无法获取devicetoken，也就没有推送功能。
    //当使用"开发／测试环境"的appkey测试推送时，必须用Development的证书打包，并且在后台上传"开发／测试环境"的推送证书，证书必须是development的。
    //当使用"生产／线上环境"的appkey测试推送时，必须用Distribution的证书打包，并且在后台上传"生产／线上环境"的推送证书，证书必须是distribution的。
    
    var window: UIWindow?
    let rongcloudIMAppkey = "p5tvi9dst07f4" //请务必更换成您自己的appkey进行测试和使用
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //初始化融云SDK，在使用SDK的所有功能和显示相关View(包括继承于SDK的View)之前必须先初始化
        RCIM.sharedRCIM().initWithAppKey(rongcloudIMAppkey)
        
        //设置监听连接状态
        RCIM.sharedRCIM().connectionStatusDelegate = self
        //设置消息接收的监听
        RCIM.sharedRCIM().receiveMessageDelegate = self
        
        //设置用户信息提供者，需要提供正确的用户信息，否则SDK无法显示用户头像、用户名和本地通知
        RCIM.sharedRCIM().userInfoDataSource = self
        //设置群组信息提供者，需要提供正确的群组信息，否则SDK无法显示群组头像、群名称和本地通知
        RCIM.sharedRCIM().groupInfoDataSource = self
        
        
        //推送处理1
        if #available(iOS 8.0, *) {
            //注册推送,用于iOS8以上系统
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(forTypes:[.Alert, .Badge, .Sound], categories: nil))
        } else {
            //注册推送,用于iOS8以下系统
            application.registerForRemoteNotificationTypes([.Badge, .Alert, .Sound])
        }
        
        //点击远程推送的launchOptions内容格式请参考官网文档
        //http://www.rongcloud.cn/docs/ios.html#App_接收的消息推送格式
        
        let viewController = ViewController()
        let nav = UINavigationController(rootViewController: viewController)
        self.window?.rootViewController = nav
        self.window?.backgroundColor = UIColor.yellowColor()
        self.window?.makeKeyAndVisible()
        
        //统一导航条样式
        let textAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(19.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.redColor()
        
        return true
    }
    
    //推送处理2
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        //注册推送,用于iOS8以上系统
        application.registerForRemoteNotifications()
    }
    
    //推送处理3
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var rcDevicetoken = deviceToken.description
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString("<", withString: "")
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString(">", withString: "")
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        RCIMClient.sharedRCIMClient().setDeviceToken(rcDevicetoken)
    }
    
    //推送处理4
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //远程推送的userInfo内容格式请参考官网文档
        //http://www.rongcloud.cn/docs/ios.html#App_接收的消息推送格式
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //本地通知
    }
    
    //监听连接状态变化
    func onRCIMConnectionStatusChanged(status: RCConnectionStatus) {
        print("RCConnectionStatus = \(status.rawValue)")
    }
    
    //用户信息提供者。您需要在completion中返回userId对应的用户信息，SDK将根据您提供的信息显示头像和用户名
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        print("用户信息提供者，getUserInfoWithUserId:\(userId)")
        
        //简单的示例，根据userId获取对应的用户信息并返回
        //建议您在本地做一个缓存，只有缓存没有该用户信息的情况下，才去您的服务器获取，以提高用户体验
        if (userId == "me") {
            //如果您提供的头像地址是http连接，在iOS9以上的系统中，请设置使用http，否则无法正常显示
            //具体可以参考Info.plist中"App Transport Security Settings->Allow Arbitrary Loads"
            completion(RCUserInfo(userId: userId, name: "我的名字", portrait: "http://www.rongcloud.cn/images/newVersion/logo/baixing.png"))
        } else if (userId == "you") {
            completion(RCUserInfo(userId: userId, name: "你的名字", portrait: "http://www.rongcloud.cn/images/newVersion/logo/qichezc.png"))
        } else {
            completion(RCUserInfo(userId: userId, name: "unknown", portrait: "http://www.rongcloud.cn/images/newVersion/logo/douguo.png"))
        }
    }
    
    //群组信息提供者。您需要在Block中返回groupId对应的群组信息，SDK将根据您提供的信息显示头像和群组名
    func getGroupInfoWithGroupId(groupId: String!, completion: ((RCGroup!) -> Void)!) {
        print("群组信息提供者，getGroupInfoWithGroupId:\(groupId)")
        
        //简单的示例，根据groupId获取对应的群组信息并返回
        //建议您在本地做一个缓存，只有缓存没有该群组信息的情况下，才去您的服务器获取，以提高用户体验
        if (groupId == "group01") {
            //如果您提供的头像地址是http连接，在iOS9以上的系统中，请设置使用http，否则无法正常显示
            //具体可以参考Info.plist中"App Transport Security Settings->Allow Arbitrary Loads"
            completion(RCGroup(groupId: groupId, groupName: "第一个群", portraitUri: "http://www.rongcloud.cn/images/newVersion/logo/aipai.png"))
        } else {
            completion(RCGroup(groupId: groupId, groupName: "unknown", portraitUri: "http://www.rongcloud.cn/images/newVersion/logo/qiugongl.png"))
        }
    }
    
    //监听消息接收
    func onRCIMReceiveMessage(message: RCMessage!, left: Int32) {
        if (left != 0) {
            print("收到一条消息，当前的接收队列中还剩余\(left)条消息未接收，您可以等待left为0时再刷新UI以提高性能")
        } else {
            print("收到一条消息")
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

