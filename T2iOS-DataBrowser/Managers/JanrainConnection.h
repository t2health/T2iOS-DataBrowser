//
//  JanrainConnection.h
//  JanrainTest
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 Tim Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JanrainConnection : NSObject

@property (nonatomic, copy) void (^completionBlock)(NSDictionary* authInfo, NSError* err);

- (void)cancel;
- (void)start;
- (id)initWithAppId:(NSString*)appId andTokenServerUrl:(NSString*)serverUrl;

@end
