#import "BMRecord.h"
#import "BMRecordItem.h"
#import "NSDictionary+NSDictionary_ObjectForKeyOrNil.h"
#import "BMDataConstants.h"

@interface BMRecord ()

@property (nonatomic, strong) NSMutableArray* recordItems;

@end

@implementation BMRecord
@synthesize locale = _locale;

- (NSLocale*)locale
{
    if (!_locale) {
        // create a locale from language and country
        if ([self localeIdentifier]) {
            _locale = [[NSLocale alloc] initWithLocaleIdentifier:[self localeIdentifier]];
        } else {
            _locale = [NSLocale currentLocale];
        }
    }

    
    return _locale;
}

- (void)configure
{
    // initialize to sensible defaults if empty
    if (!self.createdDate) {
        self.createdDate = [NSDate date];
    }

    if (!self.guid) {
        self.guid = [((NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)))) lowercaseString];
    }

    if (!self.timeStamp) {
        self.timeStamp = [NSString stringWithFormat:@"%lli", [@(floor([self.createdDate timeIntervalSince1970] * 1000)) longLongValue]];
    }
    
    if (!self.recordId) {
        self.recordId = [NSString stringWithFormat:@"%@-%@", self.timeStamp, self.guid];
    }

    if (!self.language) {
        NSString* languageCode = [self.locale objectForKey: NSLocaleLanguageCode];
        self.language =  [self.locale displayNameForKey: NSLocaleLanguageCode value:languageCode];
    }

    if (!self.platform) {
        self.platform = [[UIDevice currentDevice] systemName];
    }

    if (!self.version) {
        self.version = [[UIDevice currentDevice] systemVersion];
    }
    
    if (!self.sessionDate) {
        self.sessionDate = [NSDate date];
    }
    
    if (!self.sessionId) {
        self.sessionId = [NSString stringWithFormat:@"%lli", [@(floor([self.sessionDate timeIntervalSince1970] * 1000)) longLongValue]];
    }
    
}
- (NSMutableArray*)recordItems
{
    if (!_recordItems) {
        _recordItems = [NSMutableArray array];
    }
    
    return _recordItems;
}
- (NSArray*)items
{
    return [self.recordItems copy];
}
- (void)addRecordItem:(BMRecordItem *)item
{
    [self.recordItems addObject:item];
}
- (NSDictionary*)dictionary
{
    NSMutableDictionary* tempSet = [[NSMutableDictionary alloc] init];
    
    // start with 'dynamic' properties
    for (BMRecordItem* item in self.items) {
        [tempSet setValue:item.value forKey:item.key];
    }

    // ensure defaults are set
    [self configure];
    
    // now add fixed properties (will override any 'defaults' supplied via
    // dynamic key/value additions
    [tempSet setValue:self.appName forKey:APP_NAME];
    [tempSet setValue:self.dataType forKey:DATA_TYPE];
    [tempSet setValue:self.country forKey:LOCALE_COUNTRY];
    [tempSet setValue:self.language forKey:LOCALE_LANGUAGE];
    [tempSet setValue:self.platform forKey:PLATFORM];
    [tempSet setValue:self.version forKey:PLATFORM_VERSION];
    [tempSet setValue:self.recordId forKey:RECORD_ID];
    [tempSet setValue:self.sessionId forKey:SESSION_ID];
    [tempSet setValue:self.timeStamp forKey:TIME_STAMP];

    if (self.createdDate) {
        [tempSet setValue:[[BMRecord creationDateFormatter] stringFromDate:self.createdDate] forKey:CREATED_AT];
    }

    if (self.sessionDate) {
        [tempSet setValue:[[BMRecord sessionDateFormatter] stringFromDate:self.sessionDate] forKey:SESSION_DATE];
    }
    
    return [tempSet copy];
}
- (NSString*)sessionDateShortDescription
{
    NSString* description;
    if (self.sessionDate) {
        description = [[BMRecord sessionDateFormatter] stringFromDate:self.sessionDate];
    }
    
    return description;
}
- (NSString*)createdDateDescription
{
    NSString* description;
    if (self.createdDate) {
        description = [[BMRecord creationDateFormatter] stringFromDate:self.createdDate];
    }
    
    return description;
}

