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

 File:   JRCaptureInterface.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Thursday, January 26, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "JRCapture.h"
#import "debug_log.h"
#import "JRCaptureApidInterface.h"
#import "JRCaptureData.h"
#import "JSONKit.h"
#import "NSMutableDictionary+JRDictionaryUtils.h"
#import "NSMutableURLRequest+JRRequestUtils.h"

static NSString *const cSignInUser = @"signinUser";
static NSString *const cGetUser = @"getUser";
static NSString *const cGetObject = @"getObject";
static NSString *const cUpdateObject = @"updateObject";
static NSString *const cReplaceObject = @"replaceObject";
static NSString *const cReplaceArray = @"replaceArray";
static NSString *const cTagAction = @"action";


@implementation JRCaptureApidInterface
static JRCaptureApidInterface *singleton = nil;

- (JRCaptureApidInterface *)init
{
    if ((self = [super init])) { }

    return self;
}

+ (id)captureInterfaceInstance
{
    if (singleton == nil) {
        singleton = [((JRCaptureApidInterface *)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self captureInterfaceInstance] retain];
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

typedef enum CaptureInterfaceStatEnum
{
    StatOk,
    StatFail,
} CaptureInterfaceStat;

- (void)finishSignInFailureWithError:(JRCaptureError *)error forDelegate:(id)delegate
                         withContext:(NSObject *)context
{
    if ([delegate conformsToProtocol:@protocol(JRCaptureSignInDelegate)] &&
            [delegate respondsToSelector:@selector(captureAuthenticationDidFailWithError:)])
    {
        [delegate captureAuthenticationDidFailWithError:error];
    }

    if ([delegate conformsToProtocol:@protocol(JRCaptureInterfaceDelegate)] &&
            [delegate respondsToSelector:@selector(signInCaptureUserDidFailWithResult:context:)])
        [delegate signInCaptureUserDidFailWithResult:error context:context];
}

- (void)finishSignInSuccessWithResult:(NSString *)result forDelegate:(id)delegate withContext:(NSObject *)context
{
    if ([delegate conformsToProtocol:@protocol(JRCaptureSignInDelegate)] &&
            [delegate respondsToSelector:@selector(captureAuthenticationDidSucceedForUser:status:)])
    {
        BOOL respondsToFail = [delegate respondsToSelector:@selector(captureAuthenticationDidFailWithError:)];
        NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingOptions) 0
                                                                     error:nil];

        FinishSignInError err = [JRCaptureApidInterface finishSignInWithPayload:resultDict forDelegate:delegate];

        if ((err == cJRInvalidResponse || err == cJRInvalidCaptureUser) && respondsToFail)
        {
            [delegate captureAuthenticationDidFailWithError:[JRCaptureError invalidApiResponseErrorWithString:result]];
            return;
        }
    }

    if ([delegate conformsToProtocol:@protocol(JRCaptureInterfaceDelegate)] &&
            [delegate respondsToSelector:@selector(signInCaptureUserDidSucceedWithResult:context:)])
        [delegate signInCaptureUserDidSucceedWithResult:result context:context];
}


- (void)signInCaptureUserWithCredentials:(NSDictionary *)credentials ofType:(NSString *)signInFieldName
                             forDelegate:(id)delegate withContext:(NSObject *)context
{
    DLog(@"");
    NSString *refreshSecret = [JRCaptureData generateAndStoreRefreshSecret];

    if (!refreshSecret)
    {
        NSString *errMsg = @"unable to generate secure random refresh secret";
        [self finishSignInFailureWithError:[JRCaptureError invalidInternalStateErrorWithDescription:errMsg]
                               forDelegate:delegate withContext:context];
        return;
    }

    NSMutableDictionary *signInParams = [[@{
            @"client_id" : [JRCaptureData sharedCaptureData].clientId,
            @"locale" : [JRCaptureData sharedCaptureData].captureLocale,
            @"form" : [JRCaptureData sharedCaptureData].captureSignInFormName,
            @"redirect_uri" : [[JRCaptureData sharedCaptureData] redirectUri],
            @"response_type" : @"token",
            @"refresh_secret" : refreshSecret
    } mutableCopy] autorelease];

    [signInParams addEntriesFromDictionary:credentials];
    [signInParams JR_maybeSetObject:[JRCaptureData sharedCaptureData].bpChannelUrl forKey:@"bp_channel"];
    [signInParams JR_maybeSetObject:[JRCaptureData sharedCaptureData].captureFlowName forKey:@"flow_name"];

    NSMutableURLRequest *request = [JRCaptureData requestWithPath:@"/oauth/auth_native_traditional"];
    [request JR_setBodyWithParams:signInParams];

    NSMutableDictionary *tag = [[@{cTagAction : cSignInUser, @"delegate" : delegate } mutableCopy] autorelease];
    if (context) [tag setObject:context forKey:@"context"];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        JRCaptureError *err = [JRCaptureError connectionCreationErr:request forDelegate:self withTag:tag];
        [self finishSignInFailureWithError:err forDelegate:delegate withContext:context];
    }
}

