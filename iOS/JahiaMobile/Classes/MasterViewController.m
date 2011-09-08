//
//  MasterViewController.m
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MasterViewController.h"
#import "CommonDetailViewController.h"
#import "InputViewController.h"
#import "Configuration.h"
#import "FileUtils.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation MasterViewController

@synthesize detailViewController, fetchedResultsController, managedObjectContext, searchResults, listName, listQuery, inputViewController;

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}


#pragma mark -
#pragma mark View lifecycle

- (void) loadListData {
  Configuration *config = [Configuration sharedInstance];
		
	NSString *loginString = [NSString stringWithFormat:@"%@/cms/login", config.baseURL, nil];
	NSURL *loginUrl = [NSURL URLWithString:loginString];
	ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:loginUrl];
	[loginRequest setPostValue:config.username forKey:@"username"];
	[loginRequest setPostValue:config.password forKey:@"password"];	
	[loginRequest setPostValue:@"1" forKey:@"doLogin"];	
	[loginRequest setPostValue:@"1" forKey:@"loginFromTag"];	
	[loginRequest setPostValue:@"false" forKey:@"redirectActive"];	
	[loginRequest startSynchronous];
	NSError *error = [loginRequest error];
	NSString *loginResponse = nil;
	if (!error) {
		loginResponse = [loginRequest responseString];
	}

	NSString *findString = [NSString stringWithFormat:@"%@/cms/find/%@/%@", config.baseURL, [config getWorkspace], config.language, nil];
	NSURL *findUrl = [NSURL URLWithString:findString];
	ASIFormDataRequest *findRequest = [ASIFormDataRequest requestWithURL:findUrl];
    NSLog(@"Using query : %@", listQuery);
	[findRequest setPostValue:listQuery forKey:@"query"];
	[findRequest setPostValue:@"JCR-SQL2" forKey:@"language"];	
	[findRequest setPostValue:@"1" forKey:@"depthLimit"];	
	[findRequest setPostValue:@"20" forKey:@"limit"];	
    [findRequest setPostValue:@"true" forKey:@"getNodes"];
	[findRequest startSynchronous];
	error = [findRequest error];
	NSString *findResponse = nil;
	if (!error) {
		findResponse = [findRequest responseString];
	} else {
		NSLog(@"Error %@ in request %@", findRequest, error);
	}
	// Create SBJSON object to parse JSON
	SBJSON *parser = [[SBJSON alloc] init];
	
	// parse the JSON string into an object - assuming json_string is a NSString of JSON data
	self.searchResults = [parser objectWithString:findResponse error:nil];
	
    NSLog(@"JSON parsed objects : %@", [self.searchResults description]);
	[parser release];
	
	[self displayElementAtIndex:0];
	
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	[self.view reloadData];
}

- (IBAction)insertNewObject:sender {
	inputViewController = [[InputViewController alloc] initWithNibName:@"InputViewController" bundle:nil];
	inputViewController.callingViewController = self;
	inputViewController.masterViewController = self;
	inputViewController.controllerTitle = self.listName;
	
	[self.navigationController pushViewController:inputViewController animated:YES];
}

- (void)dismissController:(UIViewController *)viewController {
	[self.navigationController popViewControllerAnimated:YES];
	self.inputViewController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadListData];

	[self.navigationItem setRightBarButtonItem:
	 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)]];

}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/
/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
 */

#pragma mark -
#pragma mark Add a new object

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    // return [sectionInfo numberOfObjects];
	return [searchResults count];
}

