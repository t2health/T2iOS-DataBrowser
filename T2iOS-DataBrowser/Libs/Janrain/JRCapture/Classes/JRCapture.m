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


 File:   JRCapture.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, January 31, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "JRCapture.h"

#import "JREngageWrapper.h"
#import "JRCaptureData.h"
#import "debug_log.h"
#import "JRBase64.h"

@implementation JRCapture

+ (void)setBackplaneChannelUrl:(NSString *)backplaneChannelUrl
{
    [JRCaptureData sharedCaptureData].bpChannelUrl = backplaneChannelUrl;
}

+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
                 captureFlowName:(NSString *)captureFlowName captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
   captureEnableThinRegistration:(BOOL)enableThinRegistration
          captureTraditionalSignInType:(__unused JRConventionalSigninType)tradSignInType
captureTraditionalRegistrationFormName:(NSString *)captureTraditionalRegistrationFormName
     captureSocialRegistrationFormName:(NSString *)captureSocialRegistrationFormName
                          captureAppId:(NSString *)captureAppId customIdentityProviders:(NSDictionary *)customProviders
{
    [JRCaptureData setCaptureDomain:captureDomain captureClientId:clientId captureLocale:captureLocale
              captureSignInFormName:captureSignInFormName captureFlowName:captureFlowName
         captureEnableThinRegistration:enableThinRegistration
captureTraditionalRegistrationFormName:captureTraditionalRegistrationFormName
     captureSocialRegistrationFormName:captureSocialRegistrationFormName
                    captureFlowVersion:captureFlowVersion captureAppId:captureAppId];

    [JREngageWrapper configureEngageWithAppId:engageAppId customIdentityProviders:customProviders];
}

+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
                 captureFlowName:(NSString *)captureFlowName captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
    captureTraditionalSignInType:(JRConventionalSigninType)captureTraditionalSignInType
                    captureAppId:(NSString *)captureAppId customIdentityProviders:(NSDictionary *)customProviders
{
    [JRCapture setEngageAppId:engageAppId captureDomain:captureDomain
              captureClientId:clientId captureLocale:captureLocale
                 captureFlowName:captureFlowName captureFlowVersion:captureFlowVersion
captureTraditionalSignInFormName:captureSignInFormName
   captureEnableThinRegistration:YES
          captureTraditionalSignInType:captureTraditionalSignInType
captureTraditionalRegistrationFormName:nil
     captureSocialRegistrationFormName:nil
                          captureAppId:captureAppId
               customIdentityProviders:customProviders];
}

+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
             captureFlowName:(NSString *)captureFlowName captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRConventionalSigninType)captureTraditionalSignInType
{
    [JRCapture setEngageAppId:engageAppId captureDomain:captureDomain
              captureClientId:clientId captureLocale:captureLocale
                 captureFlowName:captureFlowName captureFlowVersion:nil
captureTraditionalSignInFormName:captureFormName
   captureEnableThinRegistration:YES
          captureTraditionalSignInType:captureTraditionalSignInType
captureTraditionalRegistrationFormName:nil
     captureSocialRegistrationFormName:nil
                          captureAppId:nil
               customIdentityProviders:nil];
}

+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
             captureFlowName:(NSString *)captureFlowName captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRConventionalSigninType)captureTraditionalSignInType
     customIdentityProviders:(NSDictionary *)customProviders
{
    [JRCapture setEngageAppId:engageAppId captureDomain:captureDomain
              captureClientId:clientId captureLocale:captureLocale
                 captureFlowName:captureFlowName captureFlowVersion:nil
captureTraditionalSignInFormName:captureFormName
   captureEnableThinRegistration:YES
          captureTraditionalSignInType:captureTraditionalSignInType
captureTraditionalRegistrationFormName:nil
     captureSocialRegistrationFormName:nil
                          captureAppId:nil
               customIdentityProviders:customProviders];
}


