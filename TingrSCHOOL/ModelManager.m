
#import "ModelManager.h"

@implementation ModelManager

@synthesize accessToken;
@synthesize currentHospital;
@synthesize userProfile;
@synthesize userEnteredZipCode;
@synthesize currentParentProfile;
@synthesize currentMilestone;
@synthesize currentMoment;
@synthesize facebookShare;
@synthesize currentCountryCode;

#pragma mark Singleton Methods

+ (id)sharedModel
{
    static ModelManager *sharedAppModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppModel = [[self alloc] init];
    });
    return sharedAppModel;
}

- (id)init {
    
    if (self = [super init])
    {
        [self clear];
    }
    return self;
}

- (void) clear
{
    accessToken         = NULL;
    currentHospital     = NULL;
    userProfile         = NULL;
    userEnteredZipCode  = NULL;
    currentParentProfile = NULL;
    currentMilestone    = NULL;
    currentMoment       = NULL;
    facebookShare = FALSE;
    currentCountryCode = @"";
    
}

- (void)dealloc {
    
}

@end
