//
//  AddFriendsViewController.m
//  环信使用
//
//  Created by HCL黄 on 16/10/31.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "EaseMob.h"

@interface AddFriendsViewController () <EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textF;

@end

@implementation AddFriendsViewController
//- (void)dealloc
//{
//    // 移除聊天管理器的代理
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//}
- (void)viewDidLoad {
    [super viewDidLoad];

#warning 代理放在会话控制器里
    // 设置代理
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}



- (IBAction)addClick:(id)sender {
    
    // 获取要添加好友的名字
    NSString *text = self.textF.text;
    
    NSString *loginName = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [@"" stringByAppendingString:loginName];
    
    // 发送好友请求
    EMError *error;
    [[EaseMob sharedInstance].chatManager addBuddy:text message:message error:&error];
    if (!error) {
        NSLog(@"添加成功");
    }
    else {
        NSLog(@"添加失败 -- %@", error);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
