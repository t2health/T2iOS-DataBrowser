#import "DynamoStore.h"
#import "DynamoConstants.h"
#import "AmazonClientManager.h"
#import "BMRecord.h"
#import "BMDataConstants.h"

@interface DynamoStore ()

@property (nonatomic, strong) NSString* tableName;
@property (nonatomic, strong) dispatch_queue_t mutationQueue;

// Helpers
+ (NSString*)statusForTable:(NSString*)tableName withError:(NSError*)error;

@end

@implementation DynamoStore

- (id)initWithStoreOptions:(NSDictionary*)options
{
    self = [super init];
    if (self) {
        _tableName = [options valueForKey:TABLE_NAME_KEY];
    }
    return self;
}
- (dispatch_queue_t)mutationQueue
{
    if (!_mutationQueue) {
        _mutationQueue = dispatch_queue_create("org.t2.dynamoMutationQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _mutationQueue;
}
- (void)checkStoreValidity
{
    // Ensure table set
    NSAssert(![self.tableName isEqual:nil], @"TABLE_NAME key must be set.  Example: [[DynamoStore alloc] initWithOptions:@{@'TABLE_NAME' : @'FRED'}");
}
- (void)createTableNamed:(NSString*)tableName withSchemaElement:(DynamoDBKeySchemaElement*)element andAttribute:(DynamoDBAttributeDefinition*)definition
{
    DynamoDBCreateTableRequest* createTableRequest = [[DynamoDBCreateTableRequest alloc] init];
    DynamoDBProvisionedThroughput *provisionedThroughput = [[DynamoDBProvisionedThroughput alloc] init];
    provisionedThroughput.readCapacityUnits  = [NSNumber numberWithInt:10];
    provisionedThroughput.writeCapacityUnits = [NSNumber numberWithInt:5];
    
    createTableRequest.tableName = tableName;
    createTableRequest.provisionedThroughput = provisionedThroughput;
    [createTableRequest addKeySchema:element];
    [createTableRequest addAttributeDefinition:definition];

    DynamoDBCreateTableResponse* response = [[AmazonClientManager sharedClient].dbClient createTable:createTableRequest];
    if(response.error != nil) {
        [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);
    }
}

// Helpers
- (DynamoDBAttributeDefinition*)attributeDefinitionNamed:(NSString*)name ofType:(NSString*)type
{
    DynamoDBAttributeDefinition *attributeDefinition = [[DynamoDBAttributeDefinition alloc] init];
    attributeDefinition.attributeName = name;
    attributeDefinition.attributeType = type;
    
    return attributeDefinition;
}

+ (NSString*)statusForTable:(NSString*)tableName withError:(NSError*)error
{
    DynamoDBDescribeTableRequest* request  = [[DynamoDBDescribeTableRequest alloc] initWithTableName:tableName];
    DynamoDBDescribeTableResponse* response = [[AmazonClientManager sharedClient].dbClient describeTable:request];
    
    if (error) {
        error = response.error;
    }
    return response.table.tableStatus;
}

// Converts DynamoDBAttributeValues to string in hash for portability
// different providers may have to have different deserialization strategies
- (NSDictionary*)dictionaryFromHash:(NSDictionary*)hash
{
    NSMutableDictionary* tempHash = [[NSMutableDictionary alloc] initWithCapacity:[hash count]];
    
    [hash enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // peek at record
        NSString* stringKey = (NSString*)key;
        DynamoDBAttributeValue* dbValue = (DynamoDBAttributeValue*)obj;
        
        // parse precedence
        if (dbValue.sS && ([dbValue.sS count] > 0)) {
            // array of string
            tempHash[stringKey] = dbValue.sS;
        } else if (dbValue.s && ([dbValue.s length] > 0)) {
            // string
            tempHash[stringKey] = dbValue.s;
        } else if (dbValue.n  && ([dbValue.n length] > 0)) {
            // number
            tempHash[stringKey] = dbValue.n;
        } else if (dbValue.b  && ([dbValue.b length] > 0)) {
            // data gram
            tempHash[stringKey] = dbValue.b;
        } else if (dbValue.nS  && ([dbValue.nS count] > 0)) {
            // array of numbers
            tempHash[stringKey] = dbValue.nS;
        } else if (dbValue.bS  && ([dbValue.bS count] > 0)) {
            // array of data gram
            tempHash[stringKey] = dbValue.bS;
        } else {
            // null
            tempHash[stringKey] = [NSNull null];
        }
    }];
    
    return [tempHash copy];
}
- (void)safeLog:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{});
}

