
#import <Foundation/Foundation.h>

@interface Factory : NSObject

+ (NSArray *)tokenFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)userProfileFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)stroriesFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)addKidFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)friendStatusFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)frindsListFromJSON:(NSDictionary *)parsedObject;
+ (NSMutableArray *)friendsInviteFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)profilesListFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)tasksFromJSON:(NSDictionary *)parsedObject;
+ (NSArray *)responseFromJSON:(NSDictionary *)parsedObject;
@end
