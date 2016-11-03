//
//  AddressBooKController.m
//  环信使用
//
//  Created by HCL黄 on 16/10/31.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "AddressBooKController.h"
#import "AddFriendsViewController.h"
#import "EaseMob.h"
#import "ChatViewController.h"

@interface AddressBooKController () <EMChatManagerDelegate>
/** 好友列表数据源 */
@property (nonatomic, strong) NSArray *buddyLosit;
@end

@implementation AddressBooKController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:(UIBarButtonItemStylePlain) target:self action:@selector(addClick)];
    
    
    // 设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
#warning 需要自动登录之后才有值
    // 获取好友列表 本地数据库获取的
    // 如果要从服务器获取，调用chatManger的方法- (void *)asyncFetchBuddyListWithCompletion:completion onQueue;
    // 如果当前有添加好友请求，环信内部会往数据库添加好友记录
    // 如果程序删除或者用户第一次登录，buddyLosit表示没记录的，
    // 解决：
    // 1.要从服务器获取好友列表
    // 2.用户第一次登录后，自动从服务器获取好友列表[[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES]
    self.buddyLosit = [[EaseMob sharedInstance].chatManager buddyList];
//    NSLog(@"%@",self.buddyLosit);
    
//    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
//    } onQueue:nil];
    
#warning 1.第一次登录 2.自动登录还没有完成
//    if (self.buddyLosit.count == 0) { // 数据库没有好友记录
//        
//    }
    
}
- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    if (!error) { // 自动登录成功
        self.buddyLosit = [[EaseMob sharedInstance].chatManager buddyList];
        [self.tableView reloadData];
    }
}


- (void)addClick
{
    NSLog(@"添加好友");
    [self.navigationController pushViewController:[AddFriendsViewController new] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyLosit.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"BuddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    EMBuddy *buddy = self.buddyLosit[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    cell.textLabel.text = buddy.username;
    return cell;
}
/*!
 @method
 @brief 好友请求被接受时的回调 你添加对方为好友，对方同意了回调
 @discussion
 @param username 之前发出的好友请求被用户username接受了
 */
- (void)didAcceptedByBuddy:(NSString *)username
{
//    NSArray *buddylist = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友同意");
#warning buddylist的个数仍然是没有添加好友之前的个数，必须从服务器获取
    [self loadBuddyListFromServer];
}
#pragma mark - 从服务器获取好友列表
- (void)loadBuddyListFromServer
{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取的好友列表 %@",buddyList);
        self.buddyLosit = buddyList;
        [self.tableView reloadData];
    } onQueue:nil];
}
/*!
 @method
 @brief 通讯录信息发生变化时的通知
 @discussion
 @param buddyList 好友信息列表
 @param changedBuddies 修改了的用户列表
 @param isAdd (YES为新添加好友, NO为删除好友)
 */
#pragma mark - 好友列表数据被更新 1.服务器获取会调用 2.别人发给你好友请求，你同意之后会调用
- (void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd
{
    NSLog(@"好友列表数据被更新");
    
    self.buddyLosit = buddyList;
    [self.tableView reloadData];
}

#pragma mark - 列表左滑删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 获取移除好友的名字
        EMBuddy *buddy = self.buddyLosit[indexPath.row];
        NSString *userName = buddy.username;
        
        // 删除好友 YES对方好友列表看不到我
        [[EaseMob sharedInstance].chatManager removeBuddy:userName removeFromRemote:YES error:nil];
    }
        
}
#pragma mark - 监听被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    [self loadBuddyListFromServer];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 往聊天控制器 传递一个buddy对象
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[ChatViewController class]]) {
        // 获取点击的行
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        
        ChatViewController *chat = destVC;
        chat.buddy = self.buddyLosit[selectedRow];
    }
}
@end
