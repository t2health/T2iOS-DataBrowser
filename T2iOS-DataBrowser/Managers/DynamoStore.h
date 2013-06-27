#import <AWSDynamoDB/AWSDynamoDB.h>
#import "T2DataStore.h"

@class T2BMRecord;
@interface DynamoStore : NSObject <T2DataStore>

@property (nonatomic, strong) NSManagedObjectContext* context;

- (void)createTableNamed:(NSString*)tableName withSchemaElement:(DynamoDBKeySchemaElement*)element andAttribute:(DynamoDBAttributeDefinition*)definition;
- (void)destroyTable:(NSString*)tableName;

+ (DynamoStore*)sharedStore;
+ (DynamoStore*)sharedStoreForTable:(NSString*)tableName;

@end
