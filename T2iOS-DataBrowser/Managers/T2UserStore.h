//
//  T2UserStore.h
//  T2UserStore
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "T2UserInfo.h"

@interface T2UserStore : NSObject

// Dictionary containing the user identifier, display name, current
// provider, and session timestamp
@property (nonatomic, copy) NSDictionary* currentUser;

// User selected profile
@property (nonatomic, readonly) BOOL currentUserIsAuthorized;

// Initiate user sign in/out
- (T2UserInfo*)signedInUserInfo;
- (void)signInUserWithCompletion:(void(^)(T2UserInfo* userInfo, NSError* err))block;
- (void)signOutUser;
- (void)triggerAuthenticationDidCancel:(id)sender;

// Class messages
+ (NSString*)addressFromProfile:(NSDictionary*)profile;
+ (NSString*)displayNameFromProfile:(NSDictionary*)profile;
+ (T2UserStore*)sharedStore;

@end
