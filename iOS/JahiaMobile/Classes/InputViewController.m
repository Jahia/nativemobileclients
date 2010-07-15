//
//  NewsInputViewController.m
//  iPadJahia
//
//  Created by Serge Huber on 12.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "InputViewController.h"
#import "CommonDetailViewController.h"
#import "ASIFormDataRequest.h"
#import "MasterViewController.h"
#import "Configuration.h"
#import "JSON.h"

@implementation InputViewController

@synthesize callingViewController;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"New";
	[self.navigationItem setRightBarButtonItem:
	 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:forEvent:)]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([titleField isFirstResponder]) {
		[titleField resignFirstResponder];
	} else if ([bodyTextView isFirstResponder]) {
		[bodyTextView resignFirstResponder];
	}
	
	NSLog(@"Touch ended");
}

-(IBAction) saveAction :(id)sender forEvent:(UIEvent*)event {
	
	NSString *submitPath = [[Configuration sharedInstance] objectForKey:@"submitPath" andTabBarConfigName:self.controllerTitle];
	NSDictionary *mappings = [[Configuration sharedInstance] mappingsForTabBarConfig:self.controllerTitle];
	
	// first we must submit the new file
	NSString *newsSubmitURL = [NSString stringWithFormat:@"%@%@", [Configuration sharedInstance].baseURL, submitPath];
	NSString *imageUUID = nil;
	UIImage *selectedImage = [imageView backgroundImageForState:UIControlStateNormal];
	if (selectedImage != nil) {
		ASIFormDataRequest *fileFormRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:newsSubmitURL]];
		[fileFormRequest addRequestHeader:@"accept" value:@"application/json"];
		[fileFormRequest addRequestHeader:@"x-requested-with" value:@"XMLHttpRequest"];
		UIImage *selectedImage = [imageView backgroundImageForState:UIControlStateNormal];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
		NSString *fileName = [NSString stringWithFormat:@"image-%@.png", [dateFormatter stringFromDate:[NSDate date]], nil];
		[dateFormatter release];
		[fileFormRequest setData:UIImagePNGRepresentation(selectedImage) withFileName:fileName andContentType:@"image/png" forKey:[mappings objectForKey:@"image"]];
		[fileFormRequest startSynchronous];
		NSError *error = [fileFormRequest error];
		if (!error) {
			NSString *response = [fileFormRequest responseString];
			NSLog(@"Response=%@", response);
			// Create SBJSON object to parse JSON
			SBJSON *parser = [[SBJSON alloc] init];
			
			// parse the JSON string into an object - assuming json_string is a NSString of JSON data
			NSDictionary *responseDictionary = [parser objectWithString:response error:&error];
			NSArray *uuids = [responseDictionary objectForKey:@"uuids"];
			if ((uuids != nil) && ([uuids count] > 0)) {
				imageUUID = [[uuids objectAtIndex:0] retain];
			}
			[parser release];
		} else {
			NSLog(@"Error creating new content : %@", error);
		}
		[fileFormRequest release];
	}
	
	ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:newsSubmitURL]];
	[formRequest addRequestHeader:@"accept" value:@"application/json"];
	[formRequest addRequestHeader:@"x-requested-with" value:@"XMLHttpRequest"];
	[formRequest setPostValue:@"jnt:news" forKey:@"nodeType"];
	NSString *nodeName = [titleField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	[formRequest setPostValue:nodeName forKey:@"nodeName"];
	// [formRequest setPostValue:@"json" forKey:@"newNodeOutputFormat"];
	[formRequest setPostValue:titleField.text forKey:[mappings objectForKey:@"title"]];
	[formRequest setPostValue:bodyTextView.text forKey:[mappings objectForKey:@"subtitle"]];
	if (imageUUID != nil) {
		[formRequest setPostValue:imageUUID forKey:[mappings objectForKey:@"image"]];
	}
	[formRequest startSynchronous];
	NSError *error = [formRequest error];
	if (!error) {
		NSString *response = [formRequest responseString];
		NSLog(@"Response=%@", response);
	} else {
		NSLog(@"Error creating new content : %@", error);
	}
	[formRequest release];
	[imageUUID release];
	[masterViewController loadListData];
	[callingViewController dismissController:self];
}

-(IBAction) cancelAction :(id)sender forEvent:(UIEvent*)event {
	[callingViewController dismissController:self];
}

-(IBAction) addImageAction :(id)sender forEvent:(UIEvent*)event {
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	// imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	//[callingViewController dismissController:self];
	[self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:YES];
	//[callingViewController presentModalViewController:self animated:YES];
	// [imagePicker removeFromSuperview];
	self.imagePicker = nil;
	UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[imageView setBackgroundImage:selectedImage forState:UIControlStateNormal];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)dealloc {
    [super dealloc];
}


@synthesize imageView;
@synthesize addImageButton;
@synthesize titleField;
@synthesize bodyTextView;
@synthesize imagePicker;
@synthesize controllerTitle;
@synthesize masterViewController;
@end
