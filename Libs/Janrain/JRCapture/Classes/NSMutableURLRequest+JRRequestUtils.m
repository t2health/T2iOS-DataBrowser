//
// Created by Nathan2 on 6/12/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSMutableURLRequest+JRRequestUtils.h"
#import "NSDictionary+JRQueryParams.h"
#import "debug_log.h"

@implementation NSMutableURLRequest (JRRequestUtils)
- (void)JR_setBodyWithParams:(NSDictionary *)dictionary
{
    [self setHTTPMethod:@"POST"];
    NSString *paramString = [dictionary asJRURLParamString];
    DLog(@"Adding params to %@: %@", self, paramString);
    [self setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
}
@end