- (void)finishGetCaptureUserWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                         forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(getCaptureUserDidSucceedWithResult:context:)])
            [delegate getCaptureUserDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(getCaptureUserDidFailWithResult:context:)])
            [delegate getCaptureUserDidFailWithResult:result context:context];
    }
}

- (void)getCaptureUserWithToken:(NSString *)token forDelegate:(id <JRCaptureInterfaceDelegate>)delegate
                    withContext:(NSObject *)context
{
    NSMutableURLRequest *request = [self entityRequestForPath:nil token:token];

    NSMutableDictionary *tag = [[@{cTagAction : cGetUser, @"delegate" : delegate } mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishGetCaptureUserWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }
}

- (void)finishGetObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                    forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(getCaptureObjectDidSucceedWithResult:context:)])
            [delegate getCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(getCaptureObjectDidFailWithResult:context:)])
            [delegate getCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)getCaptureObjectAtPath:(NSString *)entityPath withToken:(NSString *)token
                   forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    NSMutableURLRequest *request = [self entityRequestForPath:entityPath token:token];

    NSMutableDictionary *tag = [[@{cTagAction : cGetObject, @"delegate" : delegate } mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode 
        };
        [self finishGetObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }
}

- (NSMutableURLRequest *)entityRequestForPath:(NSString *)entityPath token:(NSString *)token
{
    NSMutableDictionary *params = [[@{@"access_token" : token} mutableCopy] autorelease];

    if (entityPath && ![entityPath isEqualToString:@""])
        [params setObject:entityPath forKey:@"attribute_name"];

    NSMutableURLRequest *request = [JRCaptureData requestWithPath:@"/entity"];
    [request JR_setBodyWithParams:params];
    return request;
}

- (void)finishUpdateObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                       forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");

    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(updateCaptureObjectDidSucceedWithResult:context:)])
            [delegate updateCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(updateCaptureObjectDidFailWithResult:context:)])
            [delegate updateCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)updateObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath
           withToken:(NSString *)token forDelegate:(id <JRCaptureInterfaceDelegate>)delegate
         withContext:(NSObject *)context
{
    DLog(@"");

    NSString      *attributes = [[captureObject JSONString] stringByAddingUrlPercentEscapes];
    NSMutableData *body       = [NSMutableData data];

    NSString *attrArgString = [NSString stringWithFormat:@"&attributes=%@", attributes];
    [body appendData:[attrArgString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (!entityPath || [entityPath isEqualToString:@""])
    {
        ;
    }
    else
    {
        NSString *attrNameArgString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[attrNameArgString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *updateUrl = [NSString stringWithFormat:@"%@/entity.update",
                                                     [JRCaptureData sharedCaptureData].captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:updateUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cUpdateObject, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishUpdateObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

- (void)finishReplaceObjectWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                        forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");
    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureObjectDidSucceedWithResult:context:)])
            [delegate replaceCaptureObjectDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureObjectDidFailWithResult:context:)])
            [delegate replaceCaptureObjectDidFailWithResult:result context:context];
    }
}

- (void)replaceObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath
            withToken:(NSString *)token forDelegate:(id <JRCaptureInterfaceDelegate>)delegate
          withContext:(NSObject *)context
{
    DLog(@"");

    NSString      *attributes = [[captureObject JSONString] stringByAddingUrlPercentEscapes];
    NSMutableData *body       = [NSMutableData data];

    [body appendData:[[NSString stringWithFormat:@"&attributes=%@", attributes] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (!entityPath || [entityPath isEqualToString:@""])
    {
        ;
    }
    else
    {
        NSString *argString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[argString dataUsingEncoding:NSUTF8StringEncoding]];        
    }

    NSString *replaceUrl = [NSString stringWithFormat:@"%@/entity.replace",
                                                      [JRCaptureData sharedCaptureData].captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:replaceUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cReplaceObject, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                      [[request URL] absoluteString]];
        NSNumber *errCode = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : errCode,
        };
        [self finishReplaceObjectWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

- (void)finishReplaceArrayWithStat:(CaptureInterfaceStat)stat andResult:(NSDictionary *)result
                       forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    DLog(@"");
    if (stat == StatOk)
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureArrayDidSucceedWithResult:context:)])
            [delegate replaceCaptureArrayDidSucceedWithResult:result context:context];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(replaceCaptureArrayDidFailWithResult:context:)])
            [delegate replaceCaptureArrayDidFailWithResult:result context:context];
    }
}

