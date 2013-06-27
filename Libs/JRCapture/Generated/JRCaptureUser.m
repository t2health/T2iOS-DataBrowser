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
#import "JRCaptureUser.h"

@interface JRPhotosElement (JRPhotosElement_InternalMethods)
+ (id)photosElementFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;
- (BOOL)isEqualToPhotosElement:(JRPhotosElement *)otherPhotosElement;
@end

@interface JRPrimaryAddress (JRPrimaryAddress_InternalMethods)
+ (id)primaryAddressObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;
- (BOOL)isEqualToPrimaryAddress:(JRPrimaryAddress *)otherPrimaryAddress;
@end

@interface JRProfilesElement (JRProfilesElement_InternalMethods)
+ (id)profilesElementFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;
- (BOOL)isEqualToProfilesElement:(JRProfilesElement *)otherProfilesElement;
@end

@interface JRStatusesElement (JRStatusesElement_InternalMethods)
+ (id)statusesElementFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder;
- (BOOL)isEqualToStatusesElement:(JRStatusesElement *)otherStatusesElement;
@end

@implementation NSArray (JRArray_Photos_ToFromDictionary)
- (NSArray*)arrayOfPhotosElementsFromPhotosDictionariesWithPath:(NSString*)capturePath fromDecoder:(BOOL)fromDecoder
{
    NSMutableArray *filteredPhotosArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *dictionary in self)
        if ([dictionary isKindOfClass:[NSDictionary class]])
            [filteredPhotosArray addObject:[JRPhotosElement photosElementFromDictionary:(NSDictionary*)dictionary withPath:capturePath fromDecoder:fromDecoder]];

    return filteredPhotosArray;
}

- (NSArray*)arrayOfPhotosElementsFromPhotosDictionariesWithPath:(NSString*)capturePath
{
    return [self arrayOfPhotosElementsFromPhotosDictionariesWithPath:capturePath fromDecoder:NO];
}

- (NSArray*)arrayOfPhotosDictionariesFromPhotosElementsForEncoder:(BOOL)forEncoder
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRPhotosElement class]])
            [filteredDictionaryArray addObject:[(JRPhotosElement*)object toDictionaryForEncoder:forEncoder]];

    return filteredDictionaryArray;
}

- (NSArray*)arrayOfPhotosDictionariesFromPhotosElements
{
    return [self arrayOfPhotosDictionariesFromPhotosElementsForEncoder:NO];
}

- (NSArray*)arrayOfPhotosReplaceDictionariesFromPhotosElements
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRPhotosElement class]])
            [filteredDictionaryArray addObject:[(JRPhotosElement*)object toReplaceDictionary]];

    return filteredDictionaryArray;
}
@end

@implementation NSArray (JRArray_Profiles_ToFromDictionary)
- (NSArray*)arrayOfProfilesElementsFromProfilesDictionariesWithPath:(NSString*)capturePath fromDecoder:(BOOL)fromDecoder
{
    NSMutableArray *filteredProfilesArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *dictionary in self)
        if ([dictionary isKindOfClass:[NSDictionary class]])
            [filteredProfilesArray addObject:[JRProfilesElement profilesElementFromDictionary:(NSDictionary*)dictionary withPath:capturePath fromDecoder:fromDecoder]];

    return filteredProfilesArray;
}

- (NSArray*)arrayOfProfilesElementsFromProfilesDictionariesWithPath:(NSString*)capturePath
{
    return [self arrayOfProfilesElementsFromProfilesDictionariesWithPath:capturePath fromDecoder:NO];
}

- (NSArray*)arrayOfProfilesDictionariesFromProfilesElementsForEncoder:(BOOL)forEncoder
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRProfilesElement class]])
            [filteredDictionaryArray addObject:[(JRProfilesElement*)object toDictionaryForEncoder:forEncoder]];

    return filteredDictionaryArray;
}

- (NSArray*)arrayOfProfilesDictionariesFromProfilesElements
{
    return [self arrayOfProfilesDictionariesFromProfilesElementsForEncoder:NO];
}

- (NSArray*)arrayOfProfilesReplaceDictionariesFromProfilesElements
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRProfilesElement class]])
            [filteredDictionaryArray addObject:[(JRProfilesElement*)object toReplaceDictionary]];

    return filteredDictionaryArray;
}
@end

@implementation NSArray (JRArray_Statuses_ToFromDictionary)
- (NSArray*)arrayOfStatusesElementsFromStatusesDictionariesWithPath:(NSString*)capturePath fromDecoder:(BOOL)fromDecoder
{
    NSMutableArray *filteredStatusesArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *dictionary in self)
        if ([dictionary isKindOfClass:[NSDictionary class]])
            [filteredStatusesArray addObject:[JRStatusesElement statusesElementFromDictionary:(NSDictionary*)dictionary withPath:capturePath fromDecoder:fromDecoder]];

    return filteredStatusesArray;
}

- (NSArray*)arrayOfStatusesElementsFromStatusesDictionariesWithPath:(NSString*)capturePath
{
    return [self arrayOfStatusesElementsFromStatusesDictionariesWithPath:capturePath fromDecoder:NO];
}

- (NSArray*)arrayOfStatusesDictionariesFromStatusesElementsForEncoder:(BOOL)forEncoder
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRStatusesElement class]])
            [filteredDictionaryArray addObject:[(JRStatusesElement*)object toDictionaryForEncoder:forEncoder]];

    return filteredDictionaryArray;
}

- (NSArray*)arrayOfStatusesDictionariesFromStatusesElements
{
    return [self arrayOfStatusesDictionariesFromStatusesElementsForEncoder:NO];
}

