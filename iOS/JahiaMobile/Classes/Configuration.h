//
//  Configuration.h
//  iPadJahia
//
//  Created by Serge Huber on 25.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Configuration : NSObject {
	NSString *baseURL;
	NSString *username;
	NSString *password;
	NSDictionary *appConfigDictionary;
	BOOL useEDITWorkspace;
	NSString *language;
}
+ (Configuration*)sharedInstance;
-(NSArray *)getAllTabBarConfigs;
-(NSDictionary *)tabBarConfigWithName:(NSString *)tabBarName;
-(id) objectForKey:(NSString *)key andTabBarConfigName:(NSString *)tabBarName;
-(NSDictionary *)mappingsForTabBarConfig:(NSString *)tabBarName;
-(NSString *)getWorkspace;

@property (retain) NSString *baseURL;
@property (retain) NSString *username;
@property (retain) NSString *password;
@property (retain) NSDictionary *appConfigDictionary;
@property (retain) NSString *language;
@property BOOL useEDITWorkspace;
@end
