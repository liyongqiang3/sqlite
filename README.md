# sqlite
FMDB   sqlite
// 创建 TSqlitemanager 单实例
+(TSqliteManager *)shareInstance
{
    static TSqliteManager * manager = nil ;
    static dispatch_once_t token ;
    dispatch_once(&token, ^{
        manager = [[TSqliteManager alloc]initManager];
    });
    return manager ;
}
// 自定义好初始化方法
-(id)initManager{
    self = [super init];
    if (self) {

    }
    return self ;
}
// 目的是创建唯一的单实例
-(id)init
{
    return  [TSqliteManager shareInstance];
}
// 创建 数据库
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
// 输入数据 
-(void)insertSqliteDb:(TEvent *)event {



    [baseDbQueue  inDatabase:^(FMDatabase *db) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', '%@', '%@')",
                               TABLENAME, EVENTID, TYPE, TIME, event.eventId,event.type, event.timestamp];
        [db executeUpdate:insertSql1];

    }];
}
// 删除数据
-(void)deleteSqliteDb
