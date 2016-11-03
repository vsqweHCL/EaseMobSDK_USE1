//
//  ChatViewController.m
//  环信使用
//
//  Created by HCL黄 on 16/11/1.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "EMCDDeviceManager+Media.h"
#import "AudioPlayTool.h"
#import "TimeTableViewCell.h"
#import "TimeTool.h"

 
@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 输入工具条底部的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
/** 输入工具条高度的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *datas;

/** 计算高度cell的工具对象 */
@property (nonatomic, strong) ChatTableViewCell *cellTool;

/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (weak, nonatomic) IBOutlet UITextView *textView;

/** 当前添加的时间 */
@property (nonatomic, copy) NSString *currentTimeStr;

/** 当前的会话对象 */
@property (nonatomic, strong) EMConversation *conversation;
@end

@implementation ChatViewController

/** 懒加载 */
- (NSMutableArray *)datas
{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.buddy.username;
    self.tableView.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    
    // 加载本地数据库聊天记录（MessageV1）
    [self loadLocalChatRecord];
    
    // 设置聊天管理器的代理，用于监听接收好友回复消息
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    
    // 给计算高度cell工具赋值
    self.cellTool = [self.tableView dequeueReusableCellWithIdentifier:ID1];

//    [self scrollToBottom];
    
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 加载本地数据库聊天记录（MessageV1）
- (void)loadLocalChatRecord
{
    /*
     @brief 会话类型
     @constant eConversationTypeChat            单聊会话
     @constant eConversationTypeGroupChat       群聊会话
     @constant eConversationTypeChatRoom        聊天室会话
     */
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    self.conversation = conversation;
    
    // 加载与当前聊天用户所有的聊天记录
    NSArray *messages = [conversation loadAllMessages];
    for (EMMessage *msg in messages) {
        [self addDataSoucesWithMessage:msg];
    }
//    [self.datas addObjectsFromArray:messages];
}
- (void)kbWillShow:(NSNotification *)noti
{
    CGRect kbFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbFrame.size.height;
    
    self.bottomConstraint.constant = kbHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)kbWillHide:(NSNotification *)noti
{
    
    self.bottomConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 判断数据源类型
    if ([self.datas[indexPath.row] isKindOfClass:[NSString class]]) { // 显示时间cell
        TimeTableViewCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
        timeCell.timeLabel.text = self.datas[indexPath.row];
        return timeCell;
    }
    
    EMMessage *msg = self.datas[indexPath.row];
    ChatTableViewCell *cell = nil;
    if ([msg.from isEqualToString:self.buddy.username]) { // 接收方
        
        cell = [tableView dequeueReusableCellWithIdentifier:ID1];
    }
    else { // 发送方
        cell = [tableView dequeueReusableCellWithIdentifier:ID2];
    }

    cell.message = msg;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.datas[indexPath.row] isKindOfClass:[NSString class]]) { // 显示时间
        return 30;
    }
    
    EMMessage *msg = self.datas[indexPath.row];
    // 先设置Label的数据
    self.cellTool.message = msg;
    
    
    return [self.cellTool cellHeight];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

#pragma mark - UITextView的代理
- (void)textViewDidChange:(UITextView *)textView
{
//    NSLog(@"%@",NSStringFromCGSize(textView.contentSize));
    // 1.计算TextView的高度，调整整个工具条的高度
    CGFloat textViewH = 0;
    CGFloat minHeight = 30; // textView最小高度
    CGFloat maxHeight = 66; // textView最大高度
    // 2.获取contenSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    }
    else if (contentHeight > maxHeight) {
        textViewH = maxHeight;
    }
    else {
        textViewH = contentHeight;
    }
//    NSLog(@"%@",textView.text);
    // 监听send事件--判断最后一个字符是不是换行字符
    if ([textView.text hasSuffix:@"\n"]) {
//        NSLog(@"发送操作");
        [self sendMessage:textView.text];
        textView.text = nil;
        
        // 发送时，textViewH的高度为33
        textViewH = minHeight;
    }
    self.heightConstraint.constant = textViewH + 8 + 8;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // 让光标回到原位
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
}
#pragma mark - 发送文本消息
- (void)sendMessage:(NSString *)text
{
    // 把最后一个换行字符去除
#warning 换行字符 只占用一个长度
    text = [text substringToIndex:text.length - 1];
    
    NSLog(@"要发送给 %@",self.buddy.username);
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    // 创建一个消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];;
    
    // 1.创建消息对象
    EMMessage *msgObjc = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[textBody]];
    /*!
     @brief 消息类型
     @constant eMessageTypeChat            单聊消息
     @constant eMessageTypeGroupChat       群聊消息
     @constant eMessageTypeChatRoom        聊天室消息
     */
    msgObjc.messageType = eMessageTypeChat;
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObjc progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"发送消息成功");
        }
        else {
            NSLog(@"发送消息失败 - %@",error);
        }
    } onQueue:nil];
    
    // 把消息添加到数据源，然后刷新表格