- (NSString *)removeTagsIn:(NSString *)inputString startingWith:(NSString *)tagPrefix endingWith:(NSString *)tagSuffix {
	if (inputString == nil) {
		return inputString;
	}
	NSString *result = [NSString stringWithString:inputString]; 
	NSRange firstMarkerPos = [result rangeOfString:tagPrefix options:0 range:NSMakeRange(0, [result length])];
	while (firstMarkerPos.location != NSNotFound) {
	    NSRange endMarkerPos = [result rangeOfString:tagSuffix options:0 range:NSMakeRange(firstMarkerPos.location + [tagPrefix length], [result length] - (firstMarkerPos.location + [tagPrefix length]))];
		if (endMarkerPos.location != NSNotFound) {
			NSString *tagName = [result substringWithRange:NSMakeRange(firstMarkerPos.location + [tagPrefix length], endMarkerPos.location - firstMarkerPos.location - [tagPrefix length])];
			NSString *completeTag = [result substringWithRange:NSMakeRange(firstMarkerPos.location, endMarkerPos.location - firstMarkerPos.location + [tagSuffix length])];
			result = [result stringByReplacingOccurrencesOfString:completeTag withString:@""];
		}
		firstMarkerPos = [result rangeOfString:tagPrefix options:0 range:NSMakeRange(0, [result length])];
	}
	return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    // NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    // cell.textLabel.text = [[managedObject valueForKey:@"timeStamp"] description];
	NSDictionary *mappings = [[Configuration sharedInstance] mappingsForTabBarConfig:self.listName];
	NSDictionary *node = [searchResults objectAtIndex:indexPath.row];
	NSString *cellTitle = [node objectForKey:[mappings objectForKey:@"title"]];
	cell.textLabel.text = [self removeTagsIn:cellTitle startingWith:@"<" endingWith:@">"];
	NSString *cellSubTitle = [node objectForKey:[mappings objectForKey:@"subtitle"]];
	cell.detailTextLabel.text = [self removeTagsIn:cellSubTitle startingWith:@"<" endingWith:@">"];
	NSString *imagePath = [self findObjectInNodeOrSubNodes:node forKey:[mappings objectForKey:@"image"]];
	UIImage *image = nil;
	if (imagePath != nil) {
		image = [[FileUtils sharedInstance] retrieveUIImage:imagePath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	} else {
		image = [UIImage imageNamed:@"jahia72x72.png"];
	}
	cell.imageView.image = image;
    
    return cell;
}

- (NSString *)findObjectInNodeOrSubNodes:(NSDictionary *)node forKey:(NSString *)key {
	NSString *result = [node objectForKey:key];
	if (result != nil) {
		NSLog(@"Found key %@", key);
		return result;
	}
		for (id curKey in node) {
			id subNode = [node objectForKey:curKey];
			if ([subNode isKindOfClass:[NSDictionary class]]) {
				result = [self findObjectInNodeOrSubNodes:subNode forKey:key];
				if (result != nil) {
					return result;
				}
			} else if ([subNode isKindOfClass:[NSArray class]]) {
				NSEnumerator *e = [subNode objectEnumerator];
				id object;
				while ((object = [e nextObject])) {
					if ([object isKindOfClass:[NSDictionary class]]) {
						result = [self findObjectInNodeOrSubNodes:object forKey:key];
						if (result != nil) {
							return result;
						}
					}
				}
			}
		}
	return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void) displayElementAtIndex: (NSUInteger )index  {
	
	if (index >= [searchResults count]) {
		NSLog(@"Request an object that doesn't existing, aborting...");
		return;
	}

	Configuration *config = [Configuration sharedInstance];

	NSDictionary *mappings = [config mappingsForTabBarConfig:self.listName];
    
	NSMutableDictionary *node = [searchResults objectAtIndex:index];
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/cms/render/%@/%@", config.baseURL, [config getWorkspace], config.language, nil];
	NSString *fullPath = [node objectForKey:[mappings objectForKey:@"path"]];
	if (fullPath != nil) {
		[urlString appendString:fullPath];
		[urlString appendString:@".html"];
		
		[detailViewController changeURL:urlString urlTitle:[node objectForKey:[mappings objectForKey:@"title"]] element:node];		
	} else {
		NSLog(@"Full path %@ not found, cannot load content !", fullPath);
	}

}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

#ifdef IPHONE_ONLY
    [[self navigationController] pushViewController:detailViewController animated:YES];
#endif
	
	[self displayElementAtIndex: indexPath.row];

}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
}

/*
 Instead of using controllerDidChangeContent: to respond to all changes, you can implement all the delegate methods to update the table view in response to individual changes.  This may have performance implications if a large number of changes are made simultaneously.

// Notifies the delegate that section and object changes are about to be processed and notifications will be sent. 
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	// Update the table view appropriately.
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	// Update the table view appropriately.
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
} 
*/


#pragma mark -
#pragma mark Memory management

- (void)dealloc {

	[detailViewController release];
	[fetchedResultsController release];
	[managedObjectContext release];
    
	[super dealloc];
}

@end
