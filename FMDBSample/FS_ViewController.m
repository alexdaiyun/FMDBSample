//
//  FS_ViewController.m
//  FMDBSample
//
//  Created by dai yun on 13-4-10.
//  Copyright (c) 2013年 alexday dev. All rights reserved.
//

#import "FS_ViewController.h"
#import "AppUtil.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"


@interface FS_ViewController ()

@end

@implementation FS_ViewController

- (void)doSomething
{
    SLog(@"viewDidLoad");
    SLLog(@"viewDidLoad");
    SLLog(@"APP_SCREEN_WIDTH --- %f",APP_SCREEN_WIDTH);
    SLog(@"PATH_OF_APP_HOME --- %@",PATH_OF_APP_HOME);
    SLog(@"PATH_OF_TEMP --- %@",PATH_OF_TEMP);
    SLog(@"PATH_OF_DOCUMENT --- %@",PATH_OF_DOCUMENT);
    
    SLog(@"appFullName --- %@", [AppUtil appFullName]);
    
    SLog(@"source -- %@ ", [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:AppDBName]);
    
    SLog(@"documents -- %@ ", [AppUtil getAppDBPath]);
    
    SLog(@" %@ ", [PATH_OF_APP_HOME stringByAppendingPathComponent:@"Documents"]);
    
    
    [self doFMDBTest];
    
    
}

- (void)createTable
{
    NSString *db = [AppUtil getAppDBPath];
    SLLog(@"%@",db);
    
    //open db
    FMDatabase *fmdb = [ FMDatabase databaseWithPath:db];
    if (![fmdb open])
    {
        SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    else
    {
        SLLog(@"open db ");
        
        
        NSString *cmdSQL = @"CREATE TABLE '_User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'password' VARCHAR(30))";
        
        bool effect = [fmdb executeUpdate:cmdSQL];
        if (!effect)
        {
            SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
        }
        else
        {
            SLLog(@"succeed create Table ");
        }
        
        
    }
    
    
    
}

- (void)queryData
{
    NSString *db = [AppUtil getAppDBPath];
    SLLog(@"%@",db);
    
    //open db
    FMDatabase *fmdb = [ FMDatabase databaseWithPath:db];
    if (![fmdb open])
    {
        SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    else
    {
        SLLog(@"open db ");
    }
    
    [fmdb setShouldCacheStatements:(YES)];
    
    NSString *cmdSQL = @"select UserID,UserName,BirthdayYear,BirthdayMonth,Gender from TBL_User ";
    
    FMResultSet *fmRS = [fmdb executeQuery:cmdSQL];
    
    while([fmRS next])
    {
        SLLog(@"UserName: %@ BirthdayYear: %d  BirthdayMonth: %d Gender: %@", [fmRS stringForColumn:@"UserName"], [fmRS intForColumn:@"BirthdayYear"], [fmRS intForColumn:@"BirthdayMonth"], [fmRS stringForColumn:@"Gender"]);
        
    }
    
    
 
    
    
    [fmRS close];
    
    [fmdb close];
   
}


- (void)insertData
{
    NSString *db = [AppUtil getAppDBPath];
   // SLLog(@"%@",db);
    
    //open db
    FMDatabase *fmdb = [ FMDatabase databaseWithPath:db];
    if (![fmdb open])
    {
        SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    else
    {
        SLLog(@"open db ");
    }
    
    [fmdb setShouldCacheStatements:(YES)];
    
    
    
    
    // insert data
    int idx = 1;
    NSString *cmdSQL  = @"insert into TBL_User (UserName,BirthdayYear,BirthdayMonth,Gender) values(?,2011,11,'F')";
    NSString *userName = [NSString stringWithFormat:@"testUser_%d", idx++];
    bool effect = [fmdb executeUpdate:cmdSQL,userName];
    if (!effect)
    {
        SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    else
    {
        SLLog(@"succeed insert data");
    }
    
    
    
    
    [fmdb close];
    
}

- (void)multithreadInsertData
{
    //多线程处理
    
    /*
    NSString *db = [AppUtil getAppDBPath];
    SLLog(@"%@",db);
    
    //open db
    FMDatabase *fmdb = [ FMDatabase databaseWithPath:db];
    if (![fmdb open])
    {
        SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    else
    {
        SLLog(@"open db ");
    }
    
    [fmdb setShouldCacheStatements:(YES)];
    */
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[AppUtil getAppDBPath]];
    
    dispatch_queue_t q1 = dispatch_queue_create("queue1",NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2",NULL);
    
    dispatch_async(q1, ^{
        for (int i=0; i < 10; ++i) {
            [queue inDatabase:^(FMDatabase *fmdb) {
              
                NSString *cmdSQL= @"insert into TBL_User (UserName,BirthdayYear,BirthdayMonth,Gender) values(?,2011,11,'F')";
                NSString *userName = [NSString stringWithFormat:@"testUserA_%d", i];
                
                bool effect = [fmdb executeUpdate:cmdSQL,userName];
                if (!effect)
                {
                    SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
                }
                else
                {
                    SLLog(@"succeed insert data");
                }
                
            }];
        }
    });
    
    
    dispatch_async(q2, ^{
        for (int i=0; i < 10; ++i) {
            [queue inDatabase:^(FMDatabase *fmdb) {
                
                NSString *cmdSQL= @"insert into TBL_User (UserName,BirthdayYear,BirthdayMonth,Gender) values(?,2011,11,'F')";
                NSString *userName = [NSString stringWithFormat:@"testUserB_%d", i];
                
                bool effect = [fmdb executeUpdate:cmdSQL,userName];
                if (!effect)
                {
                    SLLog(@"Error %d: %@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
                }
                else
                {
                    SLLog(@"succeed insert data");
                }
                
            }];
        }
    });
    
    
    
    
}

//直接调用FMDB组件
- (void)doFMDBTest
{
    [self queryData];
   // [self insertData];
   // [self queryData];
    //[self multithreadInsertData];
   // [self queryData];
    
}

#pragma mark - View lifecyle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self doSomething];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    }

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
        
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SupportedOrientations


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscape;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ( UIDeviceOrientationIsLandscape(orientation))
    {
        return YES;
    }
    return NO;
}

@end
