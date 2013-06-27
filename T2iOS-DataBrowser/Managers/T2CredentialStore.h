//
//  T2CredentialStore.h
//  T2User
//
//  Created by Tim Brooks on 5/31/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T2CredentialStore : NSObject

- (BOOL)isLoggedIntoService:(NSString*)service;
- (void)clearSavedCredentialsForService:(NSString*)service;
- (NSString*)authTokenForService:(NSString*)service;
- (void)setAuthToken:(NSString*)token forService:(NSString*)service;
+ (T2CredentialStore*)sharedStore;

@end
