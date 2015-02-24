//
//  AppDelegate.m
//  MCTObjectStoreAppTest
//
//  Created by Skylar Schipper on 2/23/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import "AppDelegate.h"

@import MCTObjectStore;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *URL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"database.sqlite"]];
    
    NSError *error = nil;
    if (![[MCTObjectStack sharedStack] prepareModelWithName:@"ListModel" bundle:[NSBundle mainBundle] location:URL error:&error]) {
        if (error) {
            NSLog(@"Failed to setup CoreData: %@",error);
        }
    }
    
    return YES;
}

@end
