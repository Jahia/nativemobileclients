//
//  PhoneDetailViewController.h
//  iPadJahia
//
//  Created by Serge Huber on 11.02.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MasterViewController;
@class InputViewController;

@interface CommonDetailViewController : UIViewController<UIWebViewDelegate> {
    NSString *controllerTitle;
    NSManagedObject *detailItem;
	IBOutlet UIWebView *detailWebView;
	InputViewController *inputViewController;
	NSMutableDictionary *detailDictionary;
	MasterViewController *masterViewController;
}


- (IBAction)insertNewObject:sender;
- (void)changeURL:(NSString *) url urlTitle:(NSString *)title element:(NSDictionary *)detailElement;
- (void)dismissController:(UIViewController *)viewController;

@property (nonatomic, retain) NSManagedObject *detailItem;
@property (retain) UIWebView *detailWebView;
@property (retain) InputViewController *inputViewController;
@property (retain) NSMutableDictionary *detailDictionary;
@property (retain) NSString *controllerTitle;
@property (retain) MasterViewController *masterViewController;
@end
