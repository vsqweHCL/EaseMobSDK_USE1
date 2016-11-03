//
//  ChatTableViewCell.h
//  环信使用
//
//  Created by HCL黄 on 16/11/1.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMob.h"

static NSString *ID1 = @"ReceiverCell";
static NSString *ID2 = @"SeivierCell";

@interface ChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

/** 消息对象 */
@property (nonatomic, strong) EMMessage *message;

- (CGFloat)cellHeight;

@end
