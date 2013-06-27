//
//  T2UserInfo.h
//  JanrainTest
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 Tim Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T2UserInfo : NSObject

@property (nonatomic, copy) NSString* displayName;
@property (nonatomic, copy) NSString* provider;
@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSDate* tokenExpirationDate;

@end
