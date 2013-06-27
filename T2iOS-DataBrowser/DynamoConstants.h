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

#define TOKEN_VENDING_MACHINE_URL   @"h2tvm.elasticbeanstalk.com"
#define USE_SSL                     NO
#define CREDENTIALS_ALERT_MESSAGE   @"Please update the Constants.h file with the Token Vending Machine URL."
#define AWS_TABLE_NAME              @"TestT2"
#define AWS_TABLE_HASH_KEY          @"record_id"
#define AWS_TABLE_RANGE_KEY         @"created_at"
#define APP_ID                      @"iOS_CLIENT_TEST"
#define TABLE_NAME_KEY              @"TABLE_NAME"
