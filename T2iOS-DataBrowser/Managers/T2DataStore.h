//
//  T2DataProvider.h
//  T2User
//
//  Created by Tim Brooks on 5/24/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMRecord;

@protocol T2DataStore <NSObject>

@required
// Init - takes a dictionary to use as an options hash // as different clients will need different config params
- (id)initWithStoreOptions:(NSDictionary*)options;
@property (nonatomic, strong) NSManagedObjectContext* context;

// CRUD
// Deletes
- (void)deleteRecord:(BMRecord*)record withCompletion:(void (^)(BOOL deleteSuccess, NSError* error))completion;
- (void)deleteKey:(NSString*)key forRecord:(BMRecord*)record withCompletion:(void (^)(BOOL deleteSuccess, NSError* error))completion;

// Inserts
- (void)addKeyValueForRecord:(BMRecord*)record usingKey:(NSString*)key withCompletion:(void (^)(BOOL updateSuccess, NSError* error))completion;
- (void)insertRecord:(BMRecord*)record;

// Reads
- (void)loadAllRowsWithCompletion:(void (^)(NSArray* items, NSError* error))completion;
- (void)loadRowsWithPredicate:(NSPredicate*)predicate andCompletion:(void (^)(NSArray* items, NSError* error))completion;

// Update
- (void)updateKeyValueForRecord:(BMRecord*)record usingKey:(NSString*)key withCompletion:(void (^)(BOOL updateSuccess, NSError* error))completion;

@optional
// Diagnostics
- (void)storeStatusWithBlock:(void (^)(NSString* status, NSError* error))block;

@end