+ (NSString *)captureMobileEndpointUrl __unused
{
    return [JRCaptureData captureTokenUrlWithMergeToken:nil];
}

/**
 * Clears user sign-in state from the Capture Library
 * This includes:
 *  - access token
 *  - uuid
 * These are cleared from memory as well as from disk.
 *
 * This does not include:
 *  - user model
 * (User models are managed by the host application, not by the Capture library.)
 */
+ (void)clearSignInState
{
    [JRCaptureData clearSignInState];
}

+ (void)setAccessToken:(NSString *)newAccessToken __unused
{
    [JRCaptureData setAccessToken:newAccessToken];
}

+ (void)setRedirectUri:(NSString *)redirectUri __unused
{
    [JRCaptureData setCaptureRedirectUri:redirectUri];
}

+ (NSString *)getAccessToken __unused
{
    return [JRCaptureData sharedCaptureData].accessToken;
}

+ (void)startEngageSigninDialogForDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [JREngageWrapper startAuthenticationDialogWithConventionalSignIn:JRConventionalSigninNone
                                         andCustomInterfaceOverrides:nil forDelegate:delegate];
}

+ (void)startEngageSigninDialogWithConventionalSignin:(JRConventionalSigninType)conventionalSignInType
                                          forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [JREngageWrapper startAuthenticationDialogWithConventionalSignIn:conventionalSignInType
                                         andCustomInterfaceOverrides:nil forDelegate:delegate];
}

+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
                              forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [JREngageWrapper startAuthenticationDialogOnProvider:provider withCustomInterfaceOverrides:nil mergeToken:nil
                                             forDelegate:delegate];
}

+ (void)startEngageSigninDialogWithCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                                forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [JREngageWrapper startAuthenticationDialogWithConventionalSignIn:JRConventionalSigninNone
                                         andCustomInterfaceOverrides:customInterfaceOverrides
                                                         forDelegate:delegate];
}

+ (void)startEngageSigninDialogWithConventionalSignin:(JRConventionalSigninType)conventionalSignInType
                      andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                      forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    [JREngageWrapper startAuthenticationDialogWithConventionalSignIn:conventionalSignInType
                                         andCustomInterfaceOverrides:customInterfaceOverrides forDelegate:delegate];
}

+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
             withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                               mergeToken:(NSString *)mergeToken
                              forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    [JREngageWrapper startAuthenticationDialogOnProvider:provider
                            withCustomInterfaceOverrides:customInterfaceOverrides mergeToken:mergeToken
                                             forDelegate:delegate];
}

+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [JREngageWrapper startAuthenticationDialogOnProvider:provider
                            withCustomInterfaceOverrides:customInterfaceOverrides mergeToken:nil
                                             forDelegate:delegate];
}

+ (void)startCaptureConventionalSigninForUser:(NSString *)user withPassword:(NSString *)password
                               withSigninType:(JRConventionalSigninType)conventionalSignInType
                                   mergeToken:(NSString *)mergeToken forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    NSString *attrName = conventionalSignInType == JRConventionalSigninEmailPassword ? @"email" :
            conventionalSignInType == JRConventionalSigninUsernamePassword ? @"username" : nil;
    if (!attrName) return;

    NSMutableDictionary *creds = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                              user, attrName,
                                                              password, @"password", nil];
    if (mergeToken) [creds setObject:mergeToken forKey:@"merge_token"];

    [JRCaptureApidInterface signInCaptureUserWithCredentials:creds ofType:attrName forDelegate:delegate
                                                 withContext:nil];
}

+ (void)startCaptureConventionalSigninForUser:(NSString *)user withPassword:(NSString *)password
                               withSigninType:(JRConventionalSigninType)conventionalSignInType
                                  forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused
{
    [self startCaptureConventionalSigninForUser:user withPassword:password withSigninType:conventionalSignInType
                                     mergeToken:nil forDelegate:delegate];
}