- (NSArray*)arrayOfStatusesReplaceDictionariesFromStatusesElements
{
    NSMutableArray *filteredDictionaryArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSObject *object in self)
        if ([object isKindOfClass:[JRStatusesElement class]])
            [filteredDictionaryArray addObject:[(JRStatusesElement*)object toReplaceDictionary]];

    return filteredDictionaryArray;
}
@end

@interface NSArray (CaptureUser_ArrayComparison)
- (BOOL)isEqualToPhotosArray:(NSArray *)otherArray;
- (BOOL)isEqualToProfilesArray:(NSArray *)otherArray;
- (BOOL)isEqualToStatusesArray:(NSArray *)otherArray;
@end

@implementation NSArray (CaptureUser_ArrayComparison)

- (BOOL)isEqualToPhotosArray:(NSArray *)otherArray
{
    if ([self count] != [otherArray count]) return NO;

    for (NSUInteger i = 0; i < [self count]; i++)
        if (![((JRPhotosElement *)[self objectAtIndex:i]) isEqualToPhotosElement:[otherArray objectAtIndex:i]])
            return NO;

    return YES;
}

- (BOOL)isEqualToProfilesArray:(NSArray *)otherArray
{
    if ([self count] != [otherArray count]) return NO;

    for (NSUInteger i = 0; i < [self count]; i++)
        if (![((JRProfilesElement *)[self objectAtIndex:i]) isEqualToProfilesElement:[otherArray objectAtIndex:i]])
            return NO;

    return YES;
}

- (BOOL)isEqualToStatusesArray:(NSArray *)otherArray
{
    if ([self count] != [otherArray count]) return NO;

    for (NSUInteger i = 0; i < [self count]; i++)
        if (![((JRStatusesElement *)[self objectAtIndex:i]) isEqualToStatusesElement:[otherArray objectAtIndex:i]])
            return NO;

    return YES;
}
@end

@interface JRCaptureUser ()
@property BOOL canBeUpdatedOnCapture;
@end

@implementation JRCaptureUser
{
    NSString *_aboutMe;
    JRDate *_birthday;
    NSString *_currentLocation;
    JRJsonObject *_display;
    NSString *_displayName;
    NSString *_email;
    JRDateTime *_emailVerified;
    NSString *_familyName;
    NSString *_gender;
    NSString *_givenName;
    JRDateTime *_lastLogin;
    NSString *_middleName;
    JRPassword *_password;
    NSArray *_photos;
    JRPrimaryAddress *_primaryAddress;
    NSArray *_profiles;
    NSArray *_statuses;
    JRDateTime *_created;
    JRDateTime *_lastUpdated;
    JRObjectId *_captureUserId;
    JRUuid *_uuid;
}
@synthesize canBeUpdatedOnCapture;

- (NSString *)aboutMe
{
    return _aboutMe;
}

- (void)setAboutMe:(NSString *)newAboutMe
{
    [self.dirtyPropertySet addObject:@"aboutMe"];

    [_aboutMe autorelease];
    _aboutMe = [newAboutMe copy];
}

- (JRDate *)birthday
{
    return _birthday;
}

- (void)setBirthday:(JRDate *)newBirthday
{
    [self.dirtyPropertySet addObject:@"birthday"];

    [_birthday autorelease];
    _birthday = [newBirthday copy];
}

- (NSString *)currentLocation
{
    return _currentLocation;
}

- (void)setCurrentLocation:(NSString *)newCurrentLocation
{
    [self.dirtyPropertySet addObject:@"currentLocation"];

    [_currentLocation autorelease];
    _currentLocation = [newCurrentLocation copy];
}

- (JRJsonObject *)display
{
    return _display;
}

- (void)setDisplay:(JRJsonObject *)newDisplay
{
    [self.dirtyPropertySet addObject:@"display"];

    [_display autorelease];
    _display = [newDisplay copy];
}

- (NSString *)displayName
{
    return _displayName;
}

- (void)setDisplayName:(NSString *)newDisplayName
{
    [self.dirtyPropertySet addObject:@"displayName"];

    [_displayName autorelease];
    _displayName = [newDisplayName copy];
}

- (NSString *)email
{
    return _email;
}

- (void)setEmail:(NSString *)newEmail
{
    [self.dirtyPropertySet addObject:@"email"];

    [_email autorelease];
    _email = [newEmail copy];
}

- (JRDateTime *)emailVerified
{
    return _emailVerified;
}

- (void)setEmailVerified:(JRDateTime *)newEmailVerified
{
    [self.dirtyPropertySet addObject:@"emailVerified"];

    [_emailVerified autorelease];
    _emailVerified = [newEmailVerified copy];
}

- (NSString *)familyName
{
    return _familyName;
}

- (void)setFamilyName:(NSString *)newFamilyName
{
    [self.dirtyPropertySet addObject:@"familyName"];

    [_familyName autorelease];
    _familyName = [newFamilyName copy];
}

- (NSString *)gender
{
    return _gender;
}

- (void)setGender:(NSString *)newGender
{
    [self.dirtyPropertySet addObject:@"gender"];

    [_gender autorelease];
    _gender = [newGender copy];
}

- (NSString *)givenName
{
    return _givenName;
}

- (void)setGivenName:(NSString *)newGivenName
{
    [self.dirtyPropertySet addObject:@"givenName"];

    [_givenName autorelease];
    _givenName = [newGivenName copy];
}

- (JRDateTime *)lastLogin
{
    return _lastLogin;
}

- (void)setLastLogin:(JRDateTime *)newLastLogin
{
    [self.dirtyPropertySet addObject:@"lastLogin"];

    [_lastLogin autorelease];
    _lastLogin = [newLastLogin copy];
}

- (NSString *)middleName
{
    return _middleName;
}

- (void)setMiddleName:(NSString *)newMiddleName
{
    [self.dirtyPropertySet addObject:@"middleName"];

    [_middleName autorelease];
    _middleName = [newMiddleName copy];
}

