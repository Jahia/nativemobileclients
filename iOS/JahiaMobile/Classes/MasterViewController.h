//
//  MasterViewController.h
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class InputViewController;
@class CommonDetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
 	InputViewController *inputViewController;
   
    CommonDetailViewController *detailViewController;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	NSArray *searchResults;
	NSString *listName;
	NSString *listQuery;
}

@property (nonatomic, retain) IBOutlet CommonDetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet InputViewController *inputViewController;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) NSString *listName;
@property (nonatomic, retain) NSString *listQuery;

- (void)insertNewObject:sender;
- (void) loadListData;
- (void)dismissController:(UIViewController *)viewController;
@end
