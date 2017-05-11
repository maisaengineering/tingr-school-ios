//
//  SVWebViewController.h
//


#import "SVModalWebViewController.h"

@interface SVWebViewController : UIViewController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, assign) BOOL isHide;
@property (nonatomic, assign) BOOL isPopup;

@end
