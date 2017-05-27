//
//  MilestoneView.h
//  KidsLink
//
//  Created by Maisa Solutions on 4/19/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharingCheck.h"
// Aviary iOS 7 Start
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>
#import "TaggingView.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "UIImageViewAligned.h"
#import "VideoRecordViewController.h"
// Aviary iOS 7 End

@protocol MilestoneDelegate <NSObject>
- (void)mileStoneClick;
@end

@interface MilestoneView : UIView<UIActionSheetDelegate,UIImagePickerControllerDelegate, UITextViewDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,AVYPhotoEditorControllerDelegate, UIPopoverControllerDelegate,SharingCheckDelegate, TaggingViewDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,NSURLSessionDelegate,VideoRecordDelegate>
{
    MBProgressHUD *HUD;
   
    NSMutableArray *imagesArray;
    UIImageView *starImage;
    UILabel *milestoneTitleLabel;
    UIButton *btnMilestoneTitle;
    UIScrollView *scrollView;
    
    UIButton *dateBtn;
    UILabel *dateLabel;
    
    UILabel *caregivers;
    UILabel *myCircle;
    
    
    UIDatePicker *docDatePicker;
    UIView       *presentchildBgView;
    UIView       *presentchildView;
    NSDate    *selectedDate;
    NSMutableArray  *profileImagesArray;
    UIView *inputView;
    NSMutableArray *totalProfileImages;
    BOOL isImageUploading;
    CGPoint scrollPosition;
    UIImagePickerController *imagePicker;
    UIImagePickerController *videoPicker;
    BOOL isImageSelected;
    
    UIButton *btnPost;
    NSString *imageURL;
     UILabel *visibleTo;
    
    UISlider *sharingSlider;
    
    UITextField *txtTitle;
    
}
//@property (nonatomic, strong)   NSMutableArray *btnSelectdArray;
@property (nonatomic, strong) NSString *profileID;
@property (nonatomic, assign) id<MilestoneDelegate> delegate;

// for Aviary
@property (strong, nonatomic) UIImageView         * imagePreviewView;
@property (nonatomic, strong) UIView              * borderView;
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, assign) BOOL                  shouldReleasePopover;
@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;
@property (nonatomic, strong) NSMutableArray      * sessions;
@property (strong, nonatomic) UIImageView         * logoImageView;
@property (strong, nonatomic) UIButton            * attachPhotoBtn;
@property (nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong)  NSMutableArray *imagesArray;
@property (nonatomic,retain)  UIImageViewAligned *attachedImageView;
@property (nonatomic, strong) UIScrollView *profileImagesScrollView;
@property (nonatomic, strong) UIScrollView *momentScroll;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, assign) BOOL isvisible;
@property (nonatomic, strong) UILabel *visible;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImageView *friendsImageView;
@property (nonatomic, assign) BOOL isFromThisView;
@property (nonatomic, assign) BOOL fbShare;
@property (nonatomic, strong) UIButton *fbIconOnOff;
@property (nonatomic, strong) UIButton *instagramIconOnOff;
@property (nonatomic, assign) BOOL isImageProcessing;
@property (nonatomic, assign) BOOL isPostClicked;
@property (nonatomic, assign) BOOL isFromAddedChild;

@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isDateSelected;

@property (nonatomic, assign) BOOL isTextOnly;
@property (nonatomic, strong) NSString *previousDate;


//Used to fill details when editing form streams drop down
@property (nonatomic, assign) NSDictionary *detailsDictionary;

// To avoid the memory leaks
@property (nonatomic, strong)UIDatePicker *docDatePicker;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

@property (nonatomic, strong) MFMailComposeViewController *mailComposer;


- (void)postClicked:(id)sender;
//-(NSMutableAttributedString *)getAttributedString:(NSString *)text;
-(void)destroyView;

-(void)setData:(NSDictionary *)dataDict;
-(void)finishedEditingImage:(UIImage *)image;
@end
