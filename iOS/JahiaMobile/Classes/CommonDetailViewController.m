//
//  PhoneDetailViewController.m
//  iPadJahia
//
//  Created by Serge Huber on 11.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "CommonDetailViewController.h"
#import "MasterViewController.h"
#import "InputViewController.h"
#import "FileUtils.h"
#import "TFHpple.h"
#import "Configuration.h"

#define kMarkerStart @"$$$"
#define kMarkerEnd @"$$$"

@implementation CommonDetailViewController
@synthesize detailItem;


#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewObject:sender {
	inputViewController = [[InputViewController alloc] initWithNibName:@"InputViewController" bundle:nil];
	inputViewController.callingViewController = self;
	inputViewController.masterViewController = self.masterViewController;
	inputViewController.controllerTitle = self.controllerTitle;
	
	[self.navigationController pushViewController:inputViewController animated:YES];
}

- (void)dismissController:(UIViewController *)viewController {
	[self.navigationController popViewControllerAnimated:YES];
	self.inputViewController = nil;
}

#pragma mark -
#pragma mark Managing the popover controller

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(NSManagedObject *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
				
        // Update the view.
        self.navigationItem.title = [[detailItem valueForKey:@"timeStamp"] description];
	}
    
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
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
			while (object = [e nextObject]) {
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


- (NSString *)fillTemplate:(NSString *)template withData:(NSDictionary *)data {
	NSString *result = [NSString stringWithString:template]; 
	NSRange firstMarkerPos = [result rangeOfString:kMarkerStart options:0 range:NSMakeRange(0, [result length])];
	while (firstMarkerPos.location != NSNotFound) {
	    NSRange endMarkerPos = [result rangeOfString:kMarkerEnd options:0 range:NSMakeRange(firstMarkerPos.location + [kMarkerStart length], [result length] - (firstMarkerPos.location + [kMarkerStart length]))];
		if (endMarkerPos.location != NSNotFound) {
			NSString *varName = [result substringWithRange:NSMakeRange(firstMarkerPos.location + [kMarkerStart length], endMarkerPos.location - firstMarkerPos.location - [kMarkerStart length])];
			NSString *completeMarker = [result substringWithRange:NSMakeRange(firstMarkerPos.location, endMarkerPos.location - firstMarkerPos.location + [kMarkerEnd length])];
			//NSString *dataValue = [data objectForKey:varName];
			NSString *dataValue = [self findObjectInNodeOrSubNodes:data forKey:varName];
			dataValue = [dataValue stringByReplacingOccurrencesOfString:@"<BODY>" withString:@""];
			if (dataValue != nil) {
				// result = [result stringByReplacingOccurrencesOfString:completeMarker withString:[data objectForKey:varName]];
				result = [result stringByReplacingOccurrencesOfString:completeMarker withString:[self findObjectInNodeOrSubNodes:data forKey:varName]];
			} else {
				result = [result stringByReplacingOccurrencesOfString:completeMarker withString:@""];
			}
		}
		firstMarkerPos = [result rangeOfString:kMarkerStart options:0 range:NSMakeRange(0, [result length])];
	}
	NSLog(@"Template filling completed.");
	return result;
}

- (void)loadContentIntoWebView:(NSMutableDictionary *)detailElement {
	NSString *escapedPrimaryTypeName = [[detailElement objectForKey:@"jcr:primaryType"] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
	NSString *baseFilePath = [NSString stringWithFormat:@"mobile/templates/%@/ipad/", escapedPrimaryTypeName, nil];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@.html", baseFilePath, escapedPrimaryTypeName, nil];
	NSLog(@"Using template file=%@", filePath);
	int deviceWidth = (int) self.view.frame.size.width;
	[detailElement setObject:[[NSNumber numberWithInt:deviceWidth] stringValue] forKey:@"deviceScreenWidth"];
	
	// now let's 
	NSString *htmlTemplate = [[FileUtils sharedInstance] retrieveString:filePath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	if (htmlTemplate == nil) {
		// let's fallback to nt:base template.
		baseFilePath = [NSString stringWithFormat:@"mobile/templates/%@/ipad/", @"nt_base", nil];
		filePath = [NSString stringWithFormat:@"%@/%@.html", baseFilePath, @"nt_base", nil];
		htmlTemplate = [[FileUtils sharedInstance] retrieveString:filePath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	}
	NSString *filledTemplate = [self fillTemplate:htmlTemplate withData:detailElement];
	
	// detailWebView.scalesPageToFit = YES;
	NSString *baseURLString = [NSString stringWithFormat:@"%@/%@",[Configuration sharedInstance].baseURL, baseFilePath, nil]; 
	[detailWebView loadHTMLString:filledTemplate baseURL:[NSURL URLWithString:baseURLString]];
	
	NSData  * data      = [[FileUtils sharedInstance] retrieveData:filePath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	
	TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
	NSArray * linkElements  = [doc search:@"//link"];	
	for (TFHppleElement *element in linkElements) {
		NSString *innerHTML = [element content];              // Tag's innerHTML
		NSString *tagName = [element tagName];              // "a"
		NSDictionary *attributes = [element attributes];           // NSDictionary of href, class, id, etc.
		NSString *href = [element objectForKey:@"href"]; // Easy access to single attribute	
		NSLog(@"%@ innerHTML=%@ href=%@", tagName, innerHTML, href);
		NSString *resolvedHRefPath = [NSString stringWithFormat:@"mobile/templates/%@/ipad/%@", escapedPrimaryTypeName, href];
		NSData  *data = [[FileUtils sharedInstance] retrieveData:resolvedHRefPath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	}
	NSArray * scriptElements  = [doc search:@"//script"];	
	for (TFHppleElement *element in scriptElements) {
		NSString *innerHTML = [element content];              // Tag's innerHTML
		NSString *tagName = [element tagName];              // "a"
		NSDictionary *attributes = [element attributes];           // NSDictionary of href, class, id, etc.
		NSString *src = [element objectForKey:@"src"]; // Easy access to single attribute	
		NSLog(@"%@ innerHTML=%@ src=%@", tagName, innerHTML, src);
		NSString *resolvedSrcPath = [NSString stringWithFormat:@"mobile/templates/%@/ipad/%@", escapedPrimaryTypeName, src];
		NSData  *data = [[FileUtils sharedInstance] retrieveData:resolvedSrcPath baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	}
}

- (void)changeURL:(NSString *) url urlTitle:(NSString *)title element:(NSMutableDictionary *)detailElement {
	self.detailDictionary = detailElement;
	[self loadContentIntoWebView:self.detailDictionary];
    self.navigationItem.title = title;
		
	/*
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	detailWebView.scalesPageToFit = YES;
	[detailWebView loadRequest:urlRequest];	
	navigationBar.topItem.title = title;
	 */
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	detailWebView.delegate = self;
	[self.navigationItem setRightBarButtonItem:
	 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)]];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"shouldStartLoadWithRequest %@", request);
	return YES;
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
		
	[detailItem release];
	
	[super dealloc];
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self loadContentIntoWebView:self.detailDictionary];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
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

@synthesize detailWebView;
@synthesize inputViewController;
@synthesize detailDictionary;
@synthesize controllerTitle;
@synthesize masterViewController;
@end

