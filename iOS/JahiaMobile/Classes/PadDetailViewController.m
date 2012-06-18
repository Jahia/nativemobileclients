//
//  DetailViewController.m
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Jahia Solutions Inc 2010-2011. All Rights Reserved.
//

#import "PadDetailViewController.h"
#import "MasterViewController.h"
#import "PadInputViewController.h"

@implementation PadDetailViewController

@synthesize popoverController;
@synthesize navigationBar;

#pragma mark -
#pragma mark Managing the popover controller

- (IBAction)insertNewObject:sender {
	inputViewController = [[PadInputViewController alloc] initWithNibName:@"PadInputViewController" bundle:nil];
	inputViewController.callingViewController = self;
	inputViewController.masterViewController = self.masterViewController;
	inputViewController.controllerTitle = self.controllerTitle;

	[self presentModalViewController:inputViewController animated:YES];
}

- (void)dismissController:(UIViewController *)viewController {
	[self dismissModalViewControllerAnimated:YES];
	self.inputViewController = nil;
}


/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(NSManagedObject *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
		
		//NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jahia.org"]];
		//[detailWebView loadRequest:urlRequest];
		
        // Update the view.
        navigationBar.topItem.title = [[detailItem valueForKey:@"timeStamp"] description];
	}
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }		
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = self.controllerTitle;
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
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
	self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	
    [popoverController release];
    [navigationBar release];
	
	[detailItem release];
	
	[super dealloc];
}	


@end
