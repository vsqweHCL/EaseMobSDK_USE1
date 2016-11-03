//
//  TimeTool.m
//  环信使用
//
//  Created by HCL黄 on 16/11/2.
//  Copyright © 2016年 HCL黄. All rights reserved.
//

#import "TimeTool.h"

@implementation TimeTool
+ (NSString *)timeStr:(long long)time
{
    // 返回时间格式
   
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 1.获取当前时间
    NSDate *currentDate = [NSDate date];
    // 获取年、月、日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    
    // 2.获取消息发送时间
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
    // 获取年、月、日
    components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:msgDate];
    NSInteger msgYear = components.year;
    NSInteger msgMonth = components.month;
    NSInteger msgDay = components.day;
    
    // 判断
    /*
     *  今天：(HH:mm)
     *  昨天：(昨天 HH:mm)
     *  昨天以前：(2015-09-26 15:22)
     */
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    if (currentYear == msgYear &&
        currentMonth == msgMonth &&
        currentDay == msgDay) { // 今天
        dateFmt.dateFormat = @"HH:mm";
    }
    else if (currentYear == msgYear &&
             currentMonth == msgMonth &&
             currentDay - 1 == msgDay) { // 昨天
        dateFmt.dateFormat = @"昨天 HH:mm";
    }
    else {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    return [dateFmt stringFromDate:msgDate];
}
@end