- (JRPassword *)password
{
    return _password;
}

- (void)setPassword:(JRPassword *)newPassword
{
    [self.dirtyPropertySet addObject:@"password"];

    [_password autorelease];
    _password = [newPassword copy];
}

- (NSArray *)photos
{
    return _photos;
}

- (void)setPhotos:(NSArray *)newPhotos
{
    [_photos autorelease];
    _photos = [newPhotos copy];
}

- (JRPrimaryAddress *)primaryAddress
{
    return _primaryAddress;
}

- (void)setPrimaryAddress:(JRPrimaryAddress *)newPrimaryAddress
{
    [self.dirtyPropertySet addObject:@"primaryAddress"];

    [_primaryAddress autorelease];
    _primaryAddress = [newPrimaryAddress retain];

    [_primaryAddress setAllPropertiesToDirty];
}

- (NSArray *)profiles
{
    return _profiles;
}

- (void)setProfiles:(NSArray *)newProfiles
{
    [_profiles autorelease];
    _profiles = [newProfiles copy];
}

- (NSArray *)statuses
{
    return _statuses;
}

- (void)setStatuses:(NSArray *)newStatuses
{
    [_statuses autorelease];
    _statuses = [newStatuses copy];
}

- (JRDateTime *)created
{
    return _created;
}

- (void)setCreated:(JRDateTime *)newCreated
{
    [self.dirtyPropertySet addObject:@"created"];

    [_created autorelease];
    _created = [newCreated copy];
}

- (JRDateTime *)lastUpdated
{
    return _lastUpdated;
}

- (void)setLastUpdated:(JRDateTime *)newLastUpdated
{
    [self.dirtyPropertySet addObject:@"lastUpdated"];

    [_lastUpdated autorelease];
    _lastUpdated = [newLastUpdated copy];
}

- (JRObjectId *)captureUserId
{
    return _captureUserId;
}

- (void)setCaptureUserId:(JRObjectId *)newCaptureUserId
{
    [self.dirtyPropertySet addObject:@"captureUserId"];

    [_captureUserId autorelease];
    _captureUserId = [newCaptureUserId copy];
}

- (JRUuid *)uuid
{
    return _uuid;
}

- (void)setUuid:(JRUuid *)newUuid
{
    [self.dirtyPropertySet addObject:@"uuid"];

    [_uuid autorelease];
    _uuid = [newUuid copy];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.captureObjectPath = @"";
        self.canBeUpdatedOnCapture = YES;

        _primaryAddress = [[JRPrimaryAddress alloc] init];

        [self.dirtyPropertySet setSet:[self updatablePropertySet]];
    }
    return self;
}

- (id)initWithEmail:(NSString *)newEmail
{
    if (!newEmail)
    {
        [self release];
        return nil;
     }

    if ((self = [super init]))
    {
        self.captureObjectPath = @"";
        self.canBeUpdatedOnCapture = YES;

        _email = [newEmail copy];
        _primaryAddress = [[JRPrimaryAddress alloc] init];
    
        [self.dirtyPropertySet setSet:[self updatablePropertySet]];
    }
    return self;
}

+ (id)captureUser
{
    return [[[JRCaptureUser alloc] init] autorelease];
}

+ (id)captureUserWithEmail:(NSString *)email
{
    return [[[JRCaptureUser alloc] initWithEmail:email] autorelease];
}

- (NSDictionary*)toDictionaryForEncoder:(BOOL)forEncoder
{
    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dictionary setObject:(self.aboutMe ? self.aboutMe : [NSNull null])
                   forKey:@"aboutMe"];
    [dictionary setObject:(self.birthday ? [self.birthday stringFromISO8601Date] : [NSNull null])
                   forKey:@"birthday"];
    [dictionary setObject:(self.currentLocation ? self.currentLocation : [NSNull null])
                   forKey:@"currentLocation"];
    [dictionary setObject:(self.display ? self.display : [NSNull null])
                   forKey:@"display"];
    [dictionary setObject:(self.displayName ? self.displayName : [NSNull null])
                   forKey:@"displayName"];
    [dictionary setObject:(self.email ? self.email : [NSNull null])
                   forKey:@"email"];
    [dictionary setObject:(self.emailVerified ? [self.emailVerified stringFromISO8601DateTime] : [NSNull null])
                   forKey:@"emailVerified"];
    [dictionary setObject:(self.familyName ? self.familyName : [NSNull null])
                   forKey:@"familyName"];
    [dictionary setObject:(self.gender ? self.gender : [NSNull null])
                   forKey:@"gender"];
    [dictionary setObject:(self.givenName ? self.givenName : [NSNull null])
                   forKey:@"givenName"];
    [dictionary setObject:(self.lastLogin ? [self.lastLogin stringFromISO8601DateTime] : [NSNull null])
                   forKey:@"lastLogin"];
    [dictionary setObject:(self.middleName ? self.middleName : [NSNull null])
                   forKey:@"middleName"];
    [dictionary setObject:(self.password ? self.password : [NSNull null])
                   forKey:@"password"];
    [dictionary setObject:(self.photos ? [self.photos arrayOfPhotosDictionariesFromPhotosElementsForEncoder:forEncoder] : [NSNull null])
                   forKey:@"photos"];
    [dictionary setObject:(self.primaryAddress ? [self.primaryAddress toDictionaryForEncoder:forEncoder] : [NSNull null])
                   forKey:@"primaryAddress"];
    [dictionary setObject:(self.profiles ? [self.profiles arrayOfProfilesDictionariesFromProfilesElementsForEncoder:forEncoder] : [NSNull null])
                   forKey:@"profiles"];
    [dictionary setObject:(self.statuses ? [self.statuses arrayOfStatusesDictionariesFromStatusesElementsForEncoder:forEncoder] : [NSNull null])
                   forKey:@"statuses"];
    [dictionary setObject:(self.created ? [self.created stringFromISO8601DateTime] : [NSNull null])
                   forKey:@"created"];
    [dictionary setObject:(self.lastUpdated ? [self.lastUpdated stringFromISO8601DateTime] : [NSNull null])
                   forKey:@"lastUpdated"];
    [dictionary setObject:(self.captureUserId ? [NSNumber numberWithInteger:[self.captureUserId integerValue]] : [NSNull null])
                   forKey:@"id"];
    [dictionary setObject:(self.uuid ? self.uuid : [NSNull null])
                   forKey:@"uuid"];

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

