//
//  AudioPlayTool.h
//  环信使用
//
//  Created by HCL黄 on 16/11/2.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMob.h"

@interface AudioPlayTool : NSObject

/** 播放语音 */
+ (void)playWithMessage:(EMMessage *)message msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

+ (void)stop;
@end
