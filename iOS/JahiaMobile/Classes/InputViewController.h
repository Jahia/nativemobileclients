//
//  NewsInputViewController.h
//  iPadJahia
//
//  Created by Serge Huber on 12.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommonDetailViewController;
@class MasterViewController;

@interface InputViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	UIViewController *callingViewController;
	MasterViewController *masterViewController;
	
	NSString *controllerTitle;
	IBOutlet UIButton *imageView;
	IBOutlet UIButton *addImageButton;
	IBOutlet UITextField *titleField;
	IBOutlet UITextView *bodyTextView;
	UIImagePickerController *imagePicker;
	
}

-(IBAction) saveAction :(id)sender forEvent:(UIEvent*)event;
-(IBAction) cancelAction :(id)sender forEvent:(UIEvent*)event;
-(IBAction) addImageAction :(id)sender forEvent:(UIEvent*)event;


@property (nonatomic, retain) UIButton *imageView;
@property (nonatomic, retain) UIButton *addImageButton;
@property (retain) UITextField *titleField;
@property (retain) UITextView *bodyTextView;
@property (retain) UIImagePickerController *imagePicker;
@property (retain) NSString *controllerTitle;
@property (retain) UIViewController *callingViewController;
@property (retain) MasterViewController *masterViewController;
@end