+ (id)captureUserObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath fromDecoder:(BOOL)fromDecoder
{
    if (!dictionary)
        return nil;

    JRCaptureUser *captureUser = [JRCaptureUser captureUser];

    NSSet *dirtyPropertySetCopy = nil;
    if (fromDecoder)
    {
        dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:@"dirtyPropertiesSet"]];
        captureUser.captureObjectPath = ([dictionary objectForKey:@"captureObjectPath"] == [NSNull null] ?
                                                              nil : [dictionary objectForKey:@"captureObjectPath"]);
    }

    captureUser.aboutMe =
        [dictionary objectForKey:@"aboutMe"] != [NSNull null] ? 
        [dictionary objectForKey:@"aboutMe"] : nil;

    captureUser.birthday =
        [dictionary objectForKey:@"birthday"] != [NSNull null] ? 
        [JRDate dateFromISO8601DateString:[dictionary objectForKey:@"birthday"]] : nil;

    captureUser.currentLocation =
        [dictionary objectForKey:@"currentLocation"] != [NSNull null] ? 
        [dictionary objectForKey:@"currentLocation"] : nil;

    captureUser.display =
        [dictionary objectForKey:@"display"] != [NSNull null] ? 
        [dictionary objectForKey:@"display"] : nil;

    captureUser.displayName =
        [dictionary objectForKey:@"displayName"] != [NSNull null] ? 
        [dictionary objectForKey:@"displayName"] : nil;

    captureUser.email =
        [dictionary objectForKey:@"email"] != [NSNull null] ? 
        [dictionary objectForKey:@"email"] : nil;

    captureUser.emailVerified =
        [dictionary objectForKey:@"emailVerified"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"emailVerified"]] : nil;

    captureUser.familyName =
        [dictionary objectForKey:@"familyName"] != [NSNull null] ? 
        [dictionary objectForKey:@"familyName"] : nil;

    captureUser.gender =
        [dictionary objectForKey:@"gender"] != [NSNull null] ? 
        [dictionary objectForKey:@"gender"] : nil;

    captureUser.givenName =
        [dictionary objectForKey:@"givenName"] != [NSNull null] ? 
        [dictionary objectForKey:@"givenName"] : nil;

    captureUser.lastLogin =
        [dictionary objectForKey:@"lastLogin"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastLogin"]] : nil;

    captureUser.middleName =
        [dictionary objectForKey:@"middleName"] != [NSNull null] ? 
        [dictionary objectForKey:@"middleName"] : nil;

    captureUser.password =
        [dictionary objectForKey:@"password"] != [NSNull null] ? 
        [dictionary objectForKey:@"password"] : nil;

    captureUser.photos =
        [dictionary objectForKey:@"photos"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"photos"] arrayOfPhotosElementsFromPhotosDictionariesWithPath:captureUser.captureObjectPath fromDecoder:fromDecoder] : nil;

    captureUser.primaryAddress =
        [dictionary objectForKey:@"primaryAddress"] != [NSNull null] ? 
        [JRPrimaryAddress primaryAddressObjectFromDictionary:[dictionary objectForKey:@"primaryAddress"] withPath:captureUser.captureObjectPath fromDecoder:fromDecoder] : nil;

    captureUser.profiles =
        [dictionary objectForKey:@"profiles"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"profiles"] arrayOfProfilesElementsFromProfilesDictionariesWithPath:captureUser.captureObjectPath fromDecoder:fromDecoder] : nil;

    captureUser.statuses =
        [dictionary objectForKey:@"statuses"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"statuses"] arrayOfStatusesElementsFromStatusesDictionariesWithPath:captureUser.captureObjectPath fromDecoder:fromDecoder] : nil;

    captureUser.created =
        [dictionary objectForKey:@"created"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"created"]] : nil;

    captureUser.lastUpdated =
        [dictionary objectForKey:@"lastUpdated"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastUpdated"]] : nil;

    captureUser.captureUserId =
        [dictionary objectForKey:@"id"] != [NSNull null] ? 
        [NSNumber numberWithInteger:[(NSNumber*)[dictionary objectForKey:@"id"] integerValue]] : nil;

    captureUser.uuid =
        [dictionary objectForKey:@"uuid"] != [NSNull null] ? 
        [dictionary objectForKey:@"uuid"] : nil;

    if (fromDecoder)
        [captureUser.dirtyPropertySet setSet:dirtyPropertySetCopy];
    else
        [captureUser.dirtyPropertySet removeAllObjects];
    
    return captureUser;
}

+ (id)captureUserObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    return [JRCaptureUser captureUserObjectFromDictionary:dictionary withPath:capturePath fromDecoder:NO];
}

- (void)decodeFromDictionary:(NSDictionary*)dictionary
{
    NSSet *dirtyPropertySetCopy = [NSSet setWithArray:[dictionary objectForKey:@"dirtyPropertiesSet"]];

    self.captureObjectPath = @"";
    self.canBeUpdatedOnCapture = YES;

    self.aboutMe =
        [dictionary objectForKey:@"aboutMe"] != [NSNull null] ? 
        [dictionary objectForKey:@"aboutMe"] : nil;

    self.birthday =
        [dictionary objectForKey:@"birthday"] != [NSNull null] ? 
        [JRDate dateFromISO8601DateString:[dictionary objectForKey:@"birthday"]] : nil;

    self.currentLocation =
        [dictionary objectForKey:@"currentLocation"] != [NSNull null] ? 
        [dictionary objectForKey:@"currentLocation"] : nil;

    self.display =
        [dictionary objectForKey:@"display"] != [NSNull null] ? 
        [dictionary objectForKey:@"display"] : nil;

    self.displayName =
        [dictionary objectForKey:@"displayName"] != [NSNull null] ? 
        [dictionary objectForKey:@"displayName"] : nil;

    self.email =
        [dictionary objectForKey:@"email"] != [NSNull null] ? 
        [dictionary objectForKey:@"email"] : nil;

    self.emailVerified =
        [dictionary objectForKey:@"emailVerified"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"emailVerified"]] : nil;

    self.familyName =
        [dictionary objectForKey:@"familyName"] != [NSNull null] ? 
        [dictionary objectForKey:@"familyName"] : nil;

    self.gender =
        [dictionary objectForKey:@"gender"] != [NSNull null] ? 
        [dictionary objectForKey:@"gender"] : nil;

    self.givenName =
        [dictionary objectForKey:@"givenName"] != [NSNull null] ? 
        [dictionary objectForKey:@"givenName"] : nil;

    self.lastLogin =
        [dictionary objectForKey:@"lastLogin"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastLogin"]] : nil;

    self.middleName =
        [dictionary objectForKey:@"middleName"] != [NSNull null] ? 
        [dictionary objectForKey:@"middleName"] : nil;

    self.password =
        [dictionary objectForKey:@"password"] != [NSNull null] ? 
        [dictionary objectForKey:@"password"] : nil;

    self.photos =
        [dictionary objectForKey:@"photos"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"photos"] arrayOfPhotosElementsFromPhotosDictionariesWithPath:self.captureObjectPath fromDecoder:YES] : nil;

    self.primaryAddress =
        [dictionary objectForKey:@"primaryAddress"] != [NSNull null] ? 
        [JRPrimaryAddress primaryAddressObjectFromDictionary:[dictionary objectForKey:@"primaryAddress"] withPath:self.captureObjectPath fromDecoder:YES] : nil;

    self.profiles =
        [dictionary objectForKey:@"profiles"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"profiles"] arrayOfProfilesElementsFromProfilesDictionariesWithPath:self.captureObjectPath fromDecoder:YES] : nil;

    self.statuses =
        [dictionary objectForKey:@"statuses"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"statuses"] arrayOfStatusesElementsFromStatusesDictionariesWithPath:self.captureObjectPath fromDecoder:YES] : nil;

    self.created =
        [dictionary objectForKey:@"created"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"created"]] : nil;

    self.lastUpdated =
        [dictionary objectForKey:@"lastUpdated"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastUpdated"]] : nil;

    self.captureUserId =
        [dictionary objectForKey:@"id"] != [NSNull null] ? 
        [NSNumber numberWithInteger:[(NSNumber*)[dictionary objectForKey:@"id"] integerValue]] : nil;

    self.uuid =
        [dictionary objectForKey:@"uuid"] != [NSNull null] ? 
        [dictionary objectForKey:@"uuid"] : nil;

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}

- (void)replaceFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOnCapture = YES;

    self.aboutMe =
        [dictionary objectForKey:@"aboutMe"] != [NSNull null] ? 
        [dictionary objectForKey:@"aboutMe"] : nil;

    self.birthday =
        [dictionary objectForKey:@"birthday"] != [NSNull null] ? 
        [JRDate dateFromISO8601DateString:[dictionary objectForKey:@"birthday"]] : nil;

    self.currentLocation =
        [dictionary objectForKey:@"currentLocation"] != [NSNull null] ? 
        [dictionary objectForKey:@"currentLocation"] : nil;

    self.display =
        [dictionary objectForKey:@"display"] != [NSNull null] ? 
        [dictionary objectForKey:@"display"] : nil;

    self.displayName =
        [dictionary objectForKey:@"displayName"] != [NSNull null] ? 
        [dictionary objectForKey:@"displayName"] : nil;

    self.email =
        [dictionary objectForKey:@"email"] != [NSNull null] ? 
        [dictionary objectForKey:@"email"] : nil;

    self.emailVerified =
        [dictionary objectForKey:@"emailVerified"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"emailVerified"]] : nil;

    self.familyName =
        [dictionary objectForKey:@"familyName"] != [NSNull null] ? 
        [dictionary objectForKey:@"familyName"] : nil;

    self.gender =
        [dictionary objectForKey:@"gender"] != [NSNull null] ? 
        [dictionary objectForKey:@"gender"] : nil;

    self.givenName =
        [dictionary objectForKey:@"givenName"] != [NSNull null] ? 
        [dictionary objectForKey:@"givenName"] : nil;

    self.lastLogin =
        [dictionary objectForKey:@"lastLogin"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastLogin"]] : nil;

    self.middleName =
        [dictionary objectForKey:@"middleName"] != [NSNull null] ? 
        [dictionary objectForKey:@"middleName"] : nil;

    self.password =
        [dictionary objectForKey:@"password"] != [NSNull null] ? 
        [dictionary objectForKey:@"password"] : nil;

    self.photos =
        [dictionary objectForKey:@"photos"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"photos"] arrayOfPhotosElementsFromPhotosDictionariesWithPath:self.captureObjectPath fromDecoder:NO] : nil;

    if (![dictionary objectForKey:@"primaryAddress"] || [dictionary objectForKey:@"primaryAddress"] == [NSNull null])
        self.primaryAddress = nil;
    else if (!self.primaryAddress)
        self.primaryAddress = [JRPrimaryAddress primaryAddressObjectFromDictionary:[dictionary objectForKey:@"primaryAddress"] withPath:self.captureObjectPath fromDecoder:NO];
    else
        [self.primaryAddress replaceFromDictionary:[dictionary objectForKey:@"primaryAddress"] withPath:self.captureObjectPath];

    self.profiles =
        [dictionary objectForKey:@"profiles"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"profiles"] arrayOfProfilesElementsFromProfilesDictionariesWithPath:self.captureObjectPath fromDecoder:NO] : nil;

    self.statuses =
        [dictionary objectForKey:@"statuses"] != [NSNull null] ? 
        [(NSArray*)[dictionary objectForKey:@"statuses"] arrayOfStatusesElementsFromStatusesDictionariesWithPath:self.captureObjectPath fromDecoder:NO] : nil;

    self.created =
        [dictionary objectForKey:@"created"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"created"]] : nil;

    self.lastUpdated =
        [dictionary objectForKey:@"lastUpdated"] != [NSNull null] ? 
        [JRDateTime dateFromISO8601DateTimeString:[dictionary objectForKey:@"lastUpdated"]] : nil;

    self.captureUserId =
        [dictionary objectForKey:@"id"] != [NSNull null] ? 
        [NSNumber numberWithInteger:[(NSNumber*)[dictionary objectForKey:@"id"] integerValue]] : nil;

    self.uuid =
        [dictionary objectForKey:@"uuid"] != [NSNull null] ? 
        [dictionary objectForKey:@"uuid"] : nil;

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}