- (void)replaceArray:(NSArray *)captureArray atPath:(NSString *)entityPath
           withToken:(NSString *)token forDelegate:(id <JRCaptureInterfaceDelegate>)delegate
         withContext:(NSObject *)context
{
    DLog(@"");

    NSString      *attributes = [[captureArray JSONString] stringByAddingUrlPercentEscapes];
    NSMutableData *body       = [NSMutableData data];

    [body appendData:[[NSString stringWithFormat:@"&attributes=%@", attributes] 
            dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&access_token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"&include_record=true" dataUsingEncoding:NSUTF8StringEncoding]];

    if (entityPath && ![entityPath isEqualToString:@""])
    {
        NSString *argString = [NSString stringWithFormat:@"&attribute_name=%@", entityPath];
        [body appendData:[argString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *captureBaseUrl = [JRCaptureData sharedCaptureData].captureBaseUrl;
    NSString *replaceUrl = [NSString stringWithFormat:@"%@/entity.replace", captureBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:replaceUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSMutableDictionary *tag = [[@{cTagAction : cReplaceArray, @"delegate" : delegate} mutableCopy] autorelease];
    [tag JR_maybeSetObject:context forKey:@"context"];

    DLog(@"%@ attributes=%@ access_token=%@ attribute_name=%@", [[request URL] absoluteString], attributes, token,
        entityPath);

    /* tag vs context for workaround */
    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag]) 
    {
        NSString *errDesc = [NSString stringWithFormat:@"Could not create a connection to %@",
                                                       [[request URL] absoluteString]];
        NSNumber *code = [NSNumber numberWithInteger:JRCaptureLocalApidErrorUrlConnection];
        NSDictionary *result = @{
                @"stat" : @"error",
                @"error" : @"url_connection",
                @"error_description" : errDesc,
                @"code" : code,
        };
        [self finishReplaceArrayWithStat:StatFail andResult:result forDelegate:delegate withContext:context];
    }

}

+ (void)signInCaptureUserWithCredentials:(NSDictionary *)credentials ofType:(NSString *)signInType
                             forDelegate:(id)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            signInCaptureUserWithCredentials:credentials ofType:signInType forDelegate:delegate
                                 withContext:context];
}

+ (void)getCaptureUserWithToken:(NSString *)token
                    forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            getCaptureUserWithToken:token forDelegate:delegate withContext:context];
}

+ (void)getCaptureObjectAtPath:(NSString *)entityPath withToken:(NSString *)token
                   forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context __unused
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            getCaptureObjectAtPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

+ (void)updateCaptureObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath withToken:(NSString *)token
                forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            updateObject:captureObject atPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

+ (void)replaceCaptureObject:(NSDictionary *)captureObject atPath:(NSString *)entityPath withToken:(NSString *)token
                 forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            replaceObject:captureObject atPath:entityPath withToken:token forDelegate:delegate
              withContext:context];
}

+ (void)replaceCaptureArray:(NSArray *)captureArray atPath:(NSString *)entityPath withToken:(NSString *)token
                forDelegate:(id <JRCaptureInterfaceDelegate>)delegate withContext:(NSObject *)context
{
    [[JRCaptureApidInterface captureInterfaceInstance]
            replaceArray:captureArray atPath:entityPath withToken:token forDelegate:delegate withContext:context];
}

- (void)connectionDidFinishLoadingWithPayload:(NSString *)payload request:(NSURLRequest*)request andTag:(id)userData
{
    DLog(@"%@", payload);

    NSDictionary *tag       = (NSDictionary *) userData;
    NSString     *action    = [tag objectForKey:cTagAction];
    NSObject     *context   = [tag objectForKey:@"context"];

    NSDictionary *response    = [payload objectFromJSONString];
    CaptureInterfaceStat stat = [[response objectForKey:@"stat"] isEqualToString:@"ok"] ? StatOk : StatFail;

    id<JRCaptureInterfaceDelegate> delegate = [tag objectForKey:@"delegate"];

    if ([action isEqualToString:cSignInUser])
    {
        [self finishSignInUserWithPayload:payload context:context response:response stat:stat delegate:delegate];
    }
    else if ([action isEqualToString:cGetUser])
    {
        [self finishGetCaptureUserWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetObject])
    {
        [self finishGetObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cUpdateObject])
    {
        [self finishUpdateObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceObject])
    {
        [self finishReplaceObjectWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceArray])
    {
        [self finishReplaceArrayWithStat:stat andResult:response forDelegate:delegate withContext:context];
    }
}

