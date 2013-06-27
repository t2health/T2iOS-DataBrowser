#import "BMRecordItem.h"


@interface BMRecordItem ()

// Private interface goes here.

@end


@implementation BMRecordItem

- (NSString*)description
{
    if ([self.value isKindOfClass:[NSArray class]]) {
        return [self.value componentsJoinedByString:@", "];
    } else {
        return [self.value description];
    }
}

@end