- (NSSet *)updatablePropertySet
{
    return [NSSet setWithObjects:@"aboutMe", @"birthday", @"currentLocation", @"display", @"displayName", @"email", @"emailVerified", @"familyName", @"gender", @"givenName", @"lastLogin", @"middleName", @"password", @"primaryAddress", @"created", @"lastUpdated", @"captureUserId", @"uuid", nil];
}

- (void)setAllPropertiesToDirty
{
    [self.dirtyPropertySet addObjectsFromArray:[[self updatablePropertySet] allObjects]];

}

- (NSDictionary *)snapshotDictionaryFromDirtyPropertySet
{
    NSMutableDictionary *snapshotDictionary =
             [NSMutableDictionary dictionaryWithCapacity:10];

    [snapshotDictionary setObject:[[self.dirtyPropertySet copy] autorelease] forKey:@"captureUser"];

    if (self.primaryAddress)
        [snapshotDictionary setObject:[self.primaryAddress snapshotDictionaryFromDirtyPropertySet]
                               forKey:@"primaryAddress"];

    return [NSDictionary dictionaryWithDictionary:snapshotDictionary];
}

- (void)restoreDirtyPropertiesFromSnapshotDictionary:(NSDictionary *)snapshotDictionary
{
    if ([snapshotDictionary objectForKey:@"captureUser"])
        [self.dirtyPropertySet addObjectsFromArray:[[snapshotDictionary objectForKey:@"captureUser"] allObjects]];

    if ([snapshotDictionary objectForKey:@"primaryAddress"])
        [self.primaryAddress restoreDirtyPropertiesFromSnapshotDictionary:
                    [snapshotDictionary objectForKey:@"primaryAddress"]];

}

- (NSDictionary *)toUpdateDictionary
{
    NSMutableDictionary *dictionary =
         [NSMutableDictionary dictionaryWithCapacity:10];

    if ([self.dirtyPropertySet containsObject:@"aboutMe"])
        [dictionary setObject:(self.aboutMe ? self.aboutMe : [NSNull null]) forKey:@"aboutMe"];

    if ([self.dirtyPropertySet containsObject:@"birthday"])
        [dictionary setObject:(self.birthday ? [self.birthday stringFromISO8601Date] : [NSNull null]) forKey:@"birthday"];

    if ([self.dirtyPropertySet containsObject:@"currentLocation"])
        [dictionary setObject:(self.currentLocation ? self.currentLocation : [NSNull null]) forKey:@"currentLocation"];

    if ([self.dirtyPropertySet containsObject:@"display"])
        [dictionary setObject:(self.display ? self.display : [NSNull null]) forKey:@"display"];

    if ([self.dirtyPropertySet containsObject:@"displayName"])
        [dictionary setObject:(self.displayName ? self.displayName : [NSNull null]) forKey:@"displayName"];

    if ([self.dirtyPropertySet containsObject:@"email"])
        [dictionary setObject:(self.email ? self.email : [NSNull null]) forKey:@"email"];

    if ([self.dirtyPropertySet containsObject:@"emailVerified"])
        [dictionary setObject:(self.emailVerified ? [self.emailVerified stringFromISO8601DateTime] : [NSNull null]) forKey:@"emailVerified"];

    if ([self.dirtyPropertySet containsObject:@"familyName"])
        [dictionary setObject:(self.familyName ? self.familyName : [NSNull null]) forKey:@"familyName"];

    if ([self.dirtyPropertySet containsObject:@"gender"])
        [dictionary setObject:(self.gender ? self.gender : [NSNull null]) forKey:@"gender"];

    if ([self.dirtyPropertySet containsObject:@"givenName"])
        [dictionary setObject:(self.givenName ? self.givenName : [NSNull null]) forKey:@"givenName"];

    if ([self.dirtyPropertySet containsObject:@"lastLogin"])
        [dictionary setObject:(self.lastLogin ? [self.lastLogin stringFromISO8601DateTime] : [NSNull null]) forKey:@"lastLogin"];

    if ([self.dirtyPropertySet containsObject:@"middleName"])
        [dictionary setObject:(self.middleName ? self.middleName : [NSNull null]) forKey:@"middleName"];

    if ([self.dirtyPropertySet containsObject:@"password"])
        [dictionary setObject:(self.password ? self.password : [NSNull null]) forKey:@"password"];

    if ([self.dirtyPropertySet containsObject:@"primaryAddress"])
        [dictionary setObject:(self.primaryAddress ?
                              [self.primaryAddress toUpdateDictionary] :
                              [[JRPrimaryAddress primaryAddress] toUpdateDictionary]) /* Use the default constructor to create an empty object */
                       forKey:@"primaryAddress"];
    else if ([self.primaryAddress needsUpdate])
        [dictionary setObject:[self.primaryAddress toUpdateDictionary]
                       forKey:@"primaryAddress"];

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

    [dictionary setObject:(self.aboutMe ? self.aboutMe : [NSNull null]) forKey:@"aboutMe"];
    [dictionary setObject:(self.birthday ? [self.birthday stringFromISO8601Date] : [NSNull null]) forKey:@"birthday"];
    [dictionary setObject:(self.currentLocation ? self.currentLocation : [NSNull null]) forKey:@"currentLocation"];
    [dictionary setObject:(self.display ? self.display : [NSNull null]) forKey:@"display"];
    [dictionary setObject:(self.displayName ? self.displayName : [NSNull null]) forKey:@"displayName"];
    [dictionary setObject:(self.email ? self.email : [NSNull null]) forKey:@"email"];
    [dictionary setObject:(self.emailVerified ? [self.emailVerified stringFromISO8601DateTime] : [NSNull null]) forKey:@"emailVerified"];
    [dictionary setObject:(self.familyName ? self.familyName : [NSNull null]) forKey:@"familyName"];
    [dictionary setObject:(self.gender ? self.gender : [NSNull null]) forKey:@"gender"];
    [dictionary setObject:(self.givenName ? self.givenName : [NSNull null]) forKey:@"givenName"];
    [dictionary setObject:(self.lastLogin ? [self.lastLogin stringFromISO8601DateTime] : [NSNull null]) forKey:@"lastLogin"];
    [dictionary setObject:(self.middleName ? self.middleName : [NSNull null]) forKey:@"middleName"];
    [dictionary setObject:(self.password ? self.password : [NSNull null]) forKey:@"password"];

    [dictionary setObject:(self.photos ?
                          [self.photos arrayOfPhotosReplaceDictionariesFromPhotosElements] :
                          [NSArray array])
                   forKey:@"photos"];

    [dictionary setObject:(self.primaryAddress ?
                          [self.primaryAddress toReplaceDictionary] :
                          [[JRPrimaryAddress primaryAddress] toUpdateDictionary]) /* Use the default constructor to create an empty object */
                   forKey:@"primaryAddress"];

    [dictionary setObject:(self.profiles ?
                          [self.profiles arrayOfProfilesReplaceDictionariesFromProfilesElements] :
                          [NSArray array])
                   forKey:@"profiles"];

    [dictionary setObject:(self.statuses ?
                          [self.statuses arrayOfStatusesReplaceDictionariesFromStatusesElements] :
                          [NSArray array])
                   forKey:@"statuses"];

    [self.dirtyPropertySet removeAllObjects];
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)replacePhotosArrayOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context
{
    [self replaceArrayOnCapture:self.photos named:@"photos" isArrayOfStrings:NO
                       withType:@"" forDelegate:delegate withContext:context];
}

- (void)replaceProfilesArrayOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context
{
    [self replaceArrayOnCapture:self.profiles named:@"profiles" isArrayOfStrings:NO
                       withType:@"" forDelegate:delegate withContext:context];
}

- (void)replaceStatusesArrayOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate context:(NSObject *)context
{
    [self replaceArrayOnCapture:self.statuses named:@"statuses" isArrayOfStrings:NO
                       withType:@"" forDelegate:delegate withContext:context];
}

- (BOOL)needsUpdate
{
    if ([self.dirtyPropertySet count])
         return YES;

    if ([self.primaryAddress needsUpdate])
        return YES;

    return NO;
}

