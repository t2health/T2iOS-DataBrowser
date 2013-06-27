/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


#import "JRCaptureObject+Internal.h"
#import "JRObjectLevelTwo.h"

@interface JRObjectLevelThree (JRObjectLevelThree_InternalMethods)
+ (id)objectLevelThreeObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;
- (BOOL)isEqualToObjectLevelThree:(JRObjectLevelThree *)otherObjectLevelThree;
@end

@interface JRObjectLevelTwo ()
@property BOOL canBeUpdatedOnCapture;
@end

@implementation JRObjectLevelTwo
{
    NSString *_level;
    NSString *_name;
    JRObjectLevelThree *_objectLevelThree;
}
@synthesize canBeUpdatedOnCapture;

- (NSString *)level
{
    return _level;
}

- (void)setLevel:(NSString *)newLevel
{
    [self.dirtyPropertySet addObject:@"level"];

    [_level autorelease];
    _level = [newLevel copy];
}

- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)newName
{
    [self.dirtyPropertySet addObject:@"name"];

    [_name autorelease];
    _name = [newName copy];
}

- (JRObjectLevelThree *)objectLevelThree
{
    return _objectLevelThree;
}

- (void)setObjectLevelThree:(JRObjectLevelThree *)newObjectLevelThree
{
    [self.dirtyPropertySet addObject:@"objectLevelThree"];

    [_objectLevelThree autorelease];
    _objectLevelThree = [newObjectLevelThree retain];

    [_objectLevelThree setAllPropertiesToDirty];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.captureObjectPath = @"/objectLevelOne/objectLevelTwo";
        self.canBeUpdatedOnCapture = YES;

        _objectLevelThree = [[JRObjectLevelThree alloc] init];

        [self.dirtyPropertySet setSet:[self updatablePropertySet]];
    }
    return self;
}

+ (id)objectLevelTwo
{
    return [[[JRObjectLevelTwo alloc] init] autorelease];
}

- (NSDictionary*)toDictionaryForEncoder:(BOOL)forEncoder
{
    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dictionary setObject:(self.level ? self.level : [NSNull null])
                   forKey:@"level"];
    [dictionary setObject:(self.name ? self.name : [NSNull null])
                   forKey:@"name"];
    [dictionary setObject:(self.objectLevelThree ? [self.objectLevelThree toDictionaryForEncoder:forEncoder] : [NSNull null])
                   forKey:@"objectLevelThree"];

    if (forEncoder)
    {
        [dictionary setObject:([self.dirtyPropertySet allObjects] ? [self.dirtyPropertySet allObjects] : [NSArray array])
                       forKey:@"dirtyPropertiesSet"];
        [dictionary setObject:(self.captureObjectPath ? self.captureObjectPath : [NSNull null])
                       forKey:@"captureObjectPath"];
        [dictionary setObject:[NSNumber numberWithBool:self.canBeUpdatedOnCapture] 
                       forKey:@"canBeUpdatedOnCapture"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

+ (id)objectLevelTwoObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder
{
    if (!dictionary)
        return nil;

    JRObjectLevelTwo *objectLevelTwo = [JRObjectLevelTwo objectLevelTwo];

    NSSet *dirtyPropertySetCopy = nil;
    if (fromDecoder)
    {
        dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:@"dirtyPropertiesSet"]];
        objectLevelTwo.captureObjectPath = ([dictionary objectForKey:@"captureObjectPath"] == [NSNull null] ?
                                                              nil : [dictionary objectForKey:@"captureObjectPath"]);
    }

    objectLevelTwo.level =
        [dictionary objectForKey:@"level"] != [NSNull null] ? 
        [dictionary objectForKey:@"level"] : nil;

    objectLevelTwo.name =
        [dictionary objectForKey:@"name"] != [NSNull null] ? 
        [dictionary objectForKey:@"name"] : nil;

    objectLevelTwo.objectLevelThree =
        [dictionary objectForKey:@"objectLevelThree"] != [NSNull null] ? 
        [JRObjectLevelThree objectLevelThreeObjectFromDictionary:[dictionary objectForKey:@"objectLevelThree"] withPath:objectLevelTwo.captureObjectPath fromDecoder:fromDecoder] : nil;

    if (fromDecoder)
        [objectLevelTwo.dirtyPropertySet setSet:dirtyPropertySetCopy];
    else
        [objectLevelTwo.dirtyPropertySet removeAllObjects];
    
    return objectLevelTwo;
}

+ (id)objectLevelTwoObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    return [JRObjectLevelTwo objectLevelTwoObjectFromDictionary:dictionary withPath:capturePath fromDecoder:NO];
}

- (void)replaceFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOnCapture = YES;

    self.level =
        [dictionary objectForKey:@"level"] != [NSNull null] ? 
        [dictionary objectForKey:@"level"] : nil;

    self.name =
        [dictionary objectForKey:@"name"] != [NSNull null] ? 
        [dictionary objectForKey:@"name"] : nil;

    if (![dictionary objectForKey:@"objectLevelThree"] || [dictionary objectForKey:@"objectLevelThree"] == [NSNull null])
        self.objectLevelThree = nil;
    else if (!self.objectLevelThree)
        self.objectLevelThree = [JRObjectLevelThree objectLevelThreeObjectFromDictionary:[dictionary objectForKey:@"objectLevelThree"] withPath:self.captureObjectPath fromDecoder:NO];
    else
        [self.objectLevelThree replaceFromDictionary:[dictionary objectForKey:@"objectLevelThree"] withPath:self.captureObjectPath];

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}