#pragma mark - TSDataStore Protocol
- (void)insertRecord:(BMRecord*)record
{
    [self checkStoreValidity];
    if([record.dictionary count] == 0) {
        return;
    }
    
    dispatch_async(self.mutationQueue, ^{
        
        NSError* error;
        NSString *tableStatus = [DynamoStore statusForTable:self.tableName withError:error];
        if ([tableStatus isEqualToString:@"ACTIVE"]) {
            __block NSMutableDictionary* itemSet = [[NSMutableDictionary alloc] init];
            
            NSArray* keys = [record.dictionary allKeys];
            
            for(NSString* key in keys) {
                NSString* item = [record.dictionary objectForKey:key];
                [itemSet setObject:[[DynamoDBAttributeValue alloc] initWithS:(NSString*)item] forKey:(NSString*)key];
            }
            
            if([itemSet count] > 0) {
                DynamoDBPutItemRequest *request = [[DynamoDBPutItemRequest alloc] initWithTableName:self.tableName andItem:itemSet];
                DynamoDBPutItemResponse *response = [[AmazonClientManager sharedClient].dbClient putItem:request];
                if(response.error != nil) {
                    [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:response.error];
                    NSLog(@"Error: %@", response.error);
                }
            }
        }
        else {
            NSLog(@"The %@ table is not ready yet. Status: %@", self.tableName, tableStatus);
        }
    });
}
- (void)loadRowsWithPredicate:(NSPredicate*)predicate andCompletion:(void (^)(NSArray* items, NSError* error))completion
{
    [self checkStoreValidity];
    
    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        DynamoDBScanRequest  *request  = [[DynamoDBScanRequest alloc] initWithTableName:self.tableName];
        DynamoDBScanResponse *response = [[AmazonClientManager sharedClient].dbClient scan:request];
        
        NSArray* rawItems = response.items;
        __block NSError* error = response.error;
        __block NSMutableArray* tempArray;
        
        if (rawItems && ([rawItems count] > 0)) {
            tempArray = [NSMutableArray array];
            for (NSDictionary* hash in rawItems) {
                
                NSDictionary* dic = [self dictionaryFromHash:hash];
                BMRecord* record = [[BMRecord alloc] init];
                [record updateAttributes:dic];
                
                if (record) {
                    [tempArray addObject:record];
                }
            }
        }
        
        if (error) {
            [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:response.error];
        }
        
        // get back on UI thread
        if (completion) {
            dispatch_async(mainQ, ^{
                completion([tempArray copy], error);
            });
        }
    });
}
- (void)loadAllRowsWithCompletion:(void (^)(NSArray* items, NSError* error))completion
{
    [self loadRowsWithPredicate:nil andCompletion:completion];
}
// Deletes the specified row and all of its attribute/value pairs.
- (void)deleteRecord:(BMRecord*)record withCompletion:(void (^)(BOOL deleteSuccess, NSError* error))completion
{
    [self checkStoreValidity];

    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        DynamoDBDeleteItemRequest *deleteItemRequest = [[DynamoDBDeleteItemRequest alloc] init];
        
        // hash key
        DynamoDBAttributeValue* primaryKey = [[DynamoDBAttributeValue alloc] initWithS:record.recordId];
        DynamoDBAttributeValue* rangeKey = [[DynamoDBAttributeValue alloc] initWithS:record.createdDateDescription];
        
        deleteItemRequest.tableName = self.tableName;
        deleteItemRequest.key = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                    AWS_TABLE_HASH_KEY : primaryKey,
                                    AWS_TABLE_RANGE_KEY : rangeKey
                                  }];
        
        DynamoDBDeleteItemResponse *deleteItemResponse = [[AmazonClientManager sharedClient].dbClient deleteItem:deleteItemRequest];
        
        __block BOOL deleteSuccess = YES;
        __block NSError* error = deleteItemResponse.error;

        if(error)
        {
            deleteSuccess = NO;
            [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:deleteItemResponse.error];
            NSLog(@"Error: %@", deleteItemResponse.error);
        }
        
        // get back on UI thread
        if (completion) {
            dispatch_async(mainQ, ^{
                completion(deleteSuccess, error);
            });
        }
    });
}
- (void)deleteKey:(NSString*)key forRecord:(BMRecord*)record withCompletion:(void (^)(BOOL deleteSuccess, NSError* error))completion
{
    [self checkStoreValidity];

    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        DynamoDBUpdateItemRequest* deleteKeyRequest = [DynamoDBUpdateItemRequest new];
        DynamoDBAttributeValueUpdate* nilValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:nil andAction:@"DELETE"];

        // hash key
        DynamoDBAttributeValue* primaryKey = [[DynamoDBAttributeValue alloc] initWithS:record.recordId];
        DynamoDBAttributeValue* rangeKey = [[DynamoDBAttributeValue alloc] initWithS:record.createdDateDescription];
        deleteKeyRequest.attributeUpdates = [NSMutableDictionary dictionaryWithObject:nilValueUpdate forKey:key];

        deleteKeyRequest.tableName = self.tableName;
        deleteKeyRequest.key = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                                          AWS_TABLE_HASH_KEY : primaryKey,
                                                         AWS_TABLE_RANGE_KEY : rangeKey
                                 }];

        
        DynamoDBUpdateItemResponse* deleteKeyResponse = [[AmazonClientManager sharedClient].dbClient updateItem:deleteKeyRequest];

        __block NSError* error = deleteKeyResponse.error;
        __block BOOL deleteSuccess = YES;

        if (error) {
            deleteSuccess = NO;
            [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:deleteKeyResponse.error];
            NSLog(@"Error: %@", deleteKeyResponse.error);
        }
       
        // get back on UI thread
        if (completion) {
            dispatch_async(mainQ, ^{
                completion(deleteSuccess, error);
            });
        }
    });

}
//Deletes the table and its key/value pairs
- (void)destroyTable:(NSString*)tableName
{
    DynamoDBDeleteTableRequest *request = [[DynamoDBDeleteTableRequest alloc] initWithTableName:tableName];
    DynamoDBDeleteTableResponse *response = [[AmazonClientManager sharedClient].dbClient deleteTable:request];
    if(response.error != nil)
    {
        [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);
    }
}
- (void)addKeyValueForRecord:(BMRecord*)record usingKey:(NSString*)key withCompletion:(void (^)(BOOL updateSuccess, NSError* error))completion
{
    // update in dynamo does a PUT -- so add is the same as update
    [self updateKeyValueForRecord:record usingKey:key withCompletion:completion];
}
- (void)updateKeyValueForRecord:(BMRecord*)record usingKey:(NSString*)key withCompletion:(void (^)(BOOL updateSuccess, NSError* error))completion
{
    [self checkStoreValidity];

    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        DynamoDBUpdateItemRequest *updateItemRequest = [DynamoDBUpdateItemRequest new];
        DynamoDBAttributeValue *attributeValue;
        id value = [record valueForKey:key];
        
        // determine update type - based on value type ~ currently only support arrays and strings
        if ([value isKindOfClass:[NSArray class]]) {
            attributeValue = [[DynamoDBAttributeValue alloc] initWithSS:[value mutableCopy]];
        } else {
            attributeValue = [[DynamoDBAttributeValue alloc] initWithS:value];
        }
        
        DynamoDBAttributeValueUpdate *attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"PUT"];
        
        // hash key
        DynamoDBAttributeValue* primaryKey = [[DynamoDBAttributeValue alloc] initWithS:record.recordId];
        DynamoDBAttributeValue* rangeKey = [[DynamoDBAttributeValue alloc] initWithS:record.createdDateDescription];
        
        updateItemRequest.tableName = self.tableName;
        updateItemRequest.key = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                                          AWS_TABLE_HASH_KEY : primaryKey,
                                                         AWS_TABLE_RANGE_KEY : rangeKey
                                 }];
        
        
        updateItemRequest.attributeUpdates = [NSMutableDictionary dictionaryWithObject:attributeValueUpdate forKey:key];
        DynamoDBUpdateItemResponse *updateItemResponse = [[AmazonClientManager sharedClient].dbClient updateItem:updateItemRequest];
        
        __block NSError* error = updateItemResponse.error;
        __block BOOL updateSuccess = YES;

        if(error)
        {
            updateSuccess = NO;
            [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:updateItemResponse.error];
            NSLog(@"Error: %@", updateItemResponse.error);
        }        
               
        // get back on UI thread
        if (completion) {
            dispatch_async(mainQ, ^{
                completion(updateSuccess, error);
            });
        }
    });
}

