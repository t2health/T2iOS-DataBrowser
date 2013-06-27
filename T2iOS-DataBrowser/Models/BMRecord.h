//
//  BMRecord.h
//  JanrainTest
//
//  Created by Tim Brooks on 5/20/13.
//  Copyright (c) 2013 Tim Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMRecordItem;

@interface BMRecord : NSObject

@property (nonatomic, strong) NSLocale* locale;
@property (nonatomic, strong) NSString* appName;
@property (nonatomic, strong) NSString* country;
@property (nonatomic, strong) NSDate* createdDate;
@property (nonatomic, strong) NSString* dataType;
@property (nonatomic, strong) NSString* guid;
@property (nonatomic, strong) NSString* language;
@property (nonatomic, strong) NSString* platform;
@property (nonatomic, strong) NSString* recordId;
@property (nonatomic, strong) NSDate* sessionDate;
@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, strong) NSString* timeStamp;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, readonly) NSArray* items;

- (void)updateAttributes:(NSDictionary*)attributes;
- (void)addRecordItem:(BMRecordItem*)item;
- (NSDictionary*)dictionary;
- (NSString*)sessionDateShortDescription;
- (NSString*)createdDateDescription;
- (BMRecordItem*)itemForKey:(NSString*)key;
- (BOOL)removeRecordItem:(BMRecordItem*)item;

@end
