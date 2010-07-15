//
//  Configuration.m
//  iPadJahia
//
//  Created by Serge Huber on 25.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "Configuration.h"
#import "FileUtils.h"

static Configuration *sharedInstance = nil;

@implementation Configuration

#pragma mark -
#pragma mark class instance methods

- (id) init {
	self = [super init];
	if (self != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSDictionary *defaultsDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"http://localhost:8080", @"url_preference",
									  @"root", @"username_preference", 
									  @"root1234", @"password_preference", 
									  @"No", @"workspace_preference", 
									  @"en", @"language_preference",
									  nil];
		
		[defaults registerDefaults:defaultsDict];
		
		self.baseURL = [defaults stringForKey:@"url_preference"];
		self.username = [defaults stringForKey:@"username_preference"];
		self.password = [defaults stringForKey:@"password_preference"];
		self.useEDITWorkspace = [defaults boolForKey:@"workspace_preference"];
		self.language = [defaults stringForKey:@"language_preference"];
	}
	return self;
}

-(NSString *)getWorkspace {
	if (useEDITWorkspace) {
		return @"default";
	} else {
		return @"live";
	}
}

-(NSArray *)getAllTabBarConfigs {
	if (self.appConfigDictionary == nil) {
		self.appConfigDictionary = [[FileUtils sharedInstance] retrieveDictionary:@"mobile/appconfig.plist" baseURL:[NSURL URLWithString:[Configuration sharedInstance].baseURL]];
	}
	return [self.appConfigDictionary objectForKey:@"tabBarConfig"];
}

-(NSDictionary *)tabBarConfigWithName:(NSString *)tabBarName {
	for (NSDictionary *currentTabConfig in [self getAllTabBarConfigs]) {
		NSString *currentTabName = [currentTabConfig objectForKey:@"name"];
		if ([currentTabName isEqualToString:tabBarName]) {
			return currentTabConfig;
			break;
		}
	}
	return nil;
}

-(id) objectForKey:(NSString *)key andTabBarConfigName:(NSString *)tabBarName {
	NSDictionary *tabBarConfig = [self tabBarConfigWithName:tabBarName];
	if (tabBarConfig != nil) {
		return [tabBarConfig objectForKey:key];
	}
	return nil;
}

-(NSDictionary *)mappingsForTabBarConfig:(NSString *)tabBarName {
	NSDictionary *mappingsFound = nil;
	NSDictionary *currentTabConfig = [self tabBarConfigWithName:tabBarName];
	if (currentTabConfig != nil) {
		mappingsFound = [currentTabConfig objectForKey:@"mappings"];
	}
	return mappingsFound;
}

#pragma mark -
#pragma mark Singleton methods

+ (Configuration*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[Configuration alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@synthesize baseURL;
@synthesize username;
@synthesize password;
@synthesize appConfigDictionary;
@synthesize useEDITWorkspace;
@synthesize language;
@end
