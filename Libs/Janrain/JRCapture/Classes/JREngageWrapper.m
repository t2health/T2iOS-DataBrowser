/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "JREngageWrapper.h"
#import "JRCaptureData.h"
#import "JREngage+CustomInterface.h"
#import "JSONKit.h"

typedef enum
{
    JREngageDialogStateAuthentication,
} JREngageDialogState;

@interface JREngageWrapper ()
@property(retain) NSString *engageToken;
@property(retain) JRConventionalSignInViewController *nativeSigninViewController;
@property(retain) id <JRCaptureSignInDelegate> delegate;
@property JREngageDialogState dialogState;
@end

@implementation JREngageWrapper
@synthesize nativeSigninViewController;
@synthesize delegate;
@synthesize dialogState;
@synthesize engageToken;

static JREngageWrapper *singleton = nil;

- (JREngageWrapper *)init
{
    if ((self = [super init])) { }

    return self;
}

+ (JREngageWrapper *)singletonInstance
{
    if (singleton == nil) {
        singleton = [((JREngageWrapper *)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self singletonInstance] retain];
}

- (id)copyWithZone:(__unused NSZone *)zone __unused
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release { }

- (id)autorelease
{
    return self;
}

+ (void)configureEngageWithAppId:(NSString *)appId customIdentityProviders:(NSDictionary *)customProviders
{
    [JREngage setEngageAppId:appId tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
    JREngage.customProviders = customProviders;
}

+ (void)startAuthenticationDialogWithConventionalSignIn:(JRConventionalSigninType)nativeSignInType
                            andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                            forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:nil]];

    JREngageWrapper *wrapper = [JREngageWrapper singletonInstance];
    [wrapper setDelegate:delegate];
    [wrapper setDialogState:JREngageDialogStateAuthentication];

    NSMutableDictionary *expandedCustomInterfaceOverrides =
            [NSMutableDictionary dictionaryWithDictionary:customInterfaceOverrides];

    if (nativeSignInType != JRConventionalSigninNone)
    {
        [self configureTradSignIn:nativeSignInType expandedCustomInterfaceOverrides:expandedCustomInterfaceOverrides];
    }

    [JREngage showAuthenticationDialogWithCustomInterfaceOverrides:expandedCustomInterfaceOverrides];
}

+ (void)     configureTradSignIn:(JRConventionalSigninType)nativeSigninType
expandedCustomInterfaceOverrides:(NSMutableDictionary *)expandedCustomInterfaceOverrides
{
    NSString *nativeSignInTitleString =
            ([expandedCustomInterfaceOverrides objectForKey:kJRCaptureConventionalSigninTitleString] ?
                    [expandedCustomInterfaceOverrides objectForKey:kJRCaptureConventionalSigninTitleString] :
                    (nativeSigninType == JRConventionalSigninEmailPassword ?
                            @"Sign In With Your Email and Password" :
                            @"Sign In With Your Username and Password"));

    if (![expandedCustomInterfaceOverrides objectForKey:kJRProviderTableSectionHeaderTitleString])
        [expandedCustomInterfaceOverrides setObject:@"Sign In With a Social Provider"
                                             forKey:kJRProviderTableSectionHeaderTitleString];

    UIView *const titleView = [expandedCustomInterfaceOverrides objectForKey:kJRCaptureConventionalSigninTitleView];
    JRConventionalSignInViewController *controller =
            [JRConventionalSignInViewController conventionalSignInViewController:nativeSigninType
                                                                     titleString:nativeSignInTitleString
                                                                       titleView:titleView
                                                                   engageWrapper:singleton];
    singleton.nativeSigninViewController = controller;

    [expandedCustomInterfaceOverrides setObject:[singleton nativeSigninViewController].view
                                         forKey:kJRProviderTableHeaderView];

    [expandedCustomInterfaceOverrides setObject:[singleton nativeSigninViewController]
                                         forKey:kJRCaptureConventionalSigninViewController];
}


+ (void)startAuthenticationDialogOnProvider:(NSString *)provider
               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                 mergeToken:(NSString *)mergeToken
                                forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureTokenUrlWithMergeToken:mergeToken]];

    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];

    [JREngage showAuthenticationDialogForProvider:provider withCustomInterfaceOverrides:customInterfaceOverrides];
}

- (void)engageLibraryTearDown
{
    [JREngage updateTokenUrl:nil];
    self.delegate = nil;
    self.nativeSigninViewController = nil;
    self.engageToken = nil;
}

- (void)authenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error
                         forProvider:(NSString *)provider
{
    DLog();
    if ([delegate respondsToSelector:@selector(captureAuthenticationDidFailWithError:)])
        [delegate captureAuthenticationDidFailWithError:error];

    [self engageLibraryTearDown];
}

- (void)authenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    DLog();
    if ([delegate respondsToSelector:@selector(engageAuthenticationDidFailWithError:forProvider:)])
        [delegate engageAuthenticationDidFailWithError:error forProvider:provider];

    [self engageLibraryTearDown];
}

- (void)authenticationDidNotComplete
{
    DLog();
    if ([delegate respondsToSelector:@selector(engageSigninDidNotComplete)])
        [delegate engageSigninDidNotComplete];

    [self engageLibraryTearDown];
}

- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response
                            andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider
{
    NSString *payload = [[[NSString alloc] initWithData:tokenUrlPayload encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *payloadDict = [payload objectFromJSONString];

    DLog(@"%@", payload);

    if (!payloadDict)
        return [self authenticationCallToTokenUrl:tokenUrl
                                 didFailWithError:[JRCaptureError invalidApiResponseErrorWithString:payload]
                                      forProvider:provider];

    if (![[payloadDict objectForKey:@"stat"] isEqual:@"ok"])
    {
        JRCaptureError *error = [JRCaptureError errorFromResult:payloadDict onProvider:provider
                                                    engageToken:engageToken];
        [self authenticationCallToTokenUrl:tokenUrl didFailWithError:error forProvider:provider];
        return;
    }

    FinishSignInError error = [JRCaptureApidInterface finishSignInWithPayload:payloadDict forDelegate:delegate];

    if (error == cJRInvalidResponse || error == cJRInvalidCaptureUser)
    {
        [self authenticationCallToTokenUrl:tokenUrl didFailWithError:[JRCaptureError invalidApiResponseErrorWithString:payload]
                               forProvider:provider];
    }

    [self engageLibraryTearDown];
}

- (void)authenticationDidSucceedForUser:(NSDictionary *)auth_info forProvider:(NSString *)provider
{
    self.engageToken = [auth_info objectForKey:@"token"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    if ([delegate respondsToSelector:@selector(engageSigninDidSucceedForUser:forProvider:)])
        [delegate engageSigninDidSucceedForUser:auth_info forProvider:provider];
}

- (void)engageDialogDidFailToShowWithError:(NSError *)error
{
    if (dialogState == JREngageDialogStateAuthentication)
    {
        if ([delegate respondsToSelector:@selector(engageSigninDialogDidFailToShowWithError:)])
            [delegate engageSigninDialogDidFailToShowWithError:error];
    }

    [self engageLibraryTearDown];
}

- (void)dealloc
{
    [delegate release];

    [nativeSigninViewController release];
    [engageToken release];
    [super dealloc];
}
@end