//    [self.datas addObject:msgObjc];
    [self addDataSoucesWithMessage:msgObjc];
    [self.tableView reloadData];
    
    // 把消息显示在底部
    [self scrollToBottom];
    
}
#pragma mark - 发送语音消息
- (void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration
{
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
//    chatVoice.duration = duration;
    // 构造语音消息体
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    // 构造一个消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[voiceBody]];
    msgObj.messageType = eMessageTypeChat;
    
    // 发送
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送语音");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"语音发送成功");
        }
        else {
            NSLog(@"语音发送失败 - %@",error);
        }
    } onQueue:nil];
    
    // 把消息添加到数据源，然后刷新表格
//    [self.datas addObject:msgObj];
    [self addDataSoucesWithMessage:msgObj];
    [self.tableView reloadData];
    
    // 把消息显示在底部
    [self scrollToBottom];
}
#pragma mark - 发送图片消息
- (void)sendImage:(UIImage *)img
{
    EMChatImage *chatImg = [[EMChatImage alloc] initWithUIImage:img displayName:@"[图片]"];
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithImage:chatImg thumbnailImage:nil];
    
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[imgBody]];
    message.messageType = eMessageTypeChat;
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送图片");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"发送图片成功");
        }
        else {
            NSLog(@"发送图片失败 - %@",error);
        }
    } onQueue:nil];
    
    
    // 把消息添加到数据源，然后刷新表格
//    [self.datas addObject:message];
    [self addDataSoucesWithMessage:message];
    [self.tableView reloadData];
    
    // 把消息显示在底部
    [self scrollToBottom];
}

#pragma mark - 把消息显示在底部
- (void)scrollToBottom
{
    // 获取最后一行
    if (self.datas.count == 0) {
        return;
    }
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.datas.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
}

#pragma mark - 接收好友回复消息
- (void)didReceiveMessage:(EMMessage *)message
{
#warning from一定要等于当前聊天用户才可以刷新数据
    if ([message.from isEqualToString:self.buddy.username]) {
        // 把接收的消息添加到数据源
//        [self.datas addObject:message];
        [self addDataSoucesWithMessage:message];
        [self.tableView reloadData];
        [self scrollToBottom];
    }
    
}

#pragma mark - 录音按钮事件
- (IBAction)voiceAction:(id)sender {
    // 显示录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    
    if (self.recordBtn.hidden == NO) { // 录音按钮要显示
        // 工具条的高度要恢复
        self.heightConstraint.constant = 46;
        // 隐藏键盘
        [self.view endEditing:YES];
    }
    else { // 当不录音的时候，显示键盘
        [self.textView becomeFirstResponder];
        
        // 保留文字内容和高度
        [self textViewDidChange:self.textView];
    }
}
#pragma mark 按钮点下去开始录音
- (IBAction)beginRecord:(id)sender {
    NSLog(@"按钮点下去开始录音");
    
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
     {
         if (error) {
             NSLog(@"开始录音失败");
         }
         else {
             NSLog(@"开始录音成功");
         }
     }];
}
#pragma mark 手指从按钮松开结束录音
- (IBAction)endRecord:(id)sender {
    NSLog(@"手指从按钮松开结束录音");
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音成功");
            NSLog(@"%@",recordPath);
            // 发送录音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        }
    }];
}
#pragma mark 手指从按钮外面松开取消录音
- (IBAction)touchUpOutside:(id)sender {
    NSLog(@"touchUpOutside");
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}
#pragma mark - 显示图片选择器
- (IBAction)showImagePicker:(id)sender {
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    
    [self sendImage:selectedImg];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止播放
    [AudioPlayTool stop];
}

- (void)dealloc
{
    // 停止播放
    [AudioPlayTool stop];
}

#pragma mark - 重新设计数据源，增加时间
- (void)addDataSoucesWithMessage:(EMMessage *)msg
{
    // 判断EMMessage对象前面是否要加“时间”
    NSString *timeStr = [TimeTool timeStr:msg.timestamp];
    if (![self.currentTimeStr isEqualToString:timeStr]) {
        [self.datas addObject:timeStr];
        self.currentTimeStr = timeStr;
    }
    
    // 再加EMMessage对象
    [self.datas addObject:msg];
    
    // 设置消息为已读
    [self.conversation markMessageWithId:msg.messageId asRead:YES];
}
@end
