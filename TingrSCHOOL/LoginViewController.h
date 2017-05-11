
#import <UIKit/UIKit.h>
#import "VOUserProfile.h"
#import "VOProfilesList.h"
@interface LoginViewController : UIViewController<UITextFieldDelegate, MBProgressHUDDelegate,UIGestureRecognizerDelegate>
{
    UIButton *btnSubmit;
    UITextField *txtConfirmPasssword;
    UITextField *txtPassword;
    UITextField *txtEmail;
    UISwitch *onoff;
    MBProgressHUD *spinner;
    UserProfile *_userProfile;
    ModelManager *sharedModel;
     ProfilesList *profilesListObj;
}

@property (strong, nonatomic) SingletonClass *singletonObj;
@property (strong, nonatomic) UITextField *txtConfirmPasssword;
@property (strong, nonatomic) UITextField *txtPassword;
@property (strong, nonatomic) UITextField *txtEmail;
@property (nonatomic, retain) UISwitch *onoff;
@property (nonatomic) BOOL isRememberClicked;
@property (nonatomic, assign) BOOL isPwdChanged;
@property (nonatomic, assign) BOOL isSignUp;
@property (nonatomic, strong)  NSString *gotoResult;
@property (nonatomic, strong) NSString *email;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) UIScrollView *backgroundImageViewScrollView;


// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

- (void)loginButtonPressed:(id)sender;
- (void)forgotButtonPressed:(id)sender;
- (void)flip:(id)sender;
-(void)newPoptoLogin;

@end
