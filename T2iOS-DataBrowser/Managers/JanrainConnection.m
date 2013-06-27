//
//  JanrainConnection.m
//  JanrainTest
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 Tim Brooks. All rights reserved.
//

#import "JanrainConnection.h"
#import "JREngage.h"

static NSMutableArray* sharedConnectionList = nil;

@interface JanrainConnection() <JREngageSigninDelegate, JREngageSharingDelegate>

// Session state
@property (nonatomic, copy) NSDictionary* authInfo;
@property (nonatomic) BOOL loadingUserData;
@property (nonatomic) BOOL pendingCallToTokenUrl;

@end

@implementation JanrainConnection

- (id)initWithAppId:(NSString*)appId andTokenServerUrl:(NSString*)serverUrl
{
    self = [super init];
    if (self) {
        [JREngage setEngageAppId:appId tokenUrl:serverUrl andDelegate:self];
    }
    
    return self;
}
- (void)cancel
{
    [JREngage cancelAuthentication];
    [self completeWithError:[NSError errorWithDomain:@"T2AuthCancelled" code:409 userInfo:nil]];
}
- (void)start
{
    self.loadingUserData = YES;
    if (!sharedConnectionList) {
        sharedConnectionList = [[NSMutableArray alloc] init];
    }
    [sharedConnectionList addObject:self];
    [JREngage showAuthenticationDialog];
}

#pragma mark - Enage Signin Delegate
- (void)authenticationDidSucceedForUser:(NSDictionary *)authInfo forProvider:(NSString *)provider
{
    // Then there was an error
    if(!authInfo) {
        [self completeWithError:[NSError errorWithDomain:@"T2AuthFailure" code:401 userInfo:nil]];
    }
    self.pendingCallToTokenUrl = YES;
    self.authInfo = authInfo;
}
- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider
{
    self.loadingUserData = NO;
    self.pendingCallToTokenUrl = NO;
    if(self.completionBlock) {
        self.completionBlock(self.authInfo, nil);
    }
    [sharedConnectionList removeObject:self];
}
- (void)authenticationDidNotComplete
{
    self.loadingUserData = NO;
}
- (void)authenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    [self completeWithError:error];
}
- (void)authenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    [self completeWithError:error];
}
- (void)completeWithError:(NSError*)error
{
    self.authInfo = nil;
    self.loadingUserData = NO;
    self.pendingCallToTokenUrl = NO;
    if(self.completionBlock) {
        self.completionBlock(nil, error);
    }
    [sharedConnectionList removeObject:self];    
}

@end
