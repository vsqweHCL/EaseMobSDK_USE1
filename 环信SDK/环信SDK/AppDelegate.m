//
//  AppDelegate.m
//  环信使用
//
//  Created by HCL黄 on 16/10/31.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseMob.h"

@interface AppDelegate () <EMChatManagerDelegate>

@end

@implementation AppDelegate

- (void)dealloc
{
    // 移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //registerSDKWithAppKey: 注册的AppKey，详细见下面注释。
    //apnsCertName: 推送证书名（不需要加后缀），详细见下面注释。
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"1196161031115503#myim" apnsCertName:nil otherConfig:@{kSDKConfigEnableConsoleLogger : @(NO)}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 监听自动登录的状态
    // 设置chatManager的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if (isAutoLogin) {
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    }
    
    return YES;
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        NSLog(@"自动登录成功 - %@",loginInfo);
    }
    else {
        NSLog(@"自动登录失败 - %@",error);
    }
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}
@end
