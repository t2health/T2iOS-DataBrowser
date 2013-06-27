//
//  T2UserStore.m
//  T2UserStore
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "T2UserStore.h"
#import "JanrainConnection.h"
#import "T2CredentialStore.h"

#define AUTH_SERVICE @"JANRAIN_AUTH_SERVICE"

@interface T2UserStore ()

// Singleton instance of the NSUserDefaults class
@property (nonatomic, strong)  NSUserDefaults* prefs;

// Auth info
@property (nonatomic, readonly) NSHTTPCookie *authCookie;
@property (nonatomic, readonly) NSString* authToken;
@property (nonatomic, readonly) NSDate* authExpiresDate;

// Account info
@property (nonatomic) BOOL isSignedIn;
@property (nonatomic, copy) NSString* appId;
@property (nonatomic, copy) NSString* cookieTokenKeyPrefix;
@property (nonatomic, copy) NSString* apiKey;
@property (nonatomic, copy) NSString* serviceUrl;
@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* tokenServerUrl;

@end

@implementation T2UserStore

- (id)init
{
    self = [super init];
    if(self) {
        self.prefs = [NSUserDefaults standardUserDefaults];
        [self initTokens];
    }
    
    return self;
}
- (void)initTokens
{
    self.cookieTokenKeyPrefix = @"SSESS";
    self.appId = @"khekfggiembncbadmddh";
    self.apiKey = @"5fcd73f9f136d3e8939adfedbdb20c53e123b40e";
    self.serviceUrl = @"https://t2health-dev.rpxnow.com/";
    self.tokenServerUrl = @"https://t2health.us/h2/rpx/token_handler?destination=node";
}
- (void)signInUserWithCompletion:(void(^)(T2UserInfo* userInfo, NSError* err))block
{
    JanrainConnection* auth = [[JanrainConnection alloc] initWithAppId:self.appId andTokenServerUrl:self.tokenServerUrl];
    auth.completionBlock = ^(NSDictionary* authInfo, NSError* err) {
        T2UserInfo* userInfo = [self completeUserSignIn:authInfo];
        userInfo.tokenExpirationDate = self.authExpiresDate;
        block(userInfo, err);
    };
    [auth start];
}
- (void)signOutUser
{
    [self completeUserSignOut];
}
- (T2UserInfo*)signedInUserInfo
{
    T2UserInfo* info = nil;
    if ([self currentUserIsAuthorized]) {
        info = [self userInfoFromCache];
        info.tokenExpirationDate = self.authExpiresDate;
    }
    
    return info;
}
- (T2UserInfo*)userInfoFromDictionary:(NSDictionary*)user
{
    T2UserInfo* info = [[T2UserInfo alloc] init];
    if (info) {
        // Get the identifier and normalize it (remove html escapes)
        info.identifier = [[[user objectForKey:@"profile"] objectForKey:@"identifier"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        info.provider = [[[user objectForKey:@"profile"] objectForKey:@"providerSpecifier"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        
        // Get the display name
        info.displayName = [T2UserStore displayNameFromProfile:[user objectForKey:@"profile"]];
    }

    return info;
}
- (T2UserInfo*)userInfoFromCache
{
    T2UserInfo* info = nil;
    NSDictionary* user = self.currentUser;
    if (user) {
        info = [[T2UserInfo alloc] init];
        // Get the identifier and normalize it (remove html escapes)
        info.identifier = [user objectForKey:@"identifier"];
        info.provider = [user objectForKey:@"provider"];
        info.displayName = [user objectForKey:@"displayName"];
    }
    
    return info;
}

- (NSDictionary*) currentUser
{
    return [self.prefs objectForKey:@"currentUser"];
}
- (void)setCurrentUser:(NSDictionary *)currentUser
{
    if (currentUser) {    
        [self.prefs setObject:currentUser forKey:@"currentUser"];
    } else {
        [self.prefs removeObjectForKey:@"currentUser"];
    }
}
- (NSHTTPCookie*)authCookie
{
    NSHTTPCookie* resultCookie = nil;
    
    if (self.currentUser) {
        // Then check the cookies to make sure the saved user's identifier matches any cookie returned from
        // the token URL, or if their session has expired
        NSHTTPCookieStorage* cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* cookies = [cookieStore cookiesForURL:[NSURL URLWithString:self.tokenServerUrl]];
        
        for (NSHTTPCookie *cookie in cookies) {
            NSString* cookieName = [cookie.name lowercaseString];
            if ([cookieName hasPrefix:[self.cookieTokenKeyPrefix lowercaseString]]) {
                resultCookie = cookie;
                break;
            }
        }
    }
    
    return resultCookie;
}
- (NSString*)authToken
{
    // check keychain
    NSString* value = [[T2CredentialStore sharedStore] authTokenForService:AUTH_SERVICE];

    if (!value) {
        NSHTTPCookie* cookie = self.authCookie;
        if(cookie) {
            value = [[NSString stringWithString:cookie.value] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            [[T2CredentialStore sharedStore] setAuthToken:value forService:AUTH_SERVICE];
        }
    }
    
    return value;
}
- (NSDate*)authExpiresDate
{
    NSDate* date = [NSDate date];
    NSHTTPCookie* cookie = self.authCookie;
    if(cookie) {
        date = cookie.expiresDate;
    }
    
    return date;
}
- (BOOL)currentUserIsAuthorized
{
    if (!self.currentUser)
        return NO;
    
    if (!self.authToken || ([self.authExpiresDate compare:[NSDate date]] == NSOrderedAscending ))
    {
        [self completeUserSignOut];
        return NO;
    }
       
    return YES;
}
- (T2UserInfo*)completeUserSignIn:(NSDictionary*)user
{
    if (self.currentUser) {
        [self completeUserSignOut];
    }
   
    T2UserInfo* userInfo = [self userInfoFromDictionary:user];
        
    // Store the current user's profile dictionary in the dictionary of users,
    // using the identifier as the key, and then save the dictionary of users
    NSDictionary* tmpProfiles = [self.prefs objectForKey:@"userProfiles"];
    
    // If this profile doesn't already exist in the dictionary of saved profiles
    if (![tmpProfiles objectForKey:userInfo.identifier]) {
        // Create a mutable dictionary from the non-mutable NSUserDefaults dictionary
        NSMutableDictionary* newProfiles = [NSMutableDictionary dictionaryWithDictionary:tmpProfiles];
        
        // add the user's profile to the dictionary, indexed by the identifier
        [newProfiles setObject:user forKey:userInfo.identifier];
        
        // and save
        [self.prefs setObject:newProfiles forKey:@"userProfiles"];
    }
    
    // Get the approximate timestamp of the user's log in
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    self.currentUser = @{
                         @"identifier": userInfo.identifier,
                         @"provider": userInfo.provider,
                         @"displayName": userInfo.displayName,
                         @"timestamp": currentTime
                         };
    
    return userInfo;
}
- (void)completeUserSignOut
{
    // remove auth cookie
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.authCookie];
    [[T2CredentialStore sharedStore] clearSavedCredentialsForService:AUTH_SERVICE];
    [self.prefs removeObjectForKey:@"currentUser"];    
}

// Returns the sign-in history as an ordered array of session dictionaries
// Each dictionary contains the identifier, display name, provider, and timestamp
- (NSArray*)signinHistory
{
    return [self.prefs objectForKey:@"signinHistory"];
}

// Returns a dictionary of dictionaries, where each dictionary contains the profile
// data of previously logged in users.  One dictionary is saved per identifier.
- (NSDictionary*)userProfiles
{
    return [self.prefs objectForKey:@"userProfiles"];
}
- (void)triggerAuthenticationDidCancel:(id)sender
{
}
+ (NSString*)displayNameFromProfile:(NSDictionary*)profile
{
    NSString *name = nil;
    
    if ([profile objectForKey:@"preferredUsername"]) {
        name = [NSString stringWithFormat:@"%@", [profile objectForKey:@"preferredUsername"]];
    }
    else if ([[profile objectForKey:@"name"] objectForKey:@"formatted"]) {
        name = [NSString stringWithFormat:@"%@",
                [[profile objectForKey:@"name"] objectForKey:@"formatted"]];
    }
    else
        name = [NSString stringWithFormat:@"%@%@%@%@%@",
                ([[profile objectForKey:@"name"] objectForKey:@"honorificPrefix"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"honorificPrefix"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"givenName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"givenName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"middleName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"middleName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"familyName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"familyName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"honorificSuffix"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"honorificSuffix"]] : @""];
    
    return name;
}
+ (NSString*)addressFromProfile:(NSDictionary*)profile
{
    NSString *addr = nil;
    
    if ([[profile objectForKey:@"address"] objectForKey:@"formatted"])
        addr = [NSString stringWithFormat:@"%@", [[profile objectForKey:@"address"] objectForKey:@"formatted"]];
    else
        addr = [NSString stringWithFormat:@"%@%@%@%@%@",
                ([[profile objectForKey:@"address"] objectForKey:@"streetAddress"]) ?
                [NSString stringWithFormat:@"%@, ",
                 [[profile objectForKey:@"address"] objectForKey:@"streetAddress"]] : @"",
                ([[profile objectForKey:@"address"] objectForKey:@"locality"]) ?
                [NSString stringWithFormat:@"%@, ",
                 [[profile objectForKey:@"address"] objectForKey:@"locality"]] : @"",
                ([[profile objectForKey:@"address"] objectForKey:@"region"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"address"] objectForKey:@"region"]] : @"",
                ([[profile objectForKey:@"address"] objectForKey:@"postalCode"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"address"] objectForKey:@"postalCode"]] : @"",
                ([[profile objectForKey:@"address"] objectForKey:@"country"]) ?
                [NSString stringWithFormat:@"%@",
                 [[profile objectForKey:@"address"] objectForKey:@"country"]] : @""];
    
    return addr;
}
+ (T2UserStore*)sharedStore
{
    static dispatch_once_t pred;
    static T2UserStore* instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