+ (void)refreshAccessTokenWithCallback:(void (^)(BOOL, NSError *))callback __unused
{
    NSString *date = [self utcTimeString];
    NSString *accessToken = [JRCaptureData sharedCaptureData].accessToken;
    NSString *refreshSecret = [JRCaptureData sharedCaptureData].refreshSecret;
    NSString *domain = [JRCaptureData sharedCaptureData].captureBaseUrl;
    NSString *refreshUrl = [NSString stringWithFormat:@"%@/oauth/refresh_access_token", domain];
    NSString *signature = [self base64SignatureForRefreshWithDate:date refreshSecret:refreshSecret
                                                      accessToken:accessToken];

    if (!signature || !accessToken || !date)
    {
        callback(NO, [JRCaptureError invalidInternalStateErrorWithDescription:@"unable to generate signature"]);
        return;
    }

    NSDictionary *params = @{
            @"access_token" : accessToken,
            @"signature" : signature,
            @"date" : date,

            @"client_id" : [JRCaptureData sharedCaptureData].clientId,
            @"locale" : [JRCaptureData sharedCaptureData].captureLocale,
    };

    [JRCaptureApidInterface jsonRequestToUrl:refreshUrl params:params completionHandler:^(id r, NSError *e)
    {
        if (e)
        {
            ALog(@"Failure refreshing access token: %@", e);
            callback(NO, e);
            return;
        }

        if ([@"ok" isEqual:[r objectForKey:@"stat"]])
        {
            [JRCaptureData setAccessToken:[r objectForKey:@"access_token"]];
            DLog(@"refreshed access token");
            callback(YES, nil);
        }
        else
        {
            callback(NO, [JRCaptureError errorFromResult:r onProvider:nil engageToken:nil]);
        }
    }];
}

+ (NSString *)utcTimeString
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

+ (NSString *)base64SignatureForRefreshWithDate:(NSString *)dateString refreshSecret:(NSString *)refreshSecret
                                    accessToken:(NSString *)accessToken
{
    if (!refreshSecret) return nil;
    NSString *stringToSign = [NSString stringWithFormat:@"refresh_access_token\n%@\n%@\n", dateString, accessToken];

    const char *cKey  = [refreshSecret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    return [[[[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)] autorelease] JRBase64EncodedString];
}

+ (void)registerNewUser:(JRCaptureUser *)newUser socialRegistrationToken:(NSString *)socialRegistrationToken
            forDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    if (!newUser)
    {
        [JRCaptureApidInterface maybeDispatch:@selector(registerUserDidFailWithError:) forDelegate:delegate
                                      withArg:[JRCaptureError invalidArgumentErrorWithParameterName:@"newUser"]];
        return;
    }

    JRCaptureData *config = [JRCaptureData sharedCaptureData];
    NSString *registrationForm = socialRegistrationToken ?
            config.captureSocialRegistrationFormName : config.captureTraditionalRegistrationFormName;
    NSMutableDictionary *params = [newUser toFormFieldsForForm:registrationForm withFlow:config.captureFlow];
    NSString *refreshSecret = [JRCaptureData generateAndStoreRefreshSecret];

    if (!refreshSecret)
    {
        [JRCaptureApidInterface maybeDispatch:@selector(registerUserDidFailWithError:) forDelegate:delegate
                                      withArg:[JRCaptureError invalidInternalStateErrorWithDescription:@"unable to generate secure "
                                              "random refresh secret"]];
        return;
    }

    [params addEntriesFromDictionary:@{
            @"client_id" : config.clientId,
            @"locale" : config.captureLocale,
            @"response_type" : @"token",
            @"redirect_uri" : [config redirectUri],
            @"flow_name" : config.captureFlowName,
            @"form" : registrationForm,
            @"refresh_secret" : refreshSecret,
    }];

    if (config.bpChannelUrl) [params setObject:config.bpChannelUrl forKey:@"bp_channel"];
    if ([config downloadedFlowVersion]) [params setObject:[config downloadedFlowVersion] forKey:@"flow_version"];

    NSString *urlString;
    if (socialRegistrationToken)
    {
        [params setObject:socialRegistrationToken forKey:@"token"];
        urlString = [NSString stringWithFormat:@"%@/oauth/register_native", config.captureBaseUrl];
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@/oauth/register_native_traditional", config.captureBaseUrl];
    }

    [JRCaptureApidInterface jsonRequestToUrl:urlString params:params completionHandler:^(id parsedResponse, NSError *e)
    {
        [self handleRegistrationResponse:parsedResponse orError:e delegate:delegate];
    }];
}

