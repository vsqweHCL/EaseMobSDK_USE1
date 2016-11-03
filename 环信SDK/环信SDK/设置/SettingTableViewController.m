//
//  SettingTableViewController.m
//  环信使用
//
//  Created by HCL黄 on 16/11/1.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "SettingTableViewController.h"
#import "EaseMob.h"

@interface SettingTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *loginName = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *title = [NSString stringWithFormat:@"log out(%@)",loginName];
    
    [self.logOutButton setTitle:title forState:0];
}

- (IBAction)logOut:(id)sender {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"退出失败：%@",error);
        }
        else {
            NSLog(@"退出成功");
            // 回到登录界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
        }
    } onQueue:nil];
}



@end
