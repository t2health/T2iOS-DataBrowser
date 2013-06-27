/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 File:   JRSessionData.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>

#ifdef CORDOVA_FRAMEWORK
#import <Cordova/JSONKit.h>
#else
#ifdef PHONEGAP_FRAMEWORK
#import <PhoneGap/JSONKit.h>
#else
#import "JSONKit.h"
#endif
#endif

#import "SFHFKeychainUtils.h"
#import "JRConnectionManager.h"
#import "JRActivityObject.h"

@protocol JRUserInterfaceDelegate <NSObject>
- (void)userInterfaceWillClose;
- (void)userInterfaceDidClose;
@end

@interface JRAuthenticatedUser : NSObject <NSCoding>
{
    NSString *_photo;
    NSString *_displayName;
    NSString *_preferredUsername;
    NSString *_deviceToken;
    NSString *_providerName;
    NSString *_welcomeString;
}
@property (readonly) NSString *photo;
@property (readonly) NSString *displayName;
@property (readonly) NSString *preferredUsername;
@property (readonly) NSString *deviceToken;
@property (readonly) NSString *providerName;
@property (copy)     NSString *welcomeString;
@end

@interface JRProvider : NSObject <NSCoding>
{
    NSString *_name;

    NSString *_friendlyName;
    NSString *_placeholderText;
    NSString *_shortText;
    BOOL      _requiresInput;

    NSString *_openIdIdentifier; // already URL encoded
    NSString *_relativeUrl;
    BOOL      _forceReauth;

    NSString *_userInput;

    NSDictionary *_socialSharingProperties;
    BOOL          _social;

    NSArray *_cookieDomains;
}

@property (readonly) NSString     *name;
@property (readonly) NSString     *friendlyName;
@property (readonly) NSString     *shortText;
@property (readonly) NSString     *placeholderText;
@property (readonly) BOOL          requiresInput;
@property            BOOL          forceReauth;
@property (retain)   NSString     *userInput;
@property (readonly) NSDictionary *socialSharingProperties;
@property (readonly) NSArray      *cookieDomains;
@property(nonatomic, retain) NSString *customUserAgentString;
@property(nonatomic) BOOL usesPhoneUserAgentString;
@property(nonatomic, retain) NSString *samlName;

@property(nonatomic, retain) NSString *opxBlob; // already URL encoded

- (BOOL)isEqualToReturningProvider:(NSString*)returningProvider;
@end

@protocol JRSessionDelegate <NSObject>
@optional
- (void)authenticationDidRestart;
- (void)authenticationDidCancel;

- (void)authenticationDidCompleteForUser:(NSDictionary*)profile forProvider:(NSString*)provider;
- (void)authenticationDidFailWithError:(NSError*)error forProvider:(NSString*)provider;

- (void)authenticationDidReachTokenUrl:(NSString*)tokenUrl withResponse:(NSURLResponse*)response
                            andPayload:(NSData*)tokenUrlPayload forProvider:(NSString*)provider;
- (void)authenticationCallToTokenUrl:(NSString*)tokenUrl didFailWithError:(NSError*)error
                         forProvider:(NSString*)provider;

//- (void)publishingDidRestart;
- (void)publishingDidCancel;
- (void)publishingDidComplete;

- (void)publishingActivityDidSucceed:(JRActivityObject*)activity forProvider:(NSString*)provider;
- (void)publishingActivity:(JRActivityObject*)activity didFailWithError:(NSError*)error forProvider:(NSString*)provider;

- (void)urlShortenedToNewUrl:(NSString*)url forActivity:(JRActivityObject*)activity;
@end

@class JRActivityObject;

@interface JRSessionData : NSObject <JRConnectionManagerDelegate>
@property (retain)   JRProvider *currentProvider;
@property (readonly) NSString   *returningAuthenticationProvider;
@property (readonly) NSString   *returningSharingProvider;

/** engageProviders is a dictionary of JRProviders, where each JRProvider contains the information specific to that
    provider. authenticationProviders and sharingProviders are arrays of NSStrings, each string being the primary key
    in engageProviders for that provider, representing the list of providers to be used in authentication and social
    publishing. The arrays are in the order configured by the RP on http://rpxnow.com. */
@property (readonly, retain) NSMutableDictionary *engageProviders;
@property (readonly, retain) NSArray             *authenticationProviders;
@property (readonly, retain) NSArray             *sharingProviders;

@property (copy)     JRActivityObject *activity;

@property (copy)     NSString *tokenUrl;
@property (readonly) NSString *baseUrl;

@property (readonly) BOOL hidePoweredBy;
@property            BOOL alwaysForceReauth;
//@property            BOOL forceReauthJustThisTime;
//@property            BOOL authenticatingDirectlyOnThisProvider;
@property            BOOL socialSharing;
@property            BOOL dialogIsShowing;
@property (retain, readonly) NSError *error;

+ (id)jrSessionData;
+ (id)jrSessionDataWithAppId:(NSString*)newAppId tokenUrl:(NSString*)newTokenUrl
                 andDelegate:(id<JRSessionDelegate>)newDelegate;

- (void)tryToReconfigureLibrary;
- (id)reconfigureWithAppId:(NSString*)newAppId tokenUrl:(NSString*)newTokenUrl;

- (void)addDelegate:(id<JRSessionDelegate>)delegateToAdd;
- (void)removeDelegate:(id<JRSessionDelegate>)delegateToRemove;

- (NSURL*)startUrlForCurrentProvider;
- (JRProvider*)getProviderNamed:(NSString*)name;

- (JRAuthenticatedUser*)authenticatedUserForProvider:(JRProvider*)provider;
- (JRAuthenticatedUser*)authenticatedUserForProviderNamed:(NSString*)provider;
- (void)forgetAuthenticatedUserForProvider:(NSString*)providerName;

- (NSDictionary *)allProviders;

- (void)forgetAllAuthenticatedUsers;

- (BOOL)weShouldBeFirstResponder;

- (void)shareActivityForUser:(JRAuthenticatedUser*)user;
- (void)setStatusForUser:(JRAuthenticatedUser*)user;

- (void)triggerAuthenticationDidCompleteWithPayload:(NSDictionary*)payloadDict;
- (void)triggerAuthenticationDidStartOver:(id)sender;
- (void)triggerAuthenticationDidCancel;
- (void)triggerAuthenticationDidCancel:(id)sender;
- (void)triggerAuthenticationDidTimeOutConfiguration;
- (void)triggerAuthenticationDidFailWithError:(NSError*)theError;

- (void)triggerPublishingDidCancel;
- (void)triggerPublishingDidCancel:(id)sender;
- (void)triggerPublishingDidTimeOutConfiguration;
- (void)triggerPublishingDidFailWithError:(NSError*)theError;

- (void)triggerEmailSharingDidComplete;
- (void)triggerSmsSharingDidComplete;

- (void)setCustomProvidersWithDictionary:(NSDictionary *)customProviders __unused;

- (void)clearReturningAuthenticationProvider;
@end

