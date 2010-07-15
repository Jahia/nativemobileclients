//
//  AbstractAppDelegate.h
//  iPadJahia
//
//  Created by Serge Huber on 22.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AbstractAppDelegate : NSObject {

	NSDictionary *appConfigDictionary;
}

- (NSString *)applicationDocumentsDirectory;
-(NSArray *) getTabBarConfig;

@property (retain) NSDictionary *appConfigDictionary;
@end
