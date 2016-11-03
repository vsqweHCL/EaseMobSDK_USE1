//
//  LoginViewController.m
//  环信使用
//
//  Created by HCL黄 on 16/10/31.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "LoginViewController.h"
#import "EaseMob.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)regist:(id)sender {
    NSString *username = self.userName.text;
    NSString *password = self.passWord.text;
    
    if (username.length == 0 || password.length == 0) {
        
        return;
    }
    
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:username password:password withCompletion:^(NSString *username, NSString *password, EMError *error) {
        if (!error) {
            NSLog(@"注册成功");
        }
        else {
            NSLog(@"注册失败 -- %@",error);
        }
    } onQueue:nil];
}

- (IBAction)login:(id)sender {
    // 让环信SDK在登录完成之后，自动从服务器获取好友列表，添加到本地数据库
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    NSString *username = self.userName.text;
    NSString *password = self.passWord.text;
    
    if (username.length == 0 || password.length == 0) {
        
        return;
    }
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"登录成功 - %@",loginInfo);
            
            // 设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
            
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
        }
        else {
            NSLog(@"登录失败 - %@",error);
        }
        
    } onQueue:nil];
}


@end