- (void)updateAttributes:(NSDictionary*)attributes
{
    NSMutableDictionary* hash = [attributes mutableCopy];
    
    self.appName = [self valueFromDictionary:hash key:APP_NAME destructive:YES defaultValue:@"[No App Name]"];
    self.dataType = [self valueFromDictionary:hash key:DATA_TYPE destructive:YES defaultValue:@"[UNKNOWN]"];
    
    self.country = [self valueFromDictionary:hash key:LOCALE_COUNTRY destructive:YES];
    if (!self.country) {
        // country
        NSString* countryCode = [self.locale objectForKey: NSLocaleCountryCode];
        self.country = [self.locale displayNameForKey: NSLocaleCountryCode value:countryCode];
    }
    
    self.language = [self valueFromDictionary:hash key:LOCALE_LANGUAGE destructive:YES];
    self.platform = [self valueFromDictionary:hash key:PLATFORM destructive:YES];
    self.recordId = [self valueFromDictionary:hash key:RECORD_ID destructive:YES];
    self.sessionId = [self valueFromDictionary:hash key:SESSION_ID destructive:YES];
    self.timeStamp = [self valueFromDictionary:hash key:TIME_STAMP destructive:YES];
    self.version = [self valueFromDictionary:hash key:PLATFORM_VERSION destructive:YES];
    
    // if record Id & timestamp retrieve guid
    if (self.recordId && self.timeStamp) {
        NSString* timePart = [NSString stringWithFormat:@"%@-", self.timeStamp];
        self.guid = [self.recordId stringByReplacingOccurrencesOfString:timePart withString:@""];
    } else {
        // create new
        self.guid = [((NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, CFUUIDCreate(NULL)))) lowercaseString];
    }

    NSString* dateString = [self valueFromDictionary:hash key:CREATED_AT destructive:YES];
    if (dateString) {
        self.createdDate = [[BMRecord creationDateFormatter] dateFromString:dateString];
    } else {
        self.createdDate = [NSDate date];
    }

    dateString = [self valueFromDictionary:hash key:SESSION_DATE destructive:YES];
    if (dateString) {
        self.sessionDate = [[BMRecord sessionDateFormatter] dateFromString:dateString];
    } else {
        self.sessionDate = [NSDate date];
    }

    // set defaults - if not set
    [self configure];
    
    // now create record item for each remaining key/pair
    // dynamically add remaining properties
    [hash enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BMRecordItem* newItem = [[BMRecordItem alloc] init];
        
        newItem.key = key;
        newItem.value = obj;

        [self addRecordItem:newItem];
    }];
}
// Private helper methods
- (BMRecordItem*)itemForKey:(NSString*)key
{
    BMRecordItem* tempItem = nil;
    for (BMRecordItem* item in self.items) {
        if ([key isEqualToString:item.key]) {
            tempItem = item;
            break;
        }
    }
    
    return tempItem;
}
- (BOOL)removeRecordItem:(BMRecordItem*)item
{
    BOOL deleted = NO;
    if (item) {
        [self.recordItems removeObject:item];
        deleted = YES;
    }
    
    return deleted;
}
- (id)valueFromDictionary:(NSMutableDictionary*)hash key:(NSString*)key destructive:(BOOL)destroy
{
    return [self valueFromDictionary:hash key:key destructive:destroy defaultValue:nil];
}
- (id)valueFromDictionary:(NSMutableDictionary*)hash key:(NSString*)key destructive:(BOOL)destroy defaultValue:(id)defaultValue
{
    id value = defaultValue;
    NSString* keyCheck;
    
    if ([hash objectForKeyOrNil:key]) {
        keyCheck = key;
    } else if ([hash objectForKeyOrNil:[key uppercaseString]]) {
        keyCheck = [key uppercaseString];
    } else if ([hash objectForKeyOrNil:[key lowercaseString]]) {
        keyCheck = [key lowercaseString];
    } else if ([hash objectForKeyOrNil:[key capitalizedString]]) {
        keyCheck = [key capitalizedString];
    }
    
    if (keyCheck) {
        value = [hash objectForKey:keyCheck];
        if (destroy) {
            [hash removeObjectForKey:keyCheck];
        }
    }
    
    return value;
}
- (NSString*)localeIdentifier {
    if (!self.language) {
        return nil;
    } else if (!self.country) {
        return self.language;
    } else {
        return [NSString stringWithFormat:@"%@_%@", self.language, self.country];
    }
}

// Private class helpers
+ (NSDateFormatter*)creationDateFormatter
{
    static NSDateFormatter* _creationDateFormatter;
    if (!_creationDateFormatter) {
        _creationDateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_creationDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [_creationDateFormatter setTimeZone:timeZone];
    }
    
    return _creationDateFormatter;
}
+ (NSDateFormatter*)sessionDateFormatter
{
    static NSDateFormatter* _sessionDateFormatter;
    if (!_sessionDateFormatter) {
        _sessionDateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_sessionDateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
        [_sessionDateFormatter setTimeZone:timeZone];
    }
    
    return _sessionDateFormatter;
}
@end
