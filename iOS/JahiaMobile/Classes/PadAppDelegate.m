//
//  iPadJahiaAppDelegate.m
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "PadAppDelegate.h"

#import "MasterViewController.h"
#import "PadDetailViewController.h"
#import "MailComposerViewController.h"
#import "SearchViewController.h"
#import "MasterTabBarController.h"

@implementation PadAppDelegate

// @synthesize window, splitViewController, masterViewController, detailViewController, tabBarViewController;
@synthesize window, tabBarViewController;


#pragma mark -
#pragma mark Application lifecycle

- (UIViewController *) setupTabViewController:(NSString *)controllerTitle withQuery:(NSString *)query {
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
	masterViewController.managedObjectContext = self.managedObjectContext;
	masterViewController.listName = controllerTitle;
	masterViewController.listQuery = query;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
	navigationController.navigationBar.topItem.title = controllerTitle;
    
    PadDetailViewController *detailViewController = [[PadDetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	detailViewController.controllerTitle = controllerTitle;
	detailViewController.masterViewController = masterViewController;
    masterViewController.detailViewController = detailViewController;
    
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
	splitViewController.title = @"News View Controller";
	
	// UIImage* anImage = [UIImage imageNamed:@"MyViewControllerImage.png"];
	UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:controllerTitle image:[UIImage imageNamed:@"1.png"] tag:0];
	splitViewController.tabBarItem = theItem;
	[theItem release];	
    splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
	splitViewController.delegate = detailViewController;
	return splitViewController;

}

- (UIViewController *)setupSearchViewController:(NSString *)controllerTitle withQuery:(NSString *)query {
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
	searchViewController.listName = controllerTitle;
	searchViewController.listQuery = query;
	NSArray *listContent = [[NSArray alloc] init];
	searchViewController.listContent = listContent;
	[listContent release];
	
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
	navigationController.navigationBar.topItem.title = controllerTitle;
    
    PadDetailViewController *detailViewController = [[PadDetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	detailViewController.controllerTitle = controllerTitle;
 	detailViewController.masterViewController = searchViewController;
    searchViewController.detailViewController = detailViewController;
    
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
	splitViewController.title = @"Users View Controller";
	
	// UIImage* anImage = [UIImage imageNamed:@"MyViewControllerImage.png"];
	UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:controllerTitle image:[UIImage imageNamed:@"1.png"] tag:0];
	splitViewController.tabBarItem = theItem;
	[theItem release];	
    splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
	splitViewController.delegate = detailViewController;
	return splitViewController;
	
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
	tabBarViewController = [[MasterTabBarController alloc] init];
	
	NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
	
	NSArray *tabBarConfig = [self getTabBarConfig];
	for (NSDictionary *tabConfiguration in tabBarConfig) {
		NSString *configType = [tabConfiguration objectForKey:@"type"];
		if ([configType isEqualToString:@"query"]) {
			UIViewController *queryViewController = [self setupTabViewController:[tabConfiguration objectForKey:@"name"] withQuery:[tabConfiguration objectForKey:@"query"]];
			[viewControllers addObject:queryViewController];
		} else if ([configType isEqualToString:@"search"]) {
			UIViewController *searchUsersTabViewController = [self setupSearchViewController:[tabConfiguration objectForKey:@"name"] withQuery:[tabConfiguration objectForKey:@"query"]];
			[viewControllers addObject:searchUsersTabViewController];
		} else if ([configType isEqualToString:@"contact"]) {
			MailComposerViewController *mailComposerViewController = [[MailComposerViewController alloc] initWithNibName:@"MailComposerViewController" bundle:nil];
			UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"Contact Us" image:nil tag:0];	
			mailComposerViewController.tabBarItem = theItem;
			[theItem release];
			[viewControllers addObject:mailComposerViewController];
		}
	}
	
	tabBarViewController.viewControllers = viewControllers;	
    
	// Add the split view controller's view to the window and display.
	[window addSubview:tabBarViewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

- (void) didRotate:(NSNotification *)notification
{   
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [UIView beginAnimations:nil context:NULL];  
	
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        [tabBarViewController.view setAlpha:0.0];
        [tabBarViewController.view removeFromSuperview];
		
        [UIApplication sharedApplication].statusBarHidden = YES; 
    } else {
        [tabBarViewController.view setAlpha:1.0];
        [UIApplication sharedApplication].statusBarHidden = NO; 
    }
    [UIView commitAnimations];  
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"iPadJahia.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	//[splitViewController release];
	//[masterViewController release];
	//[detailViewController release];

	[window release];
	[super dealloc];
}


@end

