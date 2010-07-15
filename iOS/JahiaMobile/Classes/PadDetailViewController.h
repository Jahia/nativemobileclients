//
//  DetailViewController.h
//  iPadJahia
//
//  Created by Serge Huber on 28.01.10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CommonDetailViewController.h"

@interface PadDetailViewController : CommonDetailViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    UINavigationBar *navigationBar;
    
    UIPopoverController *popoverController;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@end
