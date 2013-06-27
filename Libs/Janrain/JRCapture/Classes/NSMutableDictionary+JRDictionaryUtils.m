//
// Created by Nathan2 on 6/12/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSMutableDictionary+JRDictionaryUtils.h"


@implementation NSMutableDictionary (JRDictionaryUtils)
- (void)JR_maybeSetObject:(id)o forKey:(id <NSCopying>)key
{
    if (o) [self setObject:o forKey:key];

}
@end