+ (void)handleRegistrationResponse:(id)parsedResponse orError:(NSError *)e
                          delegate:(id <JRCaptureSignInDelegate>)delegate
{
    SEL failMsg = @selector(registerUserDidFailWithError:);
    SEL successMsg = @selector(registerUserDidSucceed:);

    NSString *accessToken;
    if (e || ![parsedResponse isKindOfClass:[NSDictionary class]])
    {
        if (!e) e = [JRCaptureError invalidApiResponseErrorWithObject:parsedResponse];
    }

    if (!e && ![[parsedResponse objectForKey:@"stat"] isEqual:@"ok"])
    {
        e = [JRCaptureError errorFromResult:parsedResponse onProvider:nil engageToken:nil];
    }

    if (!e && !(accessToken = [parsedResponse objectForKey:@"access_token"]))
    {
        e = [JRCaptureError invalidApiResponseErrorWithObject:parsedResponse];
    }

    if (e)
    {
        ALog(@"%@", e);
        [JRCaptureApidInterface maybeDispatch:failMsg forDelegate:delegate withArg:e];
        return;
    }

    void (^userDictHandler)(id, NSError *) = ^(id newUserDict, NSError *e_)
    {
        JRCaptureUser *newUser_ = [JRCaptureUser captureUserObjectFromDictionary:newUserDict];
        [self setAccessToken:accessToken];
        [JRCaptureApidInterface maybeDispatch:successMsg forDelegate:delegate withArg:newUser_];
    };

    JRCaptureData *config = [JRCaptureData sharedCaptureData];
    NSString *entityUrl = [NSString stringWithFormat:@"%@/entity", config.captureBaseUrl];
    [JRCaptureApidInterface jsonRequestToUrl:entityUrl params:@{@"access_token" : accessToken}
                           completionHandler:^(id entityResponse, NSError *e_)
                           {
                               if (e_ || ![entityResponse isKindOfClass:[NSDictionary class]] ||
                                       ![@"ok" isEqual:[entityResponse objectForKey:@"stat"]] ||
                                       ![entityResponse objectForKey:@"result"])
                               {
                                   if (!e_) e_ = [JRCaptureError invalidApiResponseErrorWithObject:entityResponse];
                                   ALog(@"%@", e);
                                   [JRCaptureApidInterface maybeDispatch:failMsg forDelegate:delegate withArg:e_];
                                   return;
                               }

                               userDictHandler([entityResponse objectForKey:@"result"], nil);
                           }];
}

//+ (void)maybeDispatch:(SEL)pSelector forDelegate:(id <JRCaptureSignInDelegate>)delegate withArg:(id)arg1
//              withArg:(id)arg2
//{
//    if ([delegate respondsToSelector:pSelector])
//    {
//        [delegate performSelector:pSelector withObject:arg1 withObject:arg2];
//        [delegate performSelector:pSelector withObject:arg1];
//    }
//}

- (void)dealloc
{
    [super dealloc];
}

+ (void)startEngageSignInForDelegate:(id <JRCaptureSignInDelegate>)delegate
{
    [JRCapture startEngageSignInDialogForDelegate:delegate];
}
@end
