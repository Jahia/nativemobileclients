//
//  AbstractAppDelegate.m
//  iPadJahia
//
//  Created by Serge Huber on 22.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "AbstractAppDelegate.h"
#import "FileUtils.h"
#import "Configuration.h"

@implementation AbstractAppDelegate

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.appConfigDictionary = [[FileUtils sharedInstance] retrieveDictionary:@"mobile/appconfig.plist" baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
		/*
		NSMutableString *appConfigURLString = [NSMutableString stringWithFormat:@"http://localhost:8080/mobile/appconfig.plist",nil];
		NSURL *appConfigURL = [NSURL URLWithString:appConfigURLString];
		self.appConfigDictionary = [NSDictionary dictionaryWithContentsOfURL:appConfigURL];
		if (appConfigDictionary != nil) {
			NSString *filePath = [NSString stringWithFormat:@"%@/appconfig.plist", [self applicationDocumentsDirectory], nil];
			[appConfigDictionary writeToFile:filePath atomically:YES];
		} else {
			NSString *appConfigPath = [[NSBundle mainBundle] pathForResource:@"appconfig" ofType:@"plist"];
			self.appConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:appConfigPath];
		}
		 */
		NSURLCache *urlCache = [NSURLCache sharedURLCache];
		[urlCache setDiskCapacity:1000000];
		NSLog(@"currentDiskCapacity=%d totalCapacity=%d currentMemoryCapacity=%d totalCapacity=%d", 
			  [urlCache currentDiskUsage], [urlCache diskCapacity],
			  [urlCache currentMemoryUsage], [urlCache memoryCapacity]);
	}
	return self;
}

-(NSArray *) getTabBarConfig {
	
	return [appConfigDictionary objectForKey:@"tabBarConfig"];
}

@synthesize appConfigDictionary;
@end
