//
//  PadInputViewController.m
//  JahiaMobile
//
//  Created by Serge Huber on 31.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "PadInputViewController.h"


@implementation PadInputViewController

-(IBAction) addImageAction :(id)sender forEvent:(UIEvent*)event {
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	// imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	//[callingViewController dismissController:self];
	//[self presentModalViewController:imagePicker animated:YES];
	popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
	[popOverController presentPopoverFromRect:imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	//[self dismissModalViewControllerAnimated:YES];
	//[callingViewController presentModalViewController:self animated:YES];
	// [imagePicker removeFromSuperview];
	self.imagePicker = nil;
	UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	[imageView setBackgroundImage:selectedImage forState:UIControlStateNormal];
	[popOverController dismissPopoverAnimated:YES];
	[popOverController release];
}


@end
