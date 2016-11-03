//
//  ConversationTableViewController.m
//  环信使用
//
//  Created by HCL黄 on 16/10/31.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "ConversationTableViewController.h"
#import "EaseMob.h"
#import "ChatViewController.h"

@interface ConversationTableViewController () <EMChatManagerDelegate>

/** 历史会话记录 */
@property (nonatomic, strong) NSArray *conversations;
@end

@implementation ConversationTableViewController
- (void)dealloc
{
    // 移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 获取历史会话记录
    [self loadConversations];
    
    // 显示总的未读消息数
    [self showTabBarBadge];
    
}
#pragma mark - 获取历史会话记录
- (void)loadConversations
{
    // 1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    // 2.如果内存里没有会话记录，从数据库Conversations表
    if (conversations.count == 0) {
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    self.conversations = conversations;
}

//
#pragma mark - 监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开，未连接...");
        self.title = @"网络断开，未连接...";
    }
    else {
        NSLog(@"网络连通，连接成功");
    }
}
// 监听自动连接的状态
#pragma mark - 监听自动连接的状态
- (void)willAutoReconnect
{
    NSLog(@"将自动重连接...");
    self.title = @"连接中...";
}
#pragma mark - 监听自动连接结束
- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"自动重连接成功...");
        self.title = @"会话";
    }
    else {
        NSLog(@"自动重连接失败...%@",error);
    }
}
/*!
 @method
 @brief 好友请求被接受时的回调
 @discussion
 @param username 之前发出的好友请求被用户username接受了
 */
#pragma mark - 好友请求被接受时的回调
- (void)didAcceptedByBuddy:(NSString *)username
{
    NSString *text = [NSString stringWithFormat:@"%@同意了你的请求",username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/*!
 @method
 @brief 好友请求被拒绝时的回调
 @discussion
 @param username 之前发出的好友请求被用户username拒绝了
 */
#pragma mark - 好友请求被拒绝时的回调
- (void)didRejectedByBuddy:(NSString *)username
{
    NSString *text = [NSString stringWithFormat:@"%@拒绝了你的请求",username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
/*!
 @method
 @brief 接收到好友请求时的通知
 @discussion
 @param username 发起好友请求的用户username
 @param message  收到好友请求时的say hello消息
 */
#pragma mark - 接受好友的添加请求
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    
    NSString *text = [NSString stringWithFormat:@"%@请求添加您为好友",username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"拒绝");
        EMError *error;
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"我不认识你" error:&error];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"同意");
        EMError *error;
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:&error];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 监听被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    NSString *text = [NSString stringWithFormat:@"%@把你删除了",username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"conversationsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    
    EMConversation *conversation = self.conversations[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   未读消息数%ld",conversation.chatter,[conversation unreadMessagesCount]];
    
    EMMessage *message = conversation.latestMessage;
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBoy = body;
        cell.detailTextLabel.text = textBoy.text;
    }
    else if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        EMVoiceMessageBody *voiceBoy = body;
        cell.detailTextLabel.text = voiceBoy.displayName;
    }
    else if ([body isKindOfClass:[EMImageMessageBody class]]) {
        EMImageMessageBody *imgBoy = body;
        cell.detailTextLabel.text = imgBoy.displayName;
    }
    else {
        cell.detailTextLabel.text = @"未知的消息类型";
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从storyboard加载聊天控制器
    ChatViewController *chat = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chatPage"];
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    chat.buddy = buddy;
    [self.navigationController pushViewController:chat animated:YES];
}


#pragma mark - 未读消息数发生改变
- (void)didUnreadMessagesCountChanged
{
    // 更新表格
    [self.tableView reloadData];
    
    // 显示总的未读消息数
    [self showTabBarBadge];
}
#pragma mark - 历史会话列表更新
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    self.conversations = conversationList;
    
    [self.tableView reloadData];
    
    // 显示总的未读消息数
    [self showTabBarBadge];
}

#pragma mark - 显示总的未读数
- (void)showTabBarBadge
{
    NSInteger totalUnreadCount = 0;
    // 遍历所有的会话记录，将未读的消息数进行累加
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",totalUnreadCount];
}
@end
