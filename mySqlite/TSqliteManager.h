//
//  TSqliteManager.h
//  CrashLog
//
//  Created by 李永强 on 15/1/29.
//  Copyright (c) 2015年 tongbaotu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "TEvent.h"
@interface TSqliteManager : NSObject
{
    FMDatabaseQueue * baseDbQueue ;

}
@property (strong,nonatomic) NSMutableArray * jsonArray ;
+(TSqliteManager *)shareInstance ;

//+(NSString *)stringDataJson:(NSArray * )dataArray ;


-(void)creatSqliteDb:(NSString *)dbName ;

-(void)insertSqliteDb:(TEvent *)event ;

-(NSMutableArray *)seleteSqliteDb ;

-(void)deleteSqliteDb;


@end
