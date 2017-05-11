
#import <Foundation/Foundation.h>

@interface UserProfile : NSObject
{
    NSString *auth_token;
    NSString *teacher_klid;
    NSString *fname;
    NSString *mname;
    NSString *lname;
    NSString *email;
    NSArray  *rooms;
    // added one bool
    BOOL     onboarding;
    //
    NSString *photograph;
    NSString *org_logo;
    
}

@property (strong, nonatomic) NSString *auth_token;
@property (strong, nonatomic) NSString *teacher_klid;
@property (strong, nonatomic) NSString *fname;
@property (strong, nonatomic) NSString *mname;
@property (strong, nonatomic) NSString *lname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray  *rooms;
@property (strong, nonatomic) NSString  *org_logo;
@property (strong, nonatomic) NSString *photograph;
@property (nonatomic)         BOOL      onboarding;
@end
