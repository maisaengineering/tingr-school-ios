
#import <Foundation/Foundation.h>
#import "VOAccessToken.h"
#import "VOUserProfile.h"

@interface ModelManager : NSObject
{
    AccessToken *accessToken;
    UserProfile *_userProfile;
    NSDictionary *currentHospital;
    NSString *userEnteredZipCode;
    NSDictionary *currentParentProfile;
    NSDictionary *currentMilestone;
    NSDictionary *currentMoment;
    BOOL facebookShare;
    NSString *currentCountryCode;
}

@property (nonatomic, retain) AccessToken *accessToken;
@property (nonatomic, retain) NSDictionary *currentHospital;
@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) NSString *userEnteredZipCode;
@property (nonatomic, retain) NSDictionary *currentParentProfile;
@property (nonatomic, retain) NSDictionary *currentMilestone;
@property (nonatomic, retain) NSDictionary *currentMoment;
@property  BOOL facebookShare;
@property (nonatomic, retain) NSString *currentCountryCode;

+ (id)sharedModel;
- (void) clear;

@end
