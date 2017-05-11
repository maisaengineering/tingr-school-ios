
#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>
{
}
@property (strong, nonatomic) SingletonClass *singletonObj;

@property (retain, nonatomic) UITextField *emailField;
@property (nonatomic, strong) LoginViewController *loginCntrl;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

- (void)resetPasswordButtonTapped:(id)sender;

@end
