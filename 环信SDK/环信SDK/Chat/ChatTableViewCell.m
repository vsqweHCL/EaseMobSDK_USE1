//
//  ChatTableViewCell.m
//  环信使用
//
//  Created by HCL黄 on 16/11/1.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "AudioPlayTool.h"
#import "UIImageView+WebCache.h"

@interface ChatTableViewCell ()

/** 聊天图片 */
@property (nonatomic, strong) UIImageView *chatImage;
@end

@implementation ChatTableViewCell
- (UIImageView *)chatImage
{
    if (_chatImage == nil) {
        _chatImage = [[UIImageView alloc] init];
    }
    return _chatImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
}
#pragma mark - messageLabel点击
- (void)messageLabelTap:(UITapGestureRecognizer *)tap
{
    // 播放语音
    // 只有当前的类型是语音消息的时候才播放
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        NSLog(@"播放语音");
        BOOL receiver = [self.reuseIdentifier isEqualToString:ID1];
        [AudioPlayTool playWithMessage:self.message msgLabel:self.messageLabel receiver:receiver];
    }
    
}
- (void)setMessage:(EMMessage *)message
{
    _message = message;
    
    // 重用时，把图片控件移除
    [self.chatImage removeFromSuperview];
    
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) { // 文本消息
        EMTextMessageBody *textBody = body;
        self.messageLabel.text = textBody.text;
        
    }
    else if ([body isKindOfClass:[EMVoiceMessageBody class]]) { // 语音消息
        self.messageLabel.attributedText = [self voiceAtt];
        
    }
    else if ([body isKindOfClass:[EMImageMessageBody class]]) { // 图片消息
        [self showImage];
        
    }
    else {
        self.messageLabel.text = @"未知的类型";
        
    }
    
}

- (void)showImage
{
    EMImageMessageBody *imgBody = self.message.messageBodies[0];
    
    // 设置label的尺寸足够显示UIImageView 占位图片
    NSTextAttachment *achment = [[NSTextAttachment alloc] init];
    achment.bounds = (CGRect){0, 0, imgBody.thumbnailSize};
    NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:achment];
    self.messageLabel.attributedText = imgAtt;
    
    // 1.cell添加一个UIImageView
    [self.messageLabel addSubview:self.chatImage];
    
    // 2.图片控件为缩略图的大小
    self.chatImage.frame = (CGRect){0, 0, imgBody.thumbnailSize};
    
    // 3.下载图片
    NSFileManager *manger = [NSFileManager defaultManager];
    // 如果本地图片有，就直接用本地图片
    if ([manger fileExistsAtPath:imgBody.thumbnailLocalPath]) {
        [self.chatImage sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
    else {// 如果本地图片没有，就下载远程服务器图片
        [self.chatImage sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
    
    
    // 设置菊花
//    [self setupActivity];
}
- (void)setupActivity
{
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [self.contentView addSubview:act];
    
    if ([self.reuseIdentifier isEqualToString:ID1]) {
        CGFloat y = self.messageLabel.frame.size.height;
        CGFloat x = CGRectGetMaxX(self.messageLabel.frame) + 5 + 30 + 5;
        act.center = CGPointMake(x, y);
    }
    else {
        
    }
    
    [act startAnimating];
}
#pragma mark - 返回语音的富文本
- (NSAttributedString *)voiceAtt
{
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    if ([self.reuseIdentifier isEqualToString:ID1]) {
        // 接收方：富文本 = 图片 + 时间
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -8, 30, 30);
        // 创建图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
        // 创建时间富文本
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
    }
    else {
        // 发送方：富文本 = 时间 + 图片
        // 创建时间富文本
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        UIImage *senderImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = senderImg;
        imgAttachment.bounds = CGRectMake(0, -8, 30, 30);
        // 创建图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
    }
    
    
    
    return [voiceAttM copy];
}

- (CGFloat)cellHeight
{
    // 强制布局子控件
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
  
}

@end
