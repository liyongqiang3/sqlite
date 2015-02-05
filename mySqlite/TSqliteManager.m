//
//  TSqliteManager.m
//  CrashLog
//
//  Created by 李永强 on 15/1/29.
//  Copyright (c) 2015年 tongbaotu. All rights reserved.
//

#import "TSqliteManager.h"
#define  TABLENAME @"event_table"
#define  EVENTID @"eventId"
#define  TIME @"timestamp"
#define TYPE @"type"

@implementation TSqliteManager
+(TSqliteManager *)shareInstance
{
    static TSqliteManager * manager = nil ;
    static dispatch_once_t token ;
    dispatch_once(&token, ^{
        manager = [[TSqliteManager alloc]initManager];
    });
    return manager ;
}
-(id)initManager{
    self = [super init];
    if (self) {

    }
    return self ;
}
-(id)init
{
    return  [TSqliteManager shareInstance];
}
-(void)creatSqliteDb:(NSString *)dbName
{
     NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString * dbPath = [docsdir stringByAppendingFormat:@"/Caches/%@",dbName];
    TLog(@"______path_______%@",dbPath);
    baseDbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];

    [baseDbQueue inDatabase:^(FMDatabase *db) {
    NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER, '%@' TEXT)",TABLENAME,@"fid",EVENTID,TYPE,TIME];
        [db executeUpdate:sqlCreateTable];
    }];

}

-(void)insertSqliteDb:(TEvent *)event {



    [baseDbQueue  inDatabase:^(FMDatabase *db) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', '%@', '%@')",
                               TABLENAME, EVENTID, TYPE, TIME, event.eventId,event.type, event.timestamp];
        [db executeUpdate:insertSql1];

    }];
}

-(NSMutableArray *)seleteSqliteDb {

    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    __block  TSqliteManager * weekSelf = self ;
    [baseDbQueue  inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:
                          @"SELECT * FROM %@",TABLENAME];
         FMResultSet *rs = [db executeQuery:sql];
        while ([rs  next]) {
            TEvent * myEvent = [[TEvent alloc]init];
            myEvent.eventId = [rs stringForColumn:EVENTID];
            myEvent.timestamp = [rs stringForColumn:TIME];
            myEvent.type = [rs stringForColumn:TYPE];
            [dataArray addObject:myEvent];
        }
       NSString * jsonString =  [self stringDataJson:dataArray];
        TLog(@"-----jsonData----%@",jsonString);
        [weekSelf updateStatistit:jsonString];

    }];
    return dataArray ;
}

-(void)deleteSqliteDb{
       NSString * deleteSql = [NSString  stringWithFormat:@"delete from %@",TABLENAME];
    [baseDbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];

    }];
}

-(NSString *)stringDataJson:(NSArray *)dataArray
{
    NSString * allString = @"[";
    BOOL isFrist = NO ;
    for (TEvent * myEvent in dataArray ) {
        if (isFrist == NO) {
            allString = [allString stringByAppendingFormat:@"{\"id\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}",myEvent.eventId,myEvent.type,myEvent.timestamp];
            isFrist = YES ;
        } else {
            allString = [allString stringByAppendingFormat:@",{\"id\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}",myEvent.eventId,myEvent.type,myEvent.timestamp];
        }
    }
    allString  = [allString stringByAppendingString:@"]"];
    return allString ;

}
-(void)updateStatistit:(NSString *)jsonData
{
        NSUUID * uuid = [[UIDevice currentDevice]identifierForVendor];
        NSString * device_type = [UIDevice currentDevice].model ;
        NSString * system_type = @"iOS";
        NSString * system_version =  [UIDevice currentDevice].systemVersion ;
        NSString * app_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        TLog(@"---json-----%@",jsonData);
        NSDictionary * params = [[NSDictionary alloc]initWithObjectsAndKeys:
                                 system_type,@"system_type",
                                 device_type,@"device_type",
                                 system_version,@"system_version",
                                 uuid.UUIDString,@"uuid",
                                 app_version,@"app_version",
                                 jsonData,@"data",
                                 nil];
    __block  TSqliteManager * weekSelf = self ;
        [LSessionRequest post:API_SYSTME_STATISTICS params:params callback:^(LResponse *response) {
            if ([response.status integerValue] == normalType) {
                NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                NSString *nowDate = [NSString stringWithFormat:@"%li", (long)[dat timeIntervalSince1970]];
                 [[NSUserDefaults standardUserDefaults]setObject:nowDate forKey:TIME_STSMP];
                [weekSelf deleteSqliteDb];
            }
        }];


}

@end
