//
//  ProfileKidsTOCV2ViewController.h
//  KidsLink
//
//  Created by Dale McIntyre on 4/18/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPostViewController.h"
#import "StreamDisplayView.h"

@interface ProfileKidsTOCV2ViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
     BOOL isPromptAdded;
     BOOL isKidTocView;
}
@property (strong, nonatomic) NSMutableDictionary *person;
@property (strong, nonatomic) NSString *kid_klid;
@property (strong, nonatomic) NSMutableDictionary *profileDetails;
@property (nonatomic, strong) UIImageView *profileImage;
@property (nonatomic, strong) UILabel *lblName,*lblGrouping;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isFromFirstAddedChild;
@property (nonatomic, assign) BOOL isKidTocView;
@property (nonatomic, assign) BOOL isFromPinView;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

@end
