//
//  AppDelegate.h
//  TesseractSample
//
//  Created by Ruxandra Nistor on 4/25/12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArchiveViewController.h"
#import "TesseractWrapper.h"



@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) ArchiveViewController * archiveViewController;



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong) TesseractWrapper * tessWrap;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)getDocumentsDirectory;
@end