- (BOOL)isEqualToCaptureUser:(JRCaptureUser *)otherCaptureUser
{
    if (!self.aboutMe && !otherCaptureUser.aboutMe) /* Keep going... */;
    else if ((self.aboutMe == nil) ^ (otherCaptureUser.aboutMe == nil)) return NO; // xor
    else if (![self.aboutMe isEqualToString:otherCaptureUser.aboutMe]) return NO;

    if (!self.birthday && !otherCaptureUser.birthday) /* Keep going... */;
    else if ((self.birthday == nil) ^ (otherCaptureUser.birthday == nil)) return NO; // xor
    else if (![self.birthday isEqualToDate:otherCaptureUser.birthday]) return NO;

    if (!self.currentLocation && !otherCaptureUser.currentLocation) /* Keep going... */;
    else if ((self.currentLocation == nil) ^ (otherCaptureUser.currentLocation == nil)) return NO; // xor
    else if (![self.currentLocation isEqualToString:otherCaptureUser.currentLocation]) return NO;

    if (!self.display && !otherCaptureUser.display) /* Keep going... */;
    else if ((self.display == nil) ^ (otherCaptureUser.display == nil)) return NO; // xor
    else if (![self.display isEqual:otherCaptureUser.display]) return NO;

    if (!self.displayName && !otherCaptureUser.displayName) /* Keep going... */;
    else if ((self.displayName == nil) ^ (otherCaptureUser.displayName == nil)) return NO; // xor
    else if (![self.displayName isEqualToString:otherCaptureUser.displayName]) return NO;

    if (!self.email && !otherCaptureUser.email) /* Keep going... */;
    else if ((self.email == nil) ^ (otherCaptureUser.email == nil)) return NO; // xor
    else if (![self.email isEqualToString:otherCaptureUser.email]) return NO;

    if (!self.emailVerified && !otherCaptureUser.emailVerified) /* Keep going... */;
    else if ((self.emailVerified == nil) ^ (otherCaptureUser.emailVerified == nil)) return NO; // xor
    else if (![self.emailVerified isEqualToDate:otherCaptureUser.emailVerified]) return NO;

    if (!self.familyName && !otherCaptureUser.familyName) /* Keep going... */;
    else if ((self.familyName == nil) ^ (otherCaptureUser.familyName == nil)) return NO; // xor
    else if (![self.familyName isEqualToString:otherCaptureUser.familyName]) return NO;

    if (!self.gender && !otherCaptureUser.gender) /* Keep going... */;
    else if ((self.gender == nil) ^ (otherCaptureUser.gender == nil)) return NO; // xor
    else if (![self.gender isEqualToString:otherCaptureUser.gender]) return NO;

    if (!self.givenName && !otherCaptureUser.givenName) /* Keep going... */;
    else if ((self.givenName == nil) ^ (otherCaptureUser.givenName == nil)) return NO; // xor
    else if (![self.givenName isEqualToString:otherCaptureUser.givenName]) return NO;

    if (!self.lastLogin && !otherCaptureUser.lastLogin) /* Keep going... */;
    else if ((self.lastLogin == nil) ^ (otherCaptureUser.lastLogin == nil)) return NO; // xor
    else if (![self.lastLogin isEqualToDate:otherCaptureUser.lastLogin]) return NO;

    if (!self.middleName && !otherCaptureUser.middleName) /* Keep going... */;
    else if ((self.middleName == nil) ^ (otherCaptureUser.middleName == nil)) return NO; // xor
    else if (![self.middleName isEqualToString:otherCaptureUser.middleName]) return NO;

    if (!self.password && !otherCaptureUser.password) /* Keep going... */;
    else if ((self.password == nil) ^ (otherCaptureUser.password == nil)) return NO; // xor
    else if (![self.password isEqual:otherCaptureUser.password]) return NO;

    if (!self.photos && !otherCaptureUser.photos) /* Keep going... */;
    else if (!self.photos && ![otherCaptureUser.photos count]) /* Keep going... */;
    else if (!otherCaptureUser.photos && ![self.photos count]) /* Keep going... */;
    else if (![self.photos isEqualToPhotosArray:otherCaptureUser.photos]) return NO;

    if (!self.primaryAddress && !otherCaptureUser.primaryAddress) /* Keep going... */;
    else if (!self.primaryAddress && [otherCaptureUser.primaryAddress isEqualToPrimaryAddress:[JRPrimaryAddress primaryAddress]]) /* Keep going... */;
    else if (!otherCaptureUser.primaryAddress && [self.primaryAddress isEqualToPrimaryAddress:[JRPrimaryAddress primaryAddress]]) /* Keep going... */;
    else if (![self.primaryAddress isEqualToPrimaryAddress:otherCaptureUser.primaryAddress]) return NO;

    if (!self.profiles && !otherCaptureUser.profiles) /* Keep going... */;
    else if (!self.profiles && ![otherCaptureUser.profiles count]) /* Keep going... */;
    else if (!otherCaptureUser.profiles && ![self.profiles count]) /* Keep going... */;
    else if (![self.profiles isEqualToProfilesArray:otherCaptureUser.profiles]) return NO;

    if (!self.statuses && !otherCaptureUser.statuses) /* Keep going... */;
    else if (!self.statuses && ![otherCaptureUser.statuses count]) /* Keep going... */;
    else if (!otherCaptureUser.statuses && ![self.statuses count]) /* Keep going... */;
    else if (![self.statuses isEqualToStatusesArray:otherCaptureUser.statuses]) return NO;

    return YES;
}

- (NSDictionary*)objectProperties
{
    NSMutableDictionary *dictionary = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dictionary setObject:@"NSString" forKey:@"aboutMe"];
    [dictionary setObject:@"JRDate" forKey:@"birthday"];
    [dictionary setObject:@"NSString" forKey:@"currentLocation"];
    [dictionary setObject:@"JRJsonObject" forKey:@"display"];
    [dictionary setObject:@"NSString" forKey:@"displayName"];
    [dictionary setObject:@"NSString" forKey:@"email"];
    [dictionary setObject:@"JRDateTime" forKey:@"emailVerified"];
    [dictionary setObject:@"NSString" forKey:@"familyName"];
    [dictionary setObject:@"NSString" forKey:@"gender"];
    [dictionary setObject:@"NSString" forKey:@"givenName"];
    [dictionary setObject:@"JRDateTime" forKey:@"lastLogin"];
    [dictionary setObject:@"NSString" forKey:@"middleName"];
    [dictionary setObject:@"JRPassword" forKey:@"password"];
    [dictionary setObject:@"NSArray" forKey:@"photos"];
    [dictionary setObject:@"JRPrimaryAddress" forKey:@"primaryAddress"];
    [dictionary setObject:@"NSArray" forKey:@"profiles"];
    [dictionary setObject:@"NSArray" forKey:@"statuses"];
    [dictionary setObject:@"JRDateTime" forKey:@"created"];
    [dictionary setObject:@"JRDateTime" forKey:@"lastUpdated"];
    [dictionary setObject:@"JRObjectId" forKey:@"captureUserId"];
    [dictionary setObject:@"JRUuid" forKey:@"uuid"];

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)dealloc
{
    [_aboutMe release];
    [_birthday release];
    [_currentLocation release];
    [_display release];
    [_displayName release];
    [_email release];
    [_emailVerified release];
    [_familyName release];
    [_gender release];
    [_givenName release];
    [_lastLogin release];
    [_middleName release];
    [_password release];
    [_photos release];
    [_primaryAddress release];
    [_profiles release];
    [_statuses release];
    [_created release];
    [_lastUpdated release];
    [_captureUserId release];
    [_uuid release];

    [super dealloc];
}
@end