// Options methods
- (void)storeStatusWithBlock:(void (^)(NSString* status, NSError* error))block
{
    [self checkStoreValidity];
    
    dispatch_queue_t mainQ = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        DynamoDBDescribeTableRequest* request  = [[DynamoDBDescribeTableRequest alloc] initWithTableName:self.tableName];
        DynamoDBDescribeTableResponse* response = [[AmazonClientManager sharedClient].dbClient describeTable:request];
        
        __block NSError* error = response.error;
        __block NSString* status;
        
        if(response.error != nil) {
            [[AmazonClientManager sharedClient] wipeCredentialsOnAuthError:response.error];
            NSLog(@"Error: %@", response.error);
        } else {
            status = response.table.tableStatus;
        }
        
        // get back on UI thread
        if (block) {
            dispatch_async(mainQ, ^{
                block(status, error);
            });
        }
    });
}

// Singleton stuff
+ (DynamoStore*)sharedStore
{
    return [self sharedStoreForTable:AWS_TABLE_NAME];
}
+ (DynamoStore*)sharedStoreForTable:(NSString*)tableName
{
    static dispatch_once_t pred;
    static DynamoStore* instance = nil;
    
    dispatch_once(&pred, ^{
        instance = [[self alloc] initWithStoreOptions:@{TABLE_NAME_KEY : tableName}];
        [AmazonClientManager sharedClient].tvmUrl = TOKEN_VENDING_MACHINE_URL;
    });
    
    return instance;    
}

@end