- (NSSet *)updatablePropertySet
{
    return [NSSet setWithObjects:@"level", @"name", @"objectLevelThree", nil];
}

- (void)setAllPropertiesToDirty
{
    [self.dirtyPropertySet addObjectsFromArray:[[self updatablePropertySet] allObjects]];

}

- (NSDictionary *)snapshotDictionaryFromDirtyPropertySet
{
    NSMutableDictionary *snapshotDictionary =
             [NSMutableDictionary dictionaryWithCapacity:10];

    [snapshotDictionary setObject:[[self.dirtyPropertySet copy] autorelease] forKey:@"objectLevelTwo"];

    if (self.objectLevelThree)
        [snapshotDictionary setObject:[self.objectLevelThree snapshotDictionaryFromDirtyPropertySet]
                               forKey:@"objectLevelThree"];

    return [NSDictionary dictionaryWithDictionary:snapshotDictionary];
}

- (void)restoreDirtyPropertiesFromSnapshotDictionary:(NSDictionary *)snapshotDictionary
{
    if ([snapshotDictionary objectForKey:@"objectLevelTwo"])
        [self.dirtyPropertySet addObjectsFromArray:[[snapshotDictionary objectForKey:@"objectLevelTwo"] allObjects]];

    if ([snapshotDictionary objectForKey:@"objectLevelThree"])
        [self.objectLevelThree restoreDirtyPropertiesFromSnapshotDictionary:
                    [snapshotDictionary objectForKey:@"objectLevelThree"]];

}

- (NSDictionary *)toUpdateDictionary
{
    NSMutableDictionary *dictionary =
         [NSMutableDictionary dictionaryWithCapacity:10];

    if ([self.dirtyPropertySet containsObject:@"level"])
        [dictionary setObject:(self.level ? self.level : [NSNull null]) forKey:@"level"];

    if ([self.dirtyPropertySet containsObject:@"name"])
        [dictionary setObject:(self.name ? self.name : [NSNull null]) forKey:@"name"];

    if ([self.dirtyPropertySet containsObject:@"objectLevelThree"])
        [dictionary setObject:(self.objectLevelThree ?
                              [self.objectLevelThree toUpdateDictionary] :
                              [[JRObjectLevelThree objectLevelThree] toUpdateDictionary]) /* Use the default constructor to create an empty object */
                       forKey:@"objectLevelThree"];
    else if ([self.objectLevelThree needsUpdate])
        [dictionary setObject:[self.objectLevelThree toUpdateDictionary]
                       forKey:@"objectLevelThree"];

    [self.dirtyPropertySet removeAllObjects];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)updateOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context
{
    [super updateOnCaptureForDelegate:delegate context:context];
}

- (NSDictionary *)toReplaceDictionary
{
    NSMutableDictionary *dictionary =
         [NSMutableDictionary dictionaryWithCapacity:10];

    [dictionary setObject:(self.level ? self.level : [NSNull null]) forKey:@"level"];
    [dictionary setObject:(self.name ? self.name : [NSNull null]) forKey:@"name"];

    [dictionary setObject:(self.objectLevelThree ?
                          [self.objectLevelThree toReplaceDictionary] :
                          [[JRObjectLevelThree objectLevelThree] toUpdateDictionary]) /* Use the default constructor to create an empty object */
                   forKey:@"objectLevelThree"];

    [self.dirtyPropertySet removeAllObjects];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (BOOL)needsUpdate
{
    if ([self.dirtyPropertySet count])
         return YES;

    if ([self.objectLevelThree needsUpdate])
        return YES;

    return NO;
}

- (BOOL)isEqualToObjectLevelTwo:(JRObjectLevelTwo *)otherObjectLevelTwo
{
    if (!self.level && !otherObjectLevelTwo.level) /* Keep going... */;
    else if ((self.level == nil) ^ (otherObjectLevelTwo.level == nil)) return NO; // xor
    else if (![self.level isEqualToString:otherObjectLevelTwo.level]) return NO;

    if (!self.name && !otherObjectLevelTwo.name) /* Keep going... */;
    else if ((self.name == nil) ^ (otherObjectLevelTwo.name == nil)) return NO; // xor
    else if (![self.name isEqualToString:otherObjectLevelTwo.name]) return NO;

    if (!self.objectLevelThree && !otherObjectLevelTwo.objectLevelThree) /* Keep going... */;
    else if (!self.objectLevelThree && [otherObjectLevelTwo.objectLevelThree isEqualToObjectLevelThree:[JRObjectLevelThree objectLevelThree]]) /* Keep going... */;
    else if (!otherObjectLevelTwo.objectLevelThree && [self.objectLevelThree isEqualToObjectLevelThree:[JRObjectLevelThree objectLevelThree]]) /* Keep going... */;
    else if (![self.objectLevelThree isEqualToObjectLevelThree:otherObjectLevelTwo.objectLevelThree]) return NO;

    return YES;
}

- (NSDictionary*)objectProperties
{
    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dictionary setObject:@"NSString" forKey:@"level"];
    [dictionary setObject:@"NSString" forKey:@"name"];
    [dictionary setObject:@"JRObjectLevelThree" forKey:@"objectLevelThree"];

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)dealloc
{
    [_level release];
    [_name release];
    [_objectLevelThree release];

    [super dealloc];
}
@end
