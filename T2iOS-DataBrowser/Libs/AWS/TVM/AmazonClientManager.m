/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import "AmazonTVMClient.h"

#define DEFAULT_TVM_URL @"CHANGE ME.elasticbeanstalk.com"

static AmazonDynamoDBClient *ddb = nil;
static AmazonTVMClient      *tvm = nil;

@interface AmazonClientManager ()

@end

@implementation AmazonClientManager

- (NSString*)tvmUrl
{
    if (!_tvmUrl) {
        _tvmUrl = DEFAULT_TVM_URL;
    }
    
    return _tvmUrl;
}
- (AmazonDynamoDBClient *)dbClient
{
    [[AmazonClientManager sharedClient] validateCredentials];
    return ddb;
}

- (AmazonTVMClient *)tvmClient
{
    if (tvm == nil) {
        tvm = [[AmazonTVMClient alloc] initWithEndpoint:self.tvmUrl useSSL:self.useSSL];
    }
    
    return tvm;
}

- (BOOL)hasCredentials
{
    return ![self.tvmUrl isEqualToString:DEFAULT_TVM_URL];
}

- (Response *)validateCredentials
{
    Response *ableToGetToken = [[Response alloc] initWithCode:200 andMessage:@"OK"];
    
    if ([AmazonKeyChainWrapper areCredentialsExpired]) {
        
        @synchronized(self)
        {
            if ([AmazonKeyChainWrapper areCredentialsExpired]) {
                
                ableToGetToken = [[AmazonClientManager sharedClient].tvmClient anonymousRegister];
                
                if ( [ableToGetToken wasSuccessful])
                {
                    ableToGetToken = [[AmazonClientManager sharedClient].tvmClient getToken];
                    
                    if ( [ableToGetToken wasSuccessful])
                    {
                        [[AmazonClientManager sharedClient] initClients];
                    }
                }
            }
        }
    }
    else if (ddb == nil)
    {
        @synchronized(self)
        {
            if (ddb == nil)
            {
                [[AmazonClientManager sharedClient] initClients];
            }
        }
    }
    
    return ableToGetToken;
}

- (void)initClients
{
    AmazonCredentials *credentials = [AmazonKeyChainWrapper getCredentialsFromKeyChain];
    
    ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
  //  ddb.endpoint = [AmazonEndpoints ddbEndpoint:US_EAST_1];
}

-(void)wipeAllCredentials
{
    @synchronized(self)
    {
        [AmazonKeyChainWrapper wipeCredentialsFromKeyChain];
        ddb = nil;
    }
}

- (void)wipeCredentialsOnAuthError:(NSError *)error
{
    id exception = [error.userInfo objectForKey:@"exception"];
    
    if([exception isKindOfClass:[AmazonServiceException class]])
    {
        AmazonServiceException *e = (AmazonServiceException *)exception;
        
        if(
           // STS http://docs.amazonwebservices.com/STS/latest/APIReference/CommonErrors.html
           [e.errorCode isEqualToString:@"IncompleteSignature"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InvalidClientTokenId"]
           || [e.errorCode isEqualToString:@"OptInRequired"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           || [e.errorCode isEqualToString:@"ServiceUnavailable"]
           
           // DynamoDB http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/ErrorHandling.html#APIErrorTypes
           || [e.errorCode isEqualToString:@"AccessDeniedException"]
           || [e.errorCode isEqualToString:@"IncompleteSignatureException"]
           || [e.errorCode isEqualToString:@"MissingAuthenticationTokenException"]
           || [e.errorCode isEqualToString:@"ValidationException"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InternalServerError"])
        {
            [[AmazonClientManager sharedClient] wipeAllCredentials];
        }
    }
}

+(AmazonClientManager *)sharedClient;
{
    static dispatch_once_t pred;
    static AmazonClientManager* instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
