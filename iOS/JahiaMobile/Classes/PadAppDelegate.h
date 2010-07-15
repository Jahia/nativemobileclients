//
//  iPadJahiaAppDelegate.h
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AbstractAppDelegate.h"

@class MasterTabBarController;
@class MasterViewController;
@class PadDetailViewController;

@interface PadAppDelegate : AbstractAppDelegate <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;

//	UISplitViewController *splitViewController;
	MasterTabBarController *tabBarViewController;

//	MasterViewController *masterViewController;
//	DetailViewController *detailViewController;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;

//@property (nonatomic,retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic,retain) IBOutlet MasterTabBarController *tabBarViewController;
//@property (nonatomic,retain) IBOutlet MasterViewController *masterViewController;
//@property (nonatomic,retain) IBOutlet DetailViewController *detailViewController;

@end
