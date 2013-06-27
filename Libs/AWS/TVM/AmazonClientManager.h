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
/*
 * Modified by: Tim Brooks, T2
 * Date: 5/22/13
 * Changes:  converted to shared instance (singleton)
 */

#import "Response.h"
#import <AWSDynamoDB/AWSDynamoDB.h>

@class AmazonTVMClient;

@interface AmazonClientManager : NSObject

@property (nonatomic, strong) AmazonDynamoDBClient* dbClient;
@property (nonatomic, strong) AmazonTVMClient* tvmClient;
@property (nonatomic, copy) NSString* tvmUrl;
@property (nonatomic) BOOL useSSL;

- (void)wipeCredentialsOnAuthError:(NSError *)error;
+ (AmazonClientManager*)sharedClient;

@end
