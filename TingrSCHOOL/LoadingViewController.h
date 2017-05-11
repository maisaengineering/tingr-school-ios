
#import <UIKit/UIKit.h>
#import "SingletonClass.h"
#import "MBProgressHUD.h"

@interface LoadingViewController : UIViewController<MBProgressHUDDelegate>
{

}

@property (strong, nonatomic) SingletonClass *singletonObj;
// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

@end
