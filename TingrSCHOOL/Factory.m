
#import "Factory.h"
#import "VOAccessToken.h"
#import "VOProfilesList.h"
@implementation Factory

+ (NSArray *)tokenFromJSON:(NSDictionary *)parsedObject 
{
    parsedObject = [parsedObject objectForKey:@"response"];
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    AccessToken *token = [[AccessToken alloc] init];
        
        for (NSString *key in parsedObject)
        {
            if ([token respondsToSelector:NSSelectorFromString(key)]) {
                
                [token setValue:[parsedObject valueForKey:key] forKey:key];
            }
        }
        
        [tokens addObject:token];
  [[NSUserDefaults standardUserDefaults] setObject:parsedObject forKey:@"tokens"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        return tokens;
}

+ (NSArray *)userProfileFromJSON:(NSDictionary *)parsedObject
{
    
    NSNumber *zipCodeResponseStatus = [parsedObject valueForKey:@"status"];
    NSString *zipCodestringStatus = [NSString stringWithFormat:@"%@",[zipCodeResponseStatus stringValue]];
    
    NSMutableArray *profiles = [[NSMutableArray alloc]init];
    UserProfile *userProfile = [[UserProfile alloc] init];
    ModelManager *sharedModel = [ModelManager sharedModel];
    
    if ([zipCodestringStatus isEqualToString:@"200"])
    {
        DebugLog(@"%@",[parsedObject valueForKey:@"body"]);
        
        // Assign fb enable status to the singleton object
        [[SingletonClass sharedInstance]setIsFBShareEnabled:[[[parsedObject valueForKey:@"body"] valueForKey:@"fb"] boolValue]];
        

        userProfile.auth_token   = [[parsedObject valueForKey:@"body"] valueForKey:@"auth_token"];
        userProfile.onboarding   = [[[parsedObject valueForKey:@"body"] valueForKey:@"onboarding"] boolValue];
        NSDictionary *dic = [parsedObject valueForKey:@"body"];
        userProfile.teacher_klid = [dic valueForKey:@"teacher_klid"];
        userProfile.photograph = [dic valueForKey:@"photograph"];
        userProfile.org_logo = [dic valueForKey:@"org_logo"];
        userProfile.fname = [dic valueForKey:@"fname"];
        userProfile.lname = [dic valueForKey:@"lname"];
        userProfile.email = [dic valueForKey:@"email"];
        userProfile.rooms = [dic valueForKey:@"rooms"];
        sharedModel.userProfile = userProfile;
        [profiles addObject:userProfile];
        [[NSUserDefaults standardUserDefaults] setObject:parsedObject forKey:@"userProfile"];
        
    }
    else if ([zipCodestringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    
    
    return profiles;
}
+ (NSArray *)stroriesFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *completeRegistrationStatus = [parsedObject valueForKey:@"status"];
    NSString *completeRegistrationStringStatus = [NSString stringWithFormat:@"%@",[completeRegistrationStatus stringValue]];
    
    NSMutableArray *streamArray = [[NSMutableArray alloc]init];
    if ([completeRegistrationStringStatus isEqualToString:@"200"])
    {
        [streamArray addObject:[parsedObject valueForKey:@"body"]];
        
        // Assign fb enable status to the singleton object
        //[[SingletonClass sharedInstance]setIsFBShareEnabled:[[[parsedObject valueForKey:@"body"] valueForKey:@"fb"] boolValue]];
    }
    else if ([completeRegistrationStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return streamArray;

}
+ (NSArray *)addKidFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *milestonesStatus = [parsedObject valueForKey:@"status"];
    NSString *milestonesStringStatus = [NSString stringWithFormat:@"%@",[milestonesStatus stringValue]];
    
    NSMutableArray *kids = [[NSMutableArray alloc]init];
    if ([milestonesStringStatus isEqualToString:@"200"])
    {
        [kids addObject:parsedObject];
    }
    else if ([milestonesStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return kids;
}

+ (NSArray *)friendStatusFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *milestonesStatus = [parsedObject valueForKey:@"status"];
    NSString *milestonesStringStatus = [NSString stringWithFormat:@"%@",[milestonesStatus stringValue]];
    
    NSMutableArray *milestonesArray = [[NSMutableArray alloc]init];
    if ([milestonesStringStatus isEqualToString:@"200"])
    {
        
    }
    else if ([milestonesStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    
    return milestonesArray;
}
+ (NSArray *)frindsListFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *returnStatus = [parsedObject valueForKey:@"status"];
    NSString *returnStringStatus = [NSString stringWithFormat:@"%@",[returnStatus stringValue]];
    
    NSMutableArray *friendsArray = [[NSMutableArray alloc]init];
    if ([returnStringStatus isEqualToString:@"200"])
    {
        [friendsArray addObject:[parsedObject valueForKey:@"body"]];
    }
    else if ([returnStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return friendsArray;
}
+ (NSMutableArray *)friendsInviteFromJSON:(NSDictionary *)parsedObject
{
    NSMutableArray *inviteArray = [[NSMutableArray alloc]init];
    
    [inviteArray addObject:[parsedObject valueForKey:@"body"]];
    
    return inviteArray;
}


+ (NSArray *)profilesListFromJSON:(NSDictionary *)parsedObject
{
    NSMutableDictionary *profilesListResponse = [parsedObject valueForKey:@"body"];
    NSMutableArray *profiles    = [[NSMutableArray alloc] init];
    
    ProfilesList *profilesList  = [[ProfilesList alloc] init];
    for (NSString *key in profilesListResponse)
    {
        if ([profilesList respondsToSelector:NSSelectorFromString(key)])
            [profilesList setValue:[profilesListResponse valueForKey:key] forKey:key];
    }
    
    [profiles addObject:profilesList];
    
    return profiles;
}
+ (NSArray *)tasksFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *completeRegistrationStatus = [parsedObject valueForKey:@"status"];
    NSString *completeRegistrationStringStatus = [NSString stringWithFormat:@"%@",[completeRegistrationStatus stringValue]];
    
    NSMutableArray *completeRegistrationArray = [[NSMutableArray alloc]init];
    if ([completeRegistrationStringStatus isEqualToString:@"200"])
    {
        if([parsedObject valueForKey:@"body"] != nil)
            [completeRegistrationArray addObject:[parsedObject valueForKey:@"body"]];
    }
    else if ([completeRegistrationStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return completeRegistrationArray;
}
+ (NSArray *)responseFromJSON:(NSDictionary *)parsedObject
{
    NSNumber *completeRegistrationStatus = [parsedObject valueForKey:@"status"];
    NSString *completeRegistrationStringStatus = [NSString stringWithFormat:@"%@",[completeRegistrationStatus stringValue]];
    
    NSMutableArray *completeRegistrationArray = [[NSMutableArray alloc]init];
    if ([completeRegistrationStringStatus isEqualToString:@"200"])
    {
        [completeRegistrationArray addObject:[parsedObject valueForKey:@"body"]];
    }
    else if ([completeRegistrationStringStatus isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:parsedObject forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return completeRegistrationArray;
}

@end
