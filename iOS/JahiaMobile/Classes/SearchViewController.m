//
//  SearchViewController.m
//  iPadJahia
//
//  Created by Serge Huber on 11.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "SearchViewController.h"
#import "Configuration.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "CommonDetailViewController.h"

@implementation SearchViewController

@synthesize listContent, filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;


#pragma mark - 
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
	self.title = @"Users";
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}


- (void)viewDidUnload
{
	// Save the state of the search UI so that it can be restored if the view is re-created.
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	
	self.filteredListContent = nil;
}


- (void)dealloc
{
	[listContent release];
	[filteredListContent release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [self.listContent count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	// Product *product = nil;
	NSDictionary *node = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        node = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        node = [self.listContent objectAtIndex:indexPath.row];
    }
	
	if (node != nil) {
		NSString *displayName = nil;
		if (([node objectForKey:@"j:firstName"] != nil) && 
			([node objectForKey:@"j:lastName"] != nil)) {
			displayName = [NSString stringWithFormat:@"%@ %@", [node objectForKey:@"j:firstName"], [node objectForKey:@"j:lastName"], nil];
		} else {
			displayName = [node objectForKey:@"j:nodename"];
		}
		cell.textLabel.text = displayName;	
	}
	return cell;
}

- (void) displayElementAtIndex: (NSUInteger )index  {
	
	if (index >= [searchResults count]) {
		NSLog(@"Request an object that doesn't existing, aborting...");
		return;
	}
	
	Configuration *config = [Configuration sharedInstance];
		
	NSDictionary *node = [searchResults objectAtIndex:index];
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/cms/render/%@/en", config.baseURL, [config getWorkspace], nil];
	NSString *fullPath = [node objectForKey:@"path"];
	if (fullPath != nil) {
		[urlString appendString:fullPath];
		[urlString appendString:@".html"];
		
		[detailViewController changeURL:urlString urlTitle:[node objectForKey:@"j:nodename"] element:node];		
	} else {
		NSLog(@"Full path not found, cannot load content !");
	}
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // UIViewController *detailsViewController = [[UIViewController alloc] init];
    
	/*
	 If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
	 */
	NSDictionary *node = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        node = [self.filteredListContent objectAtIndex:indexPath.row];
    } else {
        node = [self.listContent objectAtIndex:indexPath.row];
    }
	
	if (node != nil) {
#ifdef IPHONE_ONLY
		[[self navigationController] pushViewController:detailViewController animated:YES];
#endif
		[self displayElementAtIndex:indexPath.row];
	}
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	
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
	NSString *userQuery = [NSString stringWithFormat:@"SELECT * FROM [jnt:user] AS u WHERE u.[j:nodename] LIKE '%@%%' OR u.[j:firstName] LIKE '%@%%' OR u.[j:lastName] LIKE '%@%%'", searchText, searchText, searchText, nil];
	NSLog(@"Executing query %@...", userQuery);
	[findRequest setPostValue:userQuery forKey:@"query"];
	[findRequest setPostValue:@"JCR-SQL2" forKey:@"language"];	
	[findRequest setPostValue:@"1" forKey:@"depthLimit"];	
	[findRequest startSynchronous];
	error = [findRequest error];
	NSString *findResponse = nil;
	if (!error) {
		findResponse = [findRequest responseString];
	}
	// Create SBJSON object to parse JSON
	SBJSON *parser = [[SBJSON alloc] init];
	
	// parse the JSON string into an object - assuming json_string is a NSString of JSON data
	self.searchResults = [parser objectWithString:findResponse error:nil];
    NSLog(@"JSON parsed objects : %@", [self.searchResults description]);
	
	for (NSDictionary *node in self.searchResults) {
		[self.filteredListContent addObject:node];
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

