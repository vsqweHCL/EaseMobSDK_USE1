//
//  AudioPlayTool.m
//  环信使用
//
//  Created by HCL黄 on 16/11/2.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "AudioPlayTool.h"
#import "EMCDDeviceManager+Media.h"

static UIImageView *animatingImageView = nil;

@implementation AudioPlayTool
+ (void)playWithMessage:(EMMessage *)message msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver
{
    // 把以前的动画移除
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    EMVoiceMessageBody *body = message.messageBodies[0];
    NSString *path = body.localPath;
    // 如果本地语音文件不存在，使用服务器语音
    NSFileManager *manger = [NSFileManager defaultManager];
    if (![manger fileExistsAtPath:path]) {
        path = body.remotePath;
    }
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        if (!error) {
            NSLog(@"语音播放完毕");
        }
        else {
            NSLog(@"语音播放失败 - %@",error);
        }
        
        // 移除动画
        [animatingImageView stopAnimating];
        [animatingImageView removeFromSuperview];
    }];

    // 添加动画
    UIImageView *imgView = [[UIImageView alloc] init];
    [msgLabel addSubview:imgView];
    
    UIImage *img0 = nil;
    UIImage *img1 = nil;
    UIImage *img2 = nil;
    UIImage *img3 = nil;
    if (receiver) {
        imgView.frame = CGRectMake(0, 0, 30, 30);
        img0 = [UIImage imageNamed:@"chat_receiver_audio_playing000"];
        img1 = [UIImage imageNamed:@"chat_receiver_audio_playing001"];
        img2 = [UIImage imageNamed:@"chat_receiver_audio_playing002"];
        img3 = [UIImage imageNamed:@"chat_receiver_audio_playing003"];
    }
    else {
        imgView.frame = CGRectMake(msgLabel.bounds.size.width - 30, 0, 30, 30);
        img0 = [UIImage imageNamed:@"chat_sender_audio_playing_000"];
        img1 = [UIImage imageNamed:@"chat_sender_audio_playing_001"];
        img2 = [UIImage imageNamed:@"chat_sender_audio_playing_002"];
        img3 = [UIImage imageNamed:@"chat_sender_audio_playing_003"];
    }
    imgView.animationImages = @[img0,img1,img2,img3];
    imgView.animationDuration = 1;
    [imgView startAnimating];
    
    animatingImageView = imgView;
}

+ (void)stop
{
    // 停止播放
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    
    // 移除动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
}
@end
