//
//  KidProfileView.h
//  KidsLink
//
//  Created by Dale McIntyre on 4/13/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ProfileKidsTOCV2ViewController.h"


// Aviary iOS 7 Start
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>
// Aviary iOS 7 End

@interface KidProfileView : UIView<UIScrollViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate,UIActionSheetDelegate, UINavigationControllerDelegate,AVYPhotoEditorControllerDelegate,UIPopoverControllerDelegate>
{
    NSString *imageExtension;
    NSMutableData *_responseData;
    UIImage *changedImage;
    UIViewController *myowner;
    
    UIImagePickerController *imagePicker;
    BOOL isImageSelected;
    MBProgressHUD *HUD;
    UIView *profileParent;
    UIButton *btnProfileShare;
}

@property (nonatomic, retain) UIViewController* myowner;
@property (nonatomic) NSMutableDictionary *person;
@property (nonatomic, strong) MFMailComposeViewController *mailComposer;
@property (nonatomic, strong) ProfileKidsTOCV2ViewController *parent;
@property (strong, nonatomic) UIImageView * imagePreviewView;
@property(nonatomic,strong) SingletonClass *singletonObj;

@property (nonatomic, strong) UIView * borderView;
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, assign) BOOL     shouldReleasePopover;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIButton *btnEditPhoto;
@property (strong, nonatomic)  UILabel *lblProfileEditName;
@property (nonatomic, strong) NSMutableArray      * sessions;

@property (nonatomic, strong) UIButton *btnProfileEditPhoto;
@property (nonatomic, strong) UIPopoverController * popover;
// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;
@property (nonatomic, strong) MBProgressHUD *HUD;

-(void)showMailComposerWithEmailID:(NSString *)email;
-(void)tappedOnPhoneNumber:(NSString *)phoneNumber;

-(void)resetFormData;
- (void)editCancelButtonTapped:(id)sender;

- (void)openControl;

@end