- (void)finishSignInUserWithPayload:(NSString *)payload context:(NSObject *)context response:(NSDictionary *)response
                               stat:(CaptureInterfaceStat)stat delegate:(id)delegate
{
    if (stat == StatOk)
        [self finishSignInSuccessWithResult:payload forDelegate:delegate withContext:context];
    else
    {
        JRCaptureError *error = [JRCaptureError errorFromResult:response onProvider:nil engageToken:nil];
        [self finishSignInFailureWithError:error forDelegate:delegate withContext:context];
    }
}

- (void)connectionDidFinishLoadingWithFullResponse:(NSURLResponse*)fullResponse unencodedPayload:(NSData*)payload
                                           request:(NSURLRequest*)request andTag:(id)userData { }

- (void)connectionDidFailWithError:(NSError *)error request:(NSURLRequest*)request andTag:(id)userData
{
    DLog(@"");

    NSDictionary *tag       = (NSDictionary*) userData;
    NSString     *action    = [tag objectForKey:cTagAction];
    NSObject     *context   = [tag objectForKey:@"context"];
    id<JRCaptureInterfaceDelegate> delegate = [tag objectForKey:@"delegate"];

    NSDictionary *errDict = @{
            @"stat" : @"error",
            @"error" : [error localizedDescription],
            @"error_description" : [error localizedFailureReason],
            @"code" : [NSNumber numberWithInteger:JRCaptureLocalApidErrorConnectionDidFail],
            @"wrapped_error" : error,
    };

    JRCaptureError *wrappingError = [JRCaptureError errorFromResult:errDict onProvider:nil engageToken:nil];

    if ([action isEqualToString:cSignInUser])
    {
        [self finishSignInFailureWithError:wrappingError forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetUser])
    {
        [self finishGetCaptureUserWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cGetObject])
    {
        [self finishGetObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cUpdateObject])
    {
        [self finishUpdateObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceObject])
    {
        [self finishReplaceObjectWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
    else if ([action isEqualToString:cReplaceArray])
    {
        [self finishReplaceArrayWithStat:StatFail andResult:errDict forDelegate:delegate withContext:context];
    }
}

+ (FinishSignInError)finishSignInWithPayload:(NSDictionary *)payloadDict
                                 forDelegate:(id<JRCaptureSignInDelegate>)delegate
{
    NSString *accessToken   = [payloadDict objectForKey:@"access_token"];
    BOOL      isNew         = [(NSNumber*)[payloadDict objectForKey:@"is_new"] boolValue];

    NSDictionary *captureRecord = [payloadDict objectForKey:@"capture_user"];

    if (!captureRecord || !accessToken) return cJRInvalidResponse;

    JRCaptureUser *captureUser = [JRCaptureUser captureUserObjectFromDictionary:captureRecord];

    if (!captureUser) return cJRInvalidCaptureUser;

    [JRCaptureData setAccessToken:accessToken];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    JRCaptureRecordStatus recordStatus = isNew ? JRCaptureRecordNewlyCreated : JRCaptureRecordExists;

    if ([delegate respondsToSelector:@selector(captureAuthenticationDidSucceedForUser:status:)])
        [delegate captureAuthenticationDidSucceedForUser:captureUser status:recordStatus];

    return cJRNoError;
}

+ (void)maybeDispatch:(SEL)pSelector forDelegate:(id <JRCaptureSignInDelegate>)delegate withArg:(id)arg
{
    if ([delegate respondsToSelector:pSelector])
    {
        [delegate performSelector:pSelector withObject:arg];
    }
}

+ (void)jsonRequestToUrl:(NSString *)url params:(NSDictionary *)params
     completionHandler:(void(^)(id parsedResponse, NSError *e))handler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request JR_setBodyWithParams:params];
    NSString *p = [[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease];
    DLog(@"URL: \"%@\" params: \"%@\"", url, p);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
                           {
                               if (e)
                               {
                                   ALog(@"Error fetching JSON: %@", e);
                                   handler(nil, e);
                               }
                               else
                               {
                                   NSString *bodyString =
                                           [[[NSString alloc] initWithData:d
                                                                  encoding:NSUTF8StringEncoding] autorelease];
                                   NSError *err;
                                   id parsedJson = [NSJSONSerialization JSONObjectWithData:d
                                                                                   options:(NSJSONReadingOptions) 0
                                                                                     error:&err];
                                   ALog(@"Fetched: \"%@\"", bodyString);
                                   if (err)
                                   {
                                       ALog(@"Parse err: \"%@\"", err);
                                       handler(nil, e);
                                   }
                                   else
                                   {
                                       handler(parsedJson, nil);
                                   }
                               }
                           }];
}

- (void)connectionWasStoppedWithTag:(id)userData { }
@end
