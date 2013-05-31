//
//  AppDelegate.m
//  TestMultiTask
//
//  Created by Mike Chen on 13-5-30.
//  Copyright (c) 2013年 BeyondSoft Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic , unsafe_unretained)UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic , retain) NSTimer *myTimer;

@end

@implementation AppDelegate

@synthesize backgroundTaskIdentifier;
@synthesize myTimer = _myTimer;

- (void)dealloc
{
    [_myTimer release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor purpleColor];
    [self.window makeKeyAndVisible];
     
    NSLog(@"启动时候的字典:%@",launchOptions);
//    BOOL result = [self isMultitaskingSupported];
//    NSLog(@"result = %d",result);
//    [self localNotificationWithMessage:@"测试Message"
//                     actionButtonTitle:@"测试buttonTitle"
//                           launchImage:@"test.png"
//                      applicationBadge:0
//                        secondsFromNow:30.
//                              userInfo:@{@"aps":@{@"alert":@"本地通知测试",@"badge":@130,@"sound":@"bingbong.aiff"},@"customData":@[@"object01",@"object02"]}];
    //这里的launchOptions仅当用户通过通知启动程序且该通知附带了userInfo信息时才有值。/
    //即，如果在收到附带了userInfo的通知，但是用户点击了“取消”，没有从通知进入应用，直接从桌面点击图标进入，那么这里的launchOptions仍然为空。
    id scheduledLocalNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (scheduledLocalNotification != nil) {
        NSString *message = @"Local Notification Woke Us Up.";
        [[[[UIAlertView alloc] initWithTitle:@"Notification" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];
//        message = @"A new instant message is available.\nWould";
        

    } else{
        [self localNotificationWithMessage:@"A new instant message is available.\nWould you like to read this message?"
                         actionButtonTitle:@"YES"
                               launchImage:@"test.png"
                          applicationBadge:1
                            secondsFromNow:20.
                                  userInfo:@{@"aps":@{@"alert":@"本地通知测试",@"badge":@13,@"sound":@"bingbong.aiff"},@"customData":@[@"object01",@"object02"]}];
        NSString *message = @"A new Local Notification is set up \nto be displayed 10 seconds from now.";
        [[[[UIAlertView alloc] initWithTitle:@"Set Up" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];
    }
    return YES;
}

- (void)timerMethod:(NSTimer *)paramSender
{
    NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX) {
        NSLog(@"background Time Remaining = Undetermined.");
    } else{
        NSLog(@"Background Time Remaining = %02f seconds",backgroundTimeRemaining);
    }
}

- (BOOL)isMultitaskingSupported
{
    BOOL result = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    if ([self isMultitaskingSupported] == NO) {
//        return;
//    }
//    //进入后台时，开始运行我们设定的后台任务。
//    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
//    //设定UIBackgroundTaskIdentifier的状态为正在后台运行任务。后台时间用完后，调用endBackgroundTask来停止所有的线程和定时器；调用endBackgroundTask:方法结束后台任务；将任务标志设置为UIBackgroundTaskInvalid，标志我们的任务结束
//    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void){
//        [self endBackgroundTask];
//    }];
}

- (void)endBackgroundTask
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void){
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.myTimer invalidate];
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

//希望在程序没有运行时，可以向用户展示一个警告；在没有使用推送消息的情况下，可在程序中创建本地警告
- (BOOL)localNotificationWithMessage:(NSString *)paramMessage actionButtonTitle:(NSString *)paramActionButtonTitle launchImage:(NSString *)paramLaunchImage applicationBadge:(NSInteger)paramApplicationBadge secondsFromNow:(NSTimeInterval)paramSecondsFromNow userInfo:(NSDictionary *)paramUserInfo
{
    if ([paramMessage length] == 0) {
        return NO;
    }
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    notification.alertBody = paramMessage;
    notification.alertAction = paramActionButtonTitle;
    if ([paramActionButtonTitle length] > 0) {
        //确保可以有一个用户用来点击进入程序的按钮
        notification.hasAction = YES;
    } else{
        notification.hasAction = NO;
    }
    notification.alertLaunchImage = paramLaunchImage;
    //改变桌面上图标的badge数量，即使用户选择了“取消”按钮
    notification.applicationIconBadgeNumber = paramApplicationBadge;
    notification.userInfo = paramUserInfo;
    //调整时区，以便期间用户时区发生改变，用户仍能按时收到提醒
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    notification.timeZone = timeZone;
    NSDate *today = [NSDate date];
    NSDate *fireDate = [today dateByAddingTimeInterval:paramSecondsFromNow];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger dateComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:dateComponents fromDate:fireDate];
    fireDate = [calendar dateFromComponents:components];
    notification.fireDate = fireDate;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //如果在后台执行长期任务时程序被换到前台，我们应该终止后台任务
//    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
//        [self endBackgroundTask];
//    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"userInfo = %@",notification.userInfo);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:/*[[notification.userInfo valueForKeyPath:@"aps.badge"] integerValue]*/0] ;
    NSString *message = @"The Local Notification is delivered.";
    [[[UIAlertView alloc] initWithTitle:@"Local Notification" message:message
                               delegate:nil cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
