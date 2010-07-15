//
//  JahiaPhoneAppDelegate.h
//  iPadJahia
//
//  Created by Serge Huber on 11.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAppDelegate.h"
#import <CoreData/CoreData.h>

@class MasterTabBarController;

@interface PhoneAppDelegate : AbstractAppDelegate <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;
	MasterTabBarController *tabBarViewController;

}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,retain) IBOutlet MasterTabBarController *tabBarViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
