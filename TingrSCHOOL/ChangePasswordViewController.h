//
//  ChangePasswordViewController.h
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 03/05/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ChangePasswordCommunicator.h"

@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate>
{
    UIScrollView *scrollView;
}
// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

- (IBAction)submitButtonTapped:(id)sender;
@end
