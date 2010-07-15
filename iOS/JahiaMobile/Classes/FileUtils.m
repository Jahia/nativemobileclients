//
//  FileUtils.m
//  iPadJahia
//
//  Created by Serge Huber on 24.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import "FileUtils.h"

static FileUtils *sharedInstance = nil;

@implementation FileUtils

#pragma mark -
#pragma mark class instance methods

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSDictionary *) retrieveDictionary:(NSString *)filePath baseURL:(NSURL*)baseURL {
	NSDictionary *result = nil;
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@",baseURL, filePath, nil];
	NSURL *dictionaryURL = [NSURL URLWithString:urlString];
	result = [NSDictionary dictionaryWithContentsOfURL:dictionaryURL];
	if (result != nil) {
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		NSError *error;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[localFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Error while creating directory at path %@ : %@", [localFilePath stringByDeletingLastPathComponent], error);
		}
		if (![result writeToFile:localFilePath atomically:YES]) {
			NSLog(@"Error writing file %@ to disk : %@", localFilePath, error);
		}
		
	} else {
		// let's see if we can load the file from a previously saved file.
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		result = [NSDictionary dictionaryWithContentsOfFile:localFilePath];
		if (result != nil) {
			return result;
		}
		
		// let's see if we have a resource in the app bundle that matches.
		NSString *resourcePath = [[filePath lastPathComponent] stringByDeletingPathExtension];
		NSString *directory = [filePath stringByDeletingLastPathComponent];
		NSString *appConfigPath = [[NSBundle mainBundle] pathForResource:resourcePath ofType:[filePath pathExtension] inDirectory:directory];
		result = [NSDictionary dictionaryWithContentsOfFile:appConfigPath];
	}
	return result;
}

- (NSString *) retrieveString:(NSString *)filePath baseURL:(NSURL*)baseURL {
	NSString *result = nil;
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@",baseURL, filePath, nil];
	NSError *error;
	NSURL *dictionaryURL = [NSURL URLWithString:urlString];
	result = [NSString stringWithContentsOfURL:dictionaryURL encoding:NSUTF8StringEncoding error:&error];
	if (result != nil) {
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[localFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Error while creating directory at path %@ : %@", [localFilePath stringByDeletingLastPathComponent], error);
		}
		if (![result writeToFile:localFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
			NSLog(@"Error writing file %@ to disk : %@", localFilePath, error);
		}
	} else {
		// let's see if we can load the file from a previously saved file.
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		result = [NSString stringWithContentsOfFile:localFilePath encoding:NSUTF8StringEncoding error:&error];
		if (result != nil) {
			return result;
		}
		
		// let's see if we have a resource in the app bundle that matches.
		NSString *resourcePath = [[filePath lastPathComponent] stringByDeletingPathExtension];
		NSString *directory = [filePath stringByDeletingLastPathComponent];
		NSString *appConfigPath = [[NSBundle mainBundle] pathForResource:resourcePath ofType:[filePath pathExtension] inDirectory:directory];
		result = [NSString stringWithContentsOfFile:appConfigPath encoding:NSUTF8StringEncoding error:&error];
	}
	return result;
}

- (NSData *) retrieveData:(NSString *)filePath baseURL:(NSURL*)baseURL {
	NSData *result = nil;
	NSString *rootSlash = @"/";
	if ([filePath hasPrefix:@"/"]) {
		rootSlash = @"";
	}
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@",baseURL, rootSlash, filePath, nil];
	NSURL *dictionaryURL = [NSURL URLWithString:urlString];
	result = [NSData dataWithContentsOfURL:dictionaryURL];
	if (result != nil) {
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		NSError *error;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[localFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Error while creating directory at path %@ : %@", [localFilePath stringByDeletingLastPathComponent], error);
		}
		
		if (![result writeToFile:localFilePath options:NSAtomicWrite error:&error]) {
			NSLog(@"Error writing file %@ to disk : %@", localFilePath, error);
		}
	} else {
		// let's see if we can load the file from a previously saved file.
		NSString *localFilePath = [NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], filePath, nil];
		result = [NSData dataWithContentsOfFile:localFilePath];
		if (result != nil) {
			return result;
		}
		
		// let's see if we have a resource in the app bundle that matches.
		NSString *resourcePath = [[filePath lastPathComponent] stringByDeletingPathExtension];
		NSString *directory = [filePath stringByDeletingLastPathComponent];
		NSString *appConfigPath = [[NSBundle mainBundle] pathForResource:resourcePath ofType:[filePath pathExtension] inDirectory:directory];
		result = [NSData dataWithContentsOfFile:appConfigPath];
	}
	return result;
}


- (UIImage *) retrieveUIImage:(NSString *)filePath baseURL:(NSURL*)baseURL {
	UIImage *result = nil;
	NSData *data = [self retrieveData:filePath baseURL:baseURL];
	if (data != nil) {
		result = [UIImage imageWithData:data];
	}
	return result;
}


#pragma mark -
#pragma mark Singleton methods

+ (FileUtils*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[FileUtils alloc] init];
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

@end
