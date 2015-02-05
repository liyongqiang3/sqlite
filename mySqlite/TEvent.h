//
//  TEvent.h
//  CrashLog
//
//  Created by 李永强 on 15/1/29.
//  Copyright (c) 2015年 tongbaotu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEvent : NSObject
@property (copy,nonatomic) NSString * eventId ;
@property (copy,nonatomic) NSString * type ;
@property (copy,nonatomic) NSString * timestamp;
@end
