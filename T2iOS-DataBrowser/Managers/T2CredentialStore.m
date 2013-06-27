//
//  T2CredentialStore.m
//  T2User
//
//  Created by Tim Brooks on 5/31/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "T2CredentialStore.h"
#import "SSKeychain.h"

#define AUTH_TOKEN_KEY @"AUTH_TOKEN"

@implementation T2CredentialStore

- (BOOL)isLoggedIntoService:(NSString*)service
{
    return ([self authTokenForService:service] != nil);
}
- (void)clearSavedCredentialsForService:(NSString*)service
{
    [self setAuthToken:nil forService:service];
}
- (NSString*)authTokenForService:(NSString*)service
{
    return [self secureValueForService:service withKey:AUTH_TOKEN_KEY];
}
- (void)setAuthToken:(NSString*)token forService:(NSString*)service
{
    [self setSecureValue:token forService:service withKey:AUTH_TOKEN_KEY];
}
- (NSString*)secureValueForService:service withKey:(NSString*)key
{
    return [SSKeychain passwordForService:service account:key];
}

- (void)setSecureValue:(NSString*)value forService:(NSString*)service withKey:(NSString*)key
{
    if (value) {
        [SSKeychain setPassword:value forService:service account:key];
    } else {
        [SSKeychain deletePasswordForService:service account:key];
    }
}
+ (T2CredentialStore*)sharedStore
{
    static dispatch_once_t pred;
    static T2CredentialStore* instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
