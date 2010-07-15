//
//  FileUtils.h
//  iPadJahia
//
//  Created by Serge Huber on 24.03.10.
//  Copyright 2010 Jahia Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileUtils : NSObject {
}
+ (FileUtils*)sharedInstance;

- (NSDictionary *) retrieveDictionary:(NSString *)filePath baseURL:(NSURL*)baseURL;
- (NSString *) retrieveString:(NSString *)filePath baseURL:(NSURL*)baseURL;
- (NSData *) retrieveData:(NSString *)filePath baseURL:(NSURL*)baseURL;
- (UIImage *) retrieveUIImage:(NSString *)filePath baseURL:(NSURL*)baseURL;
@end
