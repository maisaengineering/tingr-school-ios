//
//  MilestoneView.m
//  KidsLink
//
//  Created by Maisa Solutions on 4/19/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "MilestoneView.h"
#import "Base64.h"
#import "UIImageView+AFNetworking.h"
#import "AddPostViewController.h"
#import "ProfilePhotoUtils.h"
#import "TaggingView.h"
#import "TaggingUtils.h"
#import "ProfileDateUtils.h"

#import "LSLDatePickerDialog.h"
#import "PostDataUpload.h"
@implementation MilestoneView
{
    ProfilePhotoUtils  *photoUtils;
    ProfileDateUtils *photoDateUtils;
    
    UIView *addPopUp;
    BOOL photoFromCamera;
    NSMutableDictionary *currentMilestone;
    BOOL facebookCheck;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    BOOL instagramOn;
    UIView *bottomView;
    TaggingView *tagView;
    NSMutableDictionary *allTagButtons;
    UIButton *shareEmailBtn;
    
     int uploadingImages;

    UITableView *kidTableView;
    
    NSMutableArray *imageKeysArray;
    UIView *contentDetailsView;
    UIView *addTextView;
    
    int selectedIndex;
    
    
}

@synthesize delegate;
//@synthesize textView;
@synthesize profileImagesScrollView;
// for Aviary
@synthesize  imagePreviewView;
@synthesize  borderView;
@synthesize  popover;
@synthesize  shouldReleasePopover;
@synthesize  assetLibrary;
@synthesize  sessions;
@synthesize  logoImageView;
@synthesize  attachPhotoBtn;
@synthesize profileID;
@synthesize selectedImage;
@synthesize imagesArray;
@synthesize attachedImageView;
@synthesize selectedArray;
@synthesize isvisible,visible;
@synthesize momentScroll;
@synthesize placeholderLabel;
@synthesize friendsImageView;
//@synthesize btnSelectdArray;
@synthesize isFromThisView;
@synthesize fbIconOnOff;
@synthesize instagramIconOnOff;
@synthesize isImageProcessing;
@synthesize isPostClicked;
@synthesize detailsDictionary;
@synthesize isUpdate;
@synthesize isDateSelected;
@synthesize previousDate;
// To avoid the memory leaks
@synthesize docDatePicker;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;
@synthesize isFromAddedChild;

@synthesize mailComposer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    
    return self;
}

-(void)baseInit
{
    
    SharingCheck *sharingCheck = [[SharingCheck alloc] init];
    [sharingCheck setDelegate:self];
    
    [sharingCheck callShareApi];
    
    self.backgroundColor = [UIColor whiteColor];
    
    isvisible = YES;
    isImageSelected = NO;
    isDateSelected = NO;
    uploadingImages = 0;
    sharedModel   = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    
    imageKeysArray = [[NSMutableArray alloc] init];
    imagesArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    totalProfileImages = [[NSMutableArray alloc] init];
    //btnSelectdArray = [[NSMutableArray alloc] init];
    profileImagesArray = [sharedInstance.sortedParentKidDetails mutableCopy];
    allTagButtons = [[NSMutableDictionary alloc] init];
    
    photoUtils = [ProfilePhotoUtils alloc];
    photoDateUtils = [ProfileDateUtils alloc];
    
    if(profileID.length >0)
        [selectedArray addObject:profileID];
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    CGFloat screenHeight = screenRect.size.height;
//    titleMilestoneView = [[TitleMilestoneView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
//    titleMilestoneView.delegate = self;
    
    scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    scrollView.frame = CGRectMake(0,0,Devicewidth, self.frame.size.height);
    [self addSubview:scrollView];

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(12,12,self.frame.size.width - 24, 76) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"textCell"];
    [scrollView addSubview:_collectionView];
    
    
    contentDetailsView = [[UIView alloc] init];
    [scrollView addSubview:contentDetailsView];

    [_collectionView layoutIfNeeded];
  
    contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, self.frame.size.height - _collectionView.collectionViewLayout.collectionViewContentSize.height);
    
    UIImageView *lineImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, Devicewidth-28, 0.5)];
    [lineImageView1 setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1.0]];
    [contentDetailsView addSubview:lineImageView1];

    
    txtTitle = [[UITextField alloc]init];
    
    txtTitle.frame = CGRectMake(14,11,Devicewidth-28, 30);
    txtTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    txtTitle.delegate = self;
    txtTitle.borderStyle = UITextBorderStyleNone;
    txtTitle.autocorrectionType = UITextAutocorrectionTypeNo;
    txtTitle.placeholder = @"Give it a title";
    txtTitle.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    
    NSMutableParagraphStyle *style = [txtTitle.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    NSDictionary *placeHolderAttributes = @{
                                            NSForegroundColorAttributeName: [UIColor grayColor],
                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13],
                                            NSParagraphStyleAttributeName : style
                                            };
    
    
    txtTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Give it a title"
                                                                     attributes:placeHolderAttributes
                                      ];
    

    
    [contentDetailsView addSubview:txtTitle];
    
    UIImageView *lineImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(14, txtTitle.frame.size.height+txtTitle.frame.origin.y +8, Devicewidth-28, 0.5)];
    [lineImageView2 setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1.0]];
    [contentDetailsView addSubview:lineImageView2];

    tagView = [[TaggingView alloc] initWithFrame:CGRectMake(14,lineImageView2.frame.size.height+lineImageView2.frame.origin.y + 12,Devicewidth-28, 60)];
   // tagView.personArray = profileImagesArray;
    tagView.momentPlaceholderLabel.text = @"What is this post about?";
    tagView.delegate = self;
    tagView.textView.contentInset = UIEdgeInsetsMake(-10,-5,0,0);
    [contentDetailsView addSubview:tagView];
    
    // Pre-populate date picker with current date.
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setTimeZone:[NSTimeZone systemTimeZone]];
    
    // To know the Device time format:
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    NSLog(@"Device time format is:%@\n",(is24h ? @"24 hrs" : @"12 hrs"));
    if (is24h == YES)
    {
        [formatter1 setDateFormat:@"MMMM d, yyyy"];
    }
    else
    {
        [formatter1 setDateFormat:@"MMMM d, yyyy"];
    }
    selectedDate = [NSDate date];
    
    UIImageView *lineImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(14, tagView.frame.size.height+tagView.frame.origin.y , Devicewidth-28, 0.5)];
    [lineImageView3 setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1]];
    [contentDetailsView addSubview:lineImageView3];
    
    [self addkidTableForTagging];
    

    self.docDatePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 45, 320, 250)];
    self.docDatePicker.backgroundColor = [UIColor whiteColor];
    //self.docDatePicker.maximumDate = [NSDate date];
    self.docDatePicker.datePickerMode = UIDatePickerModeDate;

    
    // for Aviary
    logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 240, 40)];
    [self addSubview:logoImageView];
    
    // Aviary iOS 7 Start
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];
    
    // Allocate Sessions Array
    NSMutableArray * sessions1 = [NSMutableArray new];
    [self setSessions:sessions1];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    // Aviary iOS 7 End
    
    //listen for facebook access
    
    facebookCheck = FALSE;
    
    if(self.isTextOnly)
        [txtTitle becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(editPostCompleted:)
     name:@"EditPostCompleted"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(postCompleted:)
     name:@"PostCompleted"
     object:nil];

}

-(void)addProfileImages
{
    int x = 14,y=21;
    for (int i = 0; i <  profileImagesArray.count; i++)
    {
        if([[[profileImagesArray objectAtIndex:i] valueForKey:@"accessibility"] intValue] != 2)
        {
            [profileImagesArray removeObjectAtIndex:i];
            i--;
            continue;
        }
        NSString *url = [NSString stringWithFormat:@"%@",[[profileImagesArray objectAtIndex:i] valueForKey:@"photograph"]];
        
        UIImageView *backImage = [[UIImageView alloc] initWithFrame: CGRectMake(x - 4.7f, y-4.75, 59.5, 59.5)] ;
        [profileImagesScrollView addSubview:backImage];
        [backImage setImage:[UIImage imageNamed:@"circle-selected.png"]];
        [backImage setHidden:YES];
        backImage.tag = -(100+i);

        
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame: CGRectMake(x, y, 50, 50)] ;
        [profileImagesScrollView addSubview:imagVw];
        [imagVw setAlpha:0.7];
        imagVw.tag = 100+i;

        
        
        UIButton *btnProfilePic = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnProfilePic setFrame:CGRectMake(x-4.75f, y-4.75f, 59.5f, 59.5f)];
        btnProfilePic.tag = i;
        
        
        UILabel *tagFamilyLbl = [[UILabel alloc] initWithFrame:CGRectMake(x-9,y+54,70, 15)];
        [tagFamilyLbl setBackgroundColor:[UIColor clearColor]];
        
        tagFamilyLbl.text = [[profileImagesArray objectAtIndex:i] valueForKey:@"name"];
        
        [tagFamilyLbl setBackgroundColor:[UIColor clearColor]];
        [tagFamilyLbl setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [tagFamilyLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        [profileImagesScrollView addSubview:tagFamilyLbl];
        [tagFamilyLbl setTextAlignment:NSTextAlignmentCenter];
        [tagFamilyLbl setTag:1000+i];
        
        __weak UIImageView *weakSelf = imagVw;
        
        [totalProfileImages addObject:[UIImage imageNamed:@"defaultPerson.png"]];
        
        [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"defaultPerson.png"] scaledToSize:CGSizeMake(50, 50)] withRadious:0.0f] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [totalProfileImages replaceObjectAtIndex:weakSelf.tag-100 withObject:image];
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(50, 50)] withRadious:0.0f];
             
         }
                               failure:nil];
        [btnProfilePic addTarget:self action:@selector(imageSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [profileImagesScrollView addSubview: btnProfilePic];
        [allTagButtons setObject:btnProfilePic forKey:[[profileImagesArray objectAtIndex:i] valueForKey:@"kl_id"]];
        
        x += 70;
        
        //TODO: Figure out the use of this profileId - this is passed into the control from the
        //AddPostViewController
        if([profileID isEqualToString:[[profileImagesArray objectAtIndex:i] valueForKey:@"kl_id"]])
        {
            [self imageSelected:btnProfilePic];
            [btnProfilePic setUserInteractionEnabled:NO];
        }
        
    }
    [profileImagesScrollView setContentSize:CGSizeMake(x, 80)];
    DebugLog(@"images 1 %@",profileImagesArray);
}

//Sets data when editing the form
-(void)setData:(NSDictionary *)dataDict
{
    self.detailsDictionary = dataDict;
    
    //image
  /*  if([[detailsDictionary objectForKey:@"image"] length] > 0)
    {
        [self.attachedImageView setImageWithURL:[NSURL URLWithString:[detailsDictionary objectForKey:@"image"]]];
    }
    */
    //title
    if([[detailsDictionary objectForKey:@"new_title"] length] > 0)
    {
        txtTitle.text = [detailsDictionary objectForKey:@"new_title"];
    }
    
    //date
    NSString *dateStr = [detailsDictionary objectForKey:@"created_at"];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:@" UTC" withString:@"-0000"];
    //NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter1 setLocale:enUSPOSIXLocale];
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];
    
    NSDate *date = [dateFormatter1 dateFromString:dateStr];
    [dateFormatter1 setDateFormat:@"MMMM d, yyyy"];
    selectedDate = date;
    [dateFormatter1 setDateFormat:@"dd MMM yyyy"];

    dateLabel.text = [dateFormatter1 stringFromDate:date];
    
    previousDate = [photoDateUtils getUTCFormateDateFromLocalDate:date];
    
    //text
    if([[detailsDictionary objectForKey:@"text"] length] > 0)
    {
        [placeholderLabel removeFromSuperview];
        //textView.attributedText = [self getAttributedString:[detailsDictionary objectForKey:@"text"]];
        tagView.textView.text = [TaggingUtils formatAttributedStringFromServerDoubleTags:[detailsDictionary objectForKey:@"text"]];
        [tagView textChangedCustomEvent];
    }
    
    //set tags
    
    for(NSString *kl_Id in [detailsDictionary objectForKey:@"tags"])
    {
        if(![selectedArray containsObject:kl_Id])
        {
            [selectedArray addObject:kl_Id];
        }

    }
    
    ///visibility
    if([[detailsDictionary objectForKey:@"scope"] isEqualToString:@"private"])
    {
        isvisible = NO;
        
        sharingSlider.value = 0;
        //myCircle.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        //caregivers.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
    else
    {
        isvisible = YES;
        
        sharingSlider.value = 1;
        //caregivers.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
       //myCircle.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
    
    [kidTableView reloadData];
    
    NSArray *imgArray = [detailsDictionary objectForKey:@"images"];
    NSArray *img_keysArray = [detailsDictionary objectForKey:@"img_keys"];
    if([imgArray count]&&img_keysArray.count &&img_keysArray.count == imgArray.count) {
        
        for(int i=0 ;i<[imgArray count];i++)
        {
            [imagesArray addObject:@{@"url":[NSURL URLWithString:imgArray[i]],@"key":img_keysArray[i]}];
        }
        
        [_collectionView reloadData];
        [_collectionView layoutIfNeeded];
        CGRect frame  = _collectionView.frame;
        
        frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
        _collectionView.frame = frame;
        
        
        contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);

    }
}

//when someone manually clicks on the tags
-(void)imageSelected:(id)sender
{
    UIButton *btn = sender;
    NSDictionary *dict = [profileImagesArray objectAtIndex:btn.tag];
    
    if(!btn.isSelected)
    {
        if(![selectedArray containsObject:[dict objectForKey:@"kl_id"]])
        {
            
            UIImageView *imgView = (UIImageView *)[profileImagesScrollView viewWithTag:[sender tag]+100];
            imgView.alpha = 1.0;
            
            UIImageView *backImgView = (UIImageView *)[profileImagesScrollView viewWithTag:-([sender tag]+100)];
            backImgView.hidden = NO;

            [(UILabel*)[profileImagesScrollView viewWithTag:[sender tag]+1000] setTextColor:[UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0]];
            [(UILabel*)[profileImagesScrollView viewWithTag:[sender tag]+1000] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
            
            [selectedArray addObject:[[profileImagesArray objectAtIndex:[sender tag]] objectForKey:@"kl_id"]];
            //[btnSelectdArray addObject:[[profileImagesArray objectAtIndex:[sender tag]] objectForKey:@"kl_id"]];
            btn.selected =  YES;
            
        }
    }
    else
    {
        ////[Flurry logEvent:@"Stream_Post_ManualTag"];
        NSString *string = [[(UILabel*)[profileImagesScrollView viewWithTag:[sender tag]+1000] text] lowercaseString];
        NSString *placeholder = @"\\b%@\\b";
        NSString *pattern = [NSString stringWithFormat:placeholder, string];
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:nil];
        
        NSArray *matches = [regex matchesInString:tagView.textView.text options:NSMatchingReportProgress range:NSMakeRange(0, tagView.textView.text.length)];
        
        if (matches.count == 0) {
            
            UIImageView *imgView = (UIImageView *)[profileImagesScrollView viewWithTag:[sender tag]+100];
            imgView.alpha = 0.7;
            UIImageView *backImgView = (UIImageView *)[profileImagesScrollView viewWithTag:-([sender tag]+100)];
            backImgView.hidden = YES;

            
            [(UILabel*)[profileImagesScrollView viewWithTag:[sender tag]+1000] setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
            [(UILabel*)[profileImagesScrollView viewWithTag:[sender tag]+1000] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];

            
            //[btnSelectdArray removeObject:[[profileImagesArray objectAtIndex:[sender tag]] objectForKey:@"kl_id"]];
            [selectedArray removeObject:[[profileImagesArray objectAtIndex:[sender tag]] objectForKey:@"kl_id"]];
            btn.selected =  NO;
        }
        
    }
}

-(void)privacyTapped:(id)sender
{
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"My Circle", @"only My Fam", nil];
    addImageActionSheet.tag = 1;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)faceBookShareOnOff:(id)sender
{
 /*   if(sharedInstance.isFBShareEnabled == 1)
    {
        if (sharedModel.facebookShare)
        {
            sharedModel.facebookShare = FALSE;
            //[fbIconOnOff setImage:[UIImage imageNamed:@"facebook_off.png"]];
            [fbIconOnOff setSelected:FALSE];
            [sharedInstance setIsFaceBookChecked:NO];
        }
        else
        {
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            facebookCheck = TRUE;
            [sharedInstance setIsFaceBookChecked:YES];
            [fbc checkFacebookPermissions];
        }
    }
    else
    {
        // Access denied.
        DebugLog(@"FB Access denied.");
        UIAlertView *fbComingSoonAlert = [[UIAlertView alloc]initWithTitle:@"Facebook temporarily unavailable. Try again later."  message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        self.globalAlert = fbComingSoonAlert;
        
        [fbComingSoonAlert show];
    }
  */
}

//this is a call back from the check function to turn off the facebook icon if there is a problem
-(void)checkFacebookButton: (NSNotification *) notification
{
    if (facebookCheck)
    {
        facebookCheck = FALSE;
        NSDictionary *dict = [notification userInfo];
        NSLog(@"%@", dict);
        
        NSString *fbShareString = [dict objectForKey:@"SHOW_FACEBOOK"];
        
        if ([fbShareString isEqualToString:@"FALSE"])
        {
            sharedModel.facebookShare = FALSE;
            //[fbIconOnOff setImage:[UIImage imageNamed:@"facebook_off.png"]];
            [fbIconOnOff setSelected:FALSE];
        }
        else
        {
            sharedModel.facebookShare = TRUE;
            //[fbIconOnOff setImage:[UIImage imageNamed:@"facebook_on.png"]];
            [fbIconOnOff setSelected:TRUE];
        }
    }
    
}

-(void)instagramShareOnOff:(id)sender
{
  /*  if (isFromAddedChild)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Advanced feature"
                                                       message:@"Instagram sharing will become available once you add your first moment for this child."
                                                      delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
    }
    else if(![(AddPostViewController *)self.delegate isSharing])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Advanced feature"
                                                       message:@"Instagram sharing will become available once you add your first moment."
                                                      delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
    }
    else
    {
        if ([MGInstagram isAppInstalled])
        {
            if (instagramOn)
            {
                instagramOn = FALSE;
                [instagramIconOnOff setSelected:FALSE];
                [sharedInstance setIsInstagramChecked:NO];
            }
            else
            {
                if (selectedImage != NULL)
                {
                    instagramOn = TRUE;
                    [instagramIconOnOff setSelected:TRUE];
                    [sharedInstance setIsInstagramChecked:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE
                                                                   message:INSTAGRAM_ALERT_BODY_SHARE
                                                                  delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                                          
                                                         otherButtonTitles:nil,nil];
                    self.globalAlert = alert;
                    
                    [alert show];
                }
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE
                                                           message:INSTAGRAM_ALERT_BODY_INSTALL
                                                          delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                                  
                                                 otherButtonTitles:nil,nil];
            self.globalAlert = alert;
            
            [alert show];
        }
    }
    
    */
}


#pragma mark Post Service Call
-(void)uploadImage:(UIImage *)imageOrg1
{
    
    selectedImage = imageOrg1;
    NSData *imageData1 = UIImageJPEGRepresentation(imageOrg1, 0.7);
    
    NSString *fileExtension = @"JPEG";
    NSString *imageExtension1 = fileExtension;
    
    imageExtension1 = [imageExtension1 uppercaseString];
    
    if ([imageExtension1 isEqualToString:@"GIF"]||[imageExtension1 isEqualToString:@"JPG"]||[imageExtension1 isEqualToString:@"PNG"]||[imageExtension1 isEqualToString:@"JPEG"])
    {
        NSString *stringImageName = [NSString stringWithFormat:@"temp.%@",imageExtension1];
        NSString *stringContentType = [NSString stringWithFormat:@"image/%@",[imageExtension1 lowercaseString]];
        NSString *stringContent = [imageData1 base64EncodedString];
        
        
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus status = [reach currentReachabilityStatus];
        NSString *networkStatus = [sharedInstance stringFromStatus:status];
        
        if ([networkStatus isEqualToString:@"Not Reachable"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                           message:@"No internet connection. Try again after connecting to internet"
                                                          delegate:self cancelButtonTitle:@"Ok"
                                  
                                                 otherButtonTitles:nil,nil];
            self.globalAlert = alert;
            
            [alert show];
        }
        else
        {
            HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
            [[UIApplication sharedApplication].keyWindow addSubview:HUD];
            HUD.delegate = self;
            [HUD hide:NO];
            [HUD show:YES];
            
            NSMutableDictionary *newImageDetails  = [NSMutableDictionary dictionary];
            
            [newImageDetails setValue:stringImageName     forKey:@"name"];
            [newImageDetails setValue:stringContentType   forKey:@"content_type"];
            [newImageDetails setValue:stringContent       forKey:@"content"];

            
            AccessToken* token = sharedModel.accessToken;
            UserProfile *userProfile = sharedModel.userProfile;
            
            NSString *command = @"upload_to_s3";
            
            
            //build an info object and convert to json
            NSDictionary* postData = @{@"access_token": token.access_token,
                                       @"auth_token": userProfile.auth_token,
                                       @"command": command,
                                       @"body": newImageDetails};
            NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
            NSDictionary *userInfo = @{@"command":command};
            
            NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
            API *api = [[API alloc] init];
            [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
                [self didReceiveMilestoneImageUpload:[json objectForKey:@"response"]];
                
            } failure:^(NSDictionary *json) {
                
                [self fetchingCreateMilestoneImageUploadFailedWithError:nil];
                
            }];
        }
        
        
    }
}
-(void)sendDataToParent:(id)sender
{
    
    [addPopUp removeFromSuperview];
   
        [self.delegate mileStoneClick];
    
}
//call back from managers
-(void)cancelTapped:(id)sender
{
    [addPopUp removeFromSuperview];
}

-(void)firstPostForKid:(id)sender
{
    [addPopUp removeFromSuperview];
    if (sharedInstance.isInKidsTOC == YES)
    {
        [[SingletonClass sharedInstance] setIsPostFromFirstAddedChild:YES];
    }
    if([(AddPostViewController *)self.delegate childDetails] != nil)
    {
        [[SingletonClass sharedInstance] setIsPostFromFirstAddedChild:YES];
    }
    [self.delegate mileStoneClick];
}

- (void)responseForSharing:(NSDictionary *)body
{
    
    if([[body objectForKey:@"first_post"] boolValue])
    {
        if((AddPostViewController *)self.delegate)
        [(AddPostViewController *)self.delegate setIsSharing:NO];
    }
    else
    {
        if((AddPostViewController *)self.delegate)
        [(AddPostViewController *)self.delegate setIsSharing:YES];
        
    }
}
- (void)errorForSharing
{
    [HUD show:NO];
    [HUD hide:YES];
}
- (void)postClicked:(id)sender
{
    btnPost = sender;
    if (self.detailsDictionary)
    {
        if (selectedImage == nil)
        {
            selectedImage = self.attachedImageView.image;
            
        }
    }
    //////new code for merging moment and milestone
    {
        if([txtTitle.text length] == 0)
        {
            UIAlertView *emptyAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Please enter title" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            self.globalAlert = emptyAlert;
            
            [emptyAlert show];
            return;
        }
        
        
      /*  if([attachedImageView image] != nil && [imagesArray count] == 0 &&  !isImageProcessing)
        {
            [tagView.textView resignFirstResponder];
            isImageProcessing = YES;
            
            [self uploadImage];
            return;
            
        }
       */
     
        
        if([imagesArray count] == 0 && tagView.textView.text.length == 0 && [[self.detailsDictionary objectForKey:@"img_keys"] count] == 0 )
        {
            UIAlertView *emptyAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Please add photo or video or enter details" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            self.globalAlert = emptyAlert;
            
            [emptyAlert show];
            return;
            
        }
        

        
        isPostClicked = YES;
        
       
        if ([sender tag] ==98765 )
        {
            //[Flurry logEvent:@"Stream_Post_PostTopRight"];
        }
        else
        {
            //[Flurry logEvent:@"Stream_Post_PostBottom"];
        }
        
        // Here we are creating the Flurry Events for both FB and IG based on the icon Selection.
        if (fbIconOnOff.selected)
        {
            //[Flurry logEvent:@"Stream_Post_Social_FB"];
        }
        if(instagramIconOnOff.selected)
        {
            //[Flurry logEvent:@"Stream_Post_Social_IG"];
        }
        
        [tagView.textView resignFirstResponder];
        
        
        isFromThisView = NO;
        isImageUploading = NO;
        
    
        [self createMilestone];
    }
}

-(void)highlightButton:(NSString *)kl_id
{
    id button = [allTagButtons objectForKey:kl_id];
    [self imageSelected:button];
}



-(void)createMilestone
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [sharedInstance stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
        UIBarButtonItem *postButton = (UIBarButtonItem *)[[(AddPostViewController *)self.delegate view] viewWithTag:98765];
        [postButton setEnabled:YES];
        [btnPost setEnabled:YES];
        [btnPost setUserInteractionEnabled:YES];
    }
    else
    {
        [Spinner showIndicator:YES];
        NSMutableArray *keysArray = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in imagesArray) {
            
            
            NSURL *url = [dict objectForKey:@"url"];
            NSString *key = [dict objectForKey:@"key"];
            if(key != nil && key.length > 0)
            {
                [keysArray addObject:key];
                continue;
            }
            else {
                
                if([[[url absoluteString] lowercaseString] containsString:@".jpeg"]) {
                    
                    NSString *contentType = @"image/jpeg";
                    NSString *key = [NSString stringWithFormat:@"%@%@.jpeg",[[[ModelManager sharedModel] userProfile] teacher_klid],TimeStamp];
                    [[PostDataUpload sharedInstance] getPresignedURLWithFileUrl:url withKey:key contentType:contentType];

            }
                else {
                    
                    NSString *contentType = @"video/mp4";
                    NSString *key = [NSString stringWithFormat:@"%@%@.mp4",[[[ModelManager sharedModel] userProfile] teacher_klid],TimeStamp];
                    
                [[PostDataUpload sharedInstance] getPresignedURLWithFileUrl:url withKey:key contentType:contentType];

                }
        }
        
        }
        UIBarButtonItem *postButton = (UIBarButtonItem *)[[(AddPostViewController *)self.delegate view] viewWithTag:98765];
        [postButton setEnabled:NO];
        [btnPost setEnabled:NO];
        [btnPost setUserInteractionEnabled:NO];
        
        
        NSMutableDictionary *newMilestoneDetails  = [NSMutableDictionary dictionary];
        
        //NSArray *tags = [tagView getAllTaggedIds];
        NSMutableArray *tags = [[tagView getAllTaggedIds] mutableCopy];
        //combine with image tags
        for (int i=0;i<selectedArray.count;i++ )
        {
            NSString *tag_kl_id = [NSString stringWithFormat:@"%@",[selectedArray objectAtIndex:i]];
            if (![tags containsObject:tag_kl_id])
            {
                [tags  addObject:tag_kl_id];
            }
        }

        if(tags.count > 0)
            [newMilestoneDetails setObject:tags forKey:@"tags"];
        
        if(txtTitle.text.length > 0)
        {
            [newMilestoneDetails setObject:txtTitle.text forKey:@"new_title"];
        }
        else
        {
            [newMilestoneDetails setObject:@"" forKey:@"new_title"];
        }
        //[newMilestoneDetails setValue:@"milestone"                forKey:@"type"];
        // Here we are getting the user selected date.
        //convert it based on UTC time and then sent to server.
        if (isDateSelected == YES)
        {
            isDateSelected = NO;
            // To fix the timezone issue.
            NSString *stringFromDate1 = [photoDateUtils getUTCFormateDateFromLocalDate:selectedDate];
            [newMilestoneDetails setObject:stringFromDate1 forKey:@"date"];
        }
        else
        {
            // Here user want to edit the previoius post except date
            // then send the previous date
            if(!isUpdate)
            {
                // Here user want to create a post without selecting a date.
                // Then we are sending the current date to the server after convertion of UTC.
                NSString *stringFromDate1 = [photoDateUtils getUTCFormateDateFromLocalDate:selectedDate];
                [newMilestoneDetails setObject:stringFromDate1 forKey:@"date"];

            }
        }
        
        //Old way to get the text from the tag view control
        //[newMilestoneDetails setObject:tagView.textView.text forKey:@"additional_text"];
        
        //this converts the text into text with ids for the server
        NSAttributedString *stringToConvert = tagView.textView.attributedText;
        NSString *formatedDesc = [TaggingUtils formatStringForServer:stringToConvert:profileImagesArray];
        [newMilestoneDetails setObject:formatedDesc forKey:@"additional_text"];
        
        if(isvisible)
        {
            [newMilestoneDetails setValue:@"public"                forKey:@"scope"];
            //[Flurry logEvent:@"Stream_Post_Visible_Friends"];
        }
        else
        {
            [newMilestoneDetails setValue:@"private"                forKey:@"scope"];
            //[Flurry logEvent:@"Stream_Post_Visible_Me"];
        }
        
        currentMilestone = newMilestoneDetails;
        
        if([[currentMilestone objectForKey:@"new_title"] length] > 0)
        {
            
            NSString *description = tagView.textView.text;
            
            if (![description isEqualToString:@""])
            {
                description = [NSString stringWithFormat:@"%@: %@",
                               [currentMilestone objectForKey:@"new_title"],
                               description];
            }
            else
            {
                description = [currentMilestone objectForKey:@"new_title"];
            }
            [[SingletonClass sharedInstance] setAttachedMessageForInstagram:description];
            
        }
        else
        {
            //[(AddPostViewController *)delegate showInstagramMessage];
            NSString *description = tagView.textView.text;
            [[SingletonClass sharedInstance] setAttachedMessageForInstagram:description];
        }
        
        
        
        AccessToken* token = sharedModel.accessToken;
        UserProfile *userProfile = sharedModel.userProfile;
        
        NSString *command;;
        
        
        //build an info object and convert to json
        NSDictionary *postData;
        NSString *urlAsString;
        NSDictionary *userInfo;
        NSDictionary *parameterDict;

        if(isUpdate)
        {
            command = @"update_post";
            postData = @{@"access_token": token.access_token,
                         @"auth_token": userProfile.auth_token,
                         @"command": command,
                         @"body": newMilestoneDetails};
            urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,[detailsDictionary objectForKey:@"kl_id"]];
            userInfo = @{@"command":command};
            
            parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
            
        }
        else
        {
            command = @"create_post";
            postData = @{@"access_token": token.access_token,
                         @"auth_token": userProfile.auth_token,
                         @"command": command,
                         @"body": newMilestoneDetails};
            urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
            userInfo = @{@"command":command};
            
            parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};

            //add this to the singleton so that we can use it later if needed (like posting to FB)
           // [newMilestoneDetails setObject:imageURL forKey:@"imageURL"];
            [newMilestoneDetails setObject:tagView.textView.text forKey:@"otherDescription"];
            
        }
    

        if(keysArray.count) {
            
            [[[PostDataUpload sharedInstance] selectedKeys] addObjectsFromArray:keysArray];
        }
        if(isUpdate)
            [[PostDataUpload sharedInstance] setDetailsDict:self.detailsDictionary];
        [[PostDataUpload sharedInstance] setPostDetails:[parameterDict mutableCopy]];
        [[PostDataUpload sharedInstance] callPostAPI];
        
        sharedInstance.lastPost = newMilestoneDetails;
        
    }
}
-(void)editPostCompleted:(NSNotification *)notification {
    
    [Spinner showIndicator:NO];
    [[(AddPostViewController *)self.delegate navigationController] popViewControllerAnimated:YES];
}
-(void)postCompleted:(NSNotification *)notification {
    
    [Spinner showIndicator:NO];
    [[(AddPostViewController *)self.delegate navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveCreateMilestones:(NSDictionary *)milestone
{
    sharedInstance.lastPostId = milestone;
    
    NSMutableDictionary *newMilestoneDetails = [[NSMutableDictionary alloc] init];
    if(imageURL)
    {
    [newMilestoneDetails setObject:imageURL forKey:@"imageURL"];
    [newMilestoneDetails setObject:tagView.textView.text forKey:@"otherDescription"];
    }
    sharedInstance.lastPost = newMilestoneDetails;
    
    if(isUpdate)
    {
        imageURL = [[milestone objectForKey:@"post"] objectForKey:@"fb_url"];
        [(AddPostViewController *)self.delegate setDetailsDictionary:[milestone objectForKey:@"post"]];
    }
    [btnPost setEnabled:YES];
    [btnPost setUserInteractionEnabled:YES];
    
    //    [HUD hide:YES];
    [HUD setHidden:YES];
    [HUD removeFromSuperview];
    HUD=nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self animated:YES];
    });
    
    // [(AddPostViewController *)self.delegate dismissViewControllerAnimated:YES completion:nil];
    
    if(![(AddPostViewController *)self.delegate isSharing])
    {
        //[self preparePopUpForAdd]; /* removing this as per ticket#84879406
        if ([[milestone allKeys] count] == 1 && sharedInstance.firstKidFirstPostKL_id.length==0)
        {
            [sharedInstance setFirstKidFirstPostKL_id:[milestone valueForKey:@"kl_id"]];
            [sharedInstance setIsFirstKidFirstPost:YES];
        }
        
        //[(AddPostViewController *)delegate dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.delegate mileStoneClick];
    
    DebugLog(@"%@",milestone); //this is always null now
    DebugLog(@"%@",currentMilestone);
    
    if(instagramOn)
    {
        sharedInstance.isInstagramShareEnabled = TRUE;
    }
    
    if (sharedModel.facebookShare)
    {
        /// If title is there then consider as milestone else moment
      /*  if([[currentMilestone objectForKey:@"new_title"] length] > 0)
        {
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            
            NSString *description = tagView.textView.text;
            
            if (![description isEqualToString:@""])
            {
                description = [NSString stringWithFormat:@"%@: %@",
                               [currentMilestone objectForKey:@"new_title"],
                               description];
            }
            else
            {
                description = [currentMilestone objectForKey:@"new_title"];
            }
            
            [fbc PostToFacebookViaAPI:imageURL:@"":description:@"milestone"];
        }
        else
        {
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            NSString *description = tagView.textView.text;
            [fbc PostToFacebookViaAPI:imageURL:@"":description:@"moment"];
        }
       */
    }
    
    
}
- (void)fetchingCreateMilestonesFailedWithError:(NSError *)error
{
    //[HUD hide:YES];
    [HUD hide:YES];
    [HUD removeFromSuperview];
    HUD=nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self animated:YES];
    });
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                       message:[error localizedDescription]
                                      delegate:self cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    
    alert.tag = 2;
    self.globalAlert = alert;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1) {
     
        if(buttonIndex != alertView.cancelButtonIndex) {
            
            [imagesArray removeObjectAtIndex:selectedIndex];
            [_collectionView reloadData];
            [_collectionView layoutIfNeeded];
            CGRect frame  = _collectionView.frame;
            
            frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
            _collectionView.frame = frame;
            
            contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);

        }
            
            
    }
    else {
        
        [self.delegate mileStoneClick];
    }
    
}

-(void)tagViewShouldBeginEditing:(id)sender
{
    
    
}

-(void)tagViewDidEndEditing:(id)sender
{
     scrollView.scrollEnabled = TRUE;
}

-(void)tagViewPersonTagged:(NSMutableDictionary *)person
{
    [self highlightButton:[person objectForKey:@"kl_id"]];
    
    //Commented as we need to add a kl_id not the dictionary
    //[selectedArray addObject:person];
    
    //Adding kl_id to the array
    [selectedArray addObject:[person objectForKey:@"kl_id"]];
}

-(void)tagViewShowTable:(id)sender
{
    CGRect frame = tagView.frame;
    frame.size.height = 400;
    tagView.frame = frame;
    [scrollView addSubview:tagView];
}

-(void)tagViewHideTable:(id)sender
{
    CGRect frame = tagView.frame;
    frame.size.height = 100;
    tagView.frame = frame;
    [scrollView addSubview:tagView];
}

#pragma mark Date Method

-(void)dateBtnTapped:(UIButton*)sender
{
    LSLDatePickerDialog *dialog = [[LSLDatePickerDialog alloc] init];
    
    
    NSDate *date = [NSDate date];
    if(selectedDate)
        date = selectedDate;
    [dialog showWithTitle:@"Demo" doneButtonTitle:@"Done" cancelButtonTitle:@"Cancel" defaultDate:date minimumDate:nil maximumDate:nil datePickerMode:UIDatePickerModeDate callback:^(NSDate * _Nullable date) {
        if(date)
        {
            isDateSelected = YES;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM d, yyyy"];
            [formatter setTimeZone:[NSTimeZone systemTimeZone]];
            selectedDate = date;
            
            [formatter setDateFormat:@"dd MMM yyyy"];
            [self.docDatePicker setDate:selectedDate];
            dateLabel.text = [formatter stringFromDate:date];

        }
    }];
    
}

-(void)selectDocBarButtonTapped
{
    isDateSelected = YES;
    // Scroll to original offset.
    [UIView animateWithDuration:0.2 animations:^{
        [scrollView setContentOffset:scrollPosition];
    }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    selectedDate = self.docDatePicker.date;
    //self.docDatePicker.hidden = YES;
    [formatter setDateFormat:@"dd MMM yyyy"];

    dateLabel.text = [formatter stringFromDate:self.docDatePicker.date];

    [self animateViewWithView:CGRectMake(self.frame.origin.x,580,320,300) particularView:presentchildView];
    [presentchildView removeFromSuperview];
    [dateBtn setUserInteractionEnabled:YES];
}
-(void)cancelBarButtonTapped
{
    // Scroll to original offset.
    [UIView animateWithDuration:0.2 animations:^{
        [scrollView setContentOffset:scrollPosition];
    }];
    
    [self animateViewWithView:CGRectMake(self.frame.origin.x,580,320,300) particularView:presentchildView];
    [presentchildView removeFromSuperview];
    [dateBtn setUserInteractionEnabled:YES];
    [self.docDatePicker setDate:selectedDate];
}
-(void)animateViewWithView:(CGRect)rect particularView:(UIView *)particularView
{
    [self bringSubviewToFront:particularView];
    [self addSubview:particularView];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    particularView.frame = rect;//
    [UIView commitAnimations];
}

#pragma mark TittleSelection
-(void)titleBtnTapped:(id)sender
{
  /*  [tagView.textView resignFirstResponder];
    [self endEditing:YES];
    CGRect rect = titleMilestoneView.frame;
    rect.origin.y = rect.size.height;
    titleMilestoneView.frame = rect;
    if(milestoneTitleLabel.text.length > 0)
        titleMilestoneView.textField.text = milestoneTitleLabel.text;
    else
        titleMilestoneView.textField.text = @"";
    titleMilestoneView.selectedName = titleMilestoneView.textField.text;
    [[[UIApplication sharedApplication] keyWindow] addSubview:titleMilestoneView];
    [titleMilestoneView openControl];
   */
}

- (void)mileStoneNameClick
{
  /*  if(titleMilestoneView.selectedName)
    {
        if ([titleMilestoneView.selectedName isEqualToString:@""])
        {
            milestoneTitleLabel.text = @"";
            btnMilestoneTitle.selected = NO;
            [starImage setImage:[UIImage imageNamed:@"star-unfilled.png"]];
            milestoneTitleLabel.hidden = YES;
        }
        else
        {
            btnMilestoneTitle.selected = YES;
            [starImage setImage:[UIImage imageNamed:@"star-filled.png"]];
            milestoneTitleLabel.text = titleMilestoneView.selectedName;
            milestoneTitleLabel.hidden = NO;
        }
    }
    else
    {
        if ([self.detailsDictionary objectForKey:@"new_title"] != nil && [[self.detailsDictionary objectForKey:@"new_title"] length] > 0)
        {
            btnMilestoneTitle.selected = NO;
            milestoneTitleLabel.text = [self.detailsDictionary objectForKey:@"new_title"];
           [starImage setImage:[UIImage imageNamed:@"star-filled.png"]];
            milestoneTitleLabel.hidden = NO;
        }
        else
        {
            btnMilestoneTitle.selected = NO;
            milestoneTitleLabel.text = @"";
            [starImage setImage:[UIImage imageNamed:@"star-unfilled.png"]];
            milestoneTitleLabel.hidden = YES;
        }
    }
   */
}

#pragma mark -
#pragma mark Image Methods

-(void)selectPhoto:(id)sender
{
    if([imagesArray count] >= 5)
        return;

   
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Photo", @"Video", nil];
    addImageActionSheet.tag = 1001;
    [addImageActionSheet setDelegate:self];
    
    if ( IDIOM == IPAD ) {
        
        [addImageActionSheet showFromRect:[(UIButton *)sender frame] inView:self animated:YES];
    }
    else {
        
        [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    }
    
}
#pragma mark- Aviary API Key Validation Method

- (BOOL) hasValidAPIKey
{
    if ([kAFAviaryAPIKey isEqualToString:@"<YOUR-API-KEY>"] || [kAFAviarySecret isEqualToString:@"<YOUR-SECRET>"])
    {
        UIAlertView *forgotKeyAlert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:@"You forgot to add your API key and secret!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
        self.globalAlert = forgotKeyAlert;
        
        [forgotKeyAlert show];
        return NO;
    }
    return YES;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1000:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        //Tracking
                        //[Flurry logEvent:@"Stream_Post_Camera"];
                        
                        isImageSelected = YES;
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        //[(AddPostViewController *)delegate presentViewController:imagePicker animated:YES completion:NULL];
                        photoFromCamera = TRUE;
                    }
                    else
                    {
                        isImageSelected = NO;
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't have a camera."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        self.globalAlert = alert;
                        
                        [alert show];
                    }
                    [self launchPicker];
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        //Tracking
                        //[Flurry logEvent:@"Stream_Post_CameraRoll"];
                        
                        isImageSelected = YES;
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        //[(AddPostViewController *)delegate presentViewController:imagePicker animated:YES completion:NULL];
                        photoFromCamera = FALSE;
                    }
                    else
                    {
                        isImageSelected = NO;
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't support photo libraries."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        self.globalAlert = alert;
                        
                        [alert show];
                    }
                    [self launchPicker];
                    break;
                }
                    
                case 2:
                {
                    //[Flurry logEvent:@"Stream_Post_PhotoCancel"];
                }
                default:
                    break;
            }
        }
            break;
        case 1001: {
            
            
            switch (buttonIndex)
            {
                case 0:
                {
                    if ([self hasValidAPIKey])
                    {
                        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                                      @"Take photo", @"Choose existing", nil];
                        addImageActionSheet.tag = 1000;
                        [addImageActionSheet setDelegate:self];
                        [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
                
                    }
                    
                }
                    break;
                case 1:
                    
                {
                    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                                          @"Record video", @"Choose existing", nil];
                    addImageActionSheet.tag = 1002;
                    [addImageActionSheet setDelegate:self];
                    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
                }
                    
                default:
                    break;
            }

        }
            break;
        case 1002:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    VideoRecordViewController *contactView = [storyBoard instantiateViewControllerWithIdentifier:@"VideoRecordViewController"];
                    contactView.delegate = self;
                    [(AddPostViewController *)self.delegate presentViewController:contactView animated:YES completion:NULL];
                    
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        videoPicker = [[UIImagePickerController alloc]init];
                        
                        isImageSelected = YES;
                        videoPicker.videoMaximumDuration = 60.0f;
                        videoPicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        videoPicker.delegate = self;
                        videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
                        videoPicker.allowsEditing = YES;

                        [(AddPostViewController *)self.delegate presentViewController:videoPicker animated:YES completion:NULL];
                    }
                    else
                    {
                        isImageSelected = NO;
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't support photo libraries."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        self.globalAlert = alert;
                        
                        [alert show];
                    }
                    break;
                }
                    
                case 2:
                {
                    //[Flurry logEvent:@"Stream_Post_PhotoCancel"];
                }
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    friendsImageView.hidden = NO;
                    visible.text = @"My Circle";
                    visible.frame = CGRectMake(137.5, 9, 122, 21);
                    isvisible = YES;
                    break;
                }
                case 1:
                {
                    friendsImageView.hidden = YES;
                    visible.text = @"only My Fam";
                    visible.frame = CGRectMake(136, 9, 142, 21);
                    isvisible = NO;
                    break;
                }                case 2:
                {
                    //[Flurry logEvent:@"Stream_Post_Visible_Cancel"];
                }
                default:
                    break;
            }
        }
            break;
            
            
        default:
            break;
    }
    
}
-(void)sliderValueChanged:(UISlider *)slider
{
   
}
- (void)sliderDidEndEditing:(UISlider *)slider
{
    if(slider.value <= 0.5)
    {
        isvisible = NO;

        slider.value = 0;
        //myCircle.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        //caregivers.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
        
    }
    else
    {
        isvisible = YES;

        slider.value = 1;
        //caregivers.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        //myCircle.textColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];

    }
}
-(void)launchPicker
{
    if (isImageSelected == YES)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [(AddPostViewController *)delegate presentViewController:imagePicker animated:YES completion:NULL];
        }else{

          
                
                [(AddPostViewController *)delegate dismissViewControllerAnimated:NO completion:nil];
                UIPopoverController *popover1 = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                [popover1 presentPopoverFromRect:attachPhotoBtn.frame inView:[(AddPostViewController *)delegate view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.popover = popover1;
                
            

        }
    }
}
- (void)videoRecordCompletedWithOutputUrl:(NSURL *)url {
    
    isImageSelected = NO;
    
    [imagesArray addObject:@{@"url":url}];
    [_collectionView reloadData];
    
    [_collectionView layoutIfNeeded];
    CGRect frame  = _collectionView.frame;
    
    frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
    _collectionView.frame = frame;
    

    contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);
    
}
#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AVYPhotoEditorController * photoEditor = [[AVYPhotoEditorController alloc] initWithImage:highResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage)
    {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    else
    {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:editingResImage];
    }
    
    // Present the photo editor.
    [(AddPostViewController *)delegate presentViewController:photoEditor animated:NO completion:^{ [HUD hide:YES];
        [HUD show:NO];
    }];
}

- (void) setupHighResContextForPhotoEditor:(AVYPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    id<AVYPhotoEditorRender> render = [photoEditor enqueueHighResolutionRenderWithImage:highResImage
                                                                             completion:^(UIImage *result, NSError *error) {
                                                                                 if (result) {
                                                                                 } else {
                                                                                     NSLog(@"High-res render failed with error : %@", error);
                                                                                 }
                                                                             }];
    
    
    // Provide a block to receive updates about the status of the render. This block will be called potentially multiple times, always
    // from the main thread.
    
    [render setProgressHandler:^(CGFloat progress) {
        NSLog(@"Render now %lf percent complete", round(progress * 100.0f));
    }];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [self finishedEditingImage:image];
    
    [(AddPostViewController *)delegate dismissViewControllerAnimated:YES completion:nil];

}

-(void)finishedEditingImage:(UIImage *)image
{
    //[Flurry logEvent:@"Stream_Photo_Done"];
    
    isFromThisView = YES;
    isImageSelected = NO;
    
    [[self imagePreviewView] setImage:image];
    [[self imagePreviewView] setContentMode:UIViewContentModeScaleAspectFit];
    
    
    NSString *contentType = @"image/jpeg";
    NSString *key = [NSString stringWithFormat:@"%@%@.jpeg",[[[ModelManager sharedModel] userProfile] teacher_klid],TimeStamp];
    
    UIImage *imageOrg1 =  image ;
    //    NSData *imageData1 = UIImagePNGRepresentation(imageOrg1);
    NSData *imageData1 = UIImageJPEGRepresentation(imageOrg1, 0.7);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:key];
    [imageData1 writeToFile:savedImagePath atomically:NO];

    [imagesArray addObject:@{@"url":[NSURL fileURLWithPath:savedImagePath]}];
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
    
    CGRect frame  = _collectionView.frame;
    
    frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
    _collectionView.frame = frame;
    

    contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);
}


// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    //[Flurry logEvent:@"Stream_Photo_Cancel"];
    [(AddPostViewController *)delegate dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AVYPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    // kAFStickers
    // NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    
    NSArray * toolOrder = @[kAVYOrientation , kAVYCrop, kAVYEffects, kAVYFrames, kAVYEnhance, kAVYColorAdjust, kAVYLightingAdjust, kAVYFocus];
    [AVYPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AVYPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAVYCropPresetHeight : @(4.0f), kAVYCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAVYCropPresetHeight : @(5.0f), kAVYCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAVYCropPresetName: @"Square", kAVYCropPresetHeight : @(1.0f), kAVYCropPresetWidth : @(1.0f)};
    [AVYPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AVYPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if(picker == videoPicker)
    {
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        
        NSTimeInterval durationInSeconds = 0.0;
        if (asset)
            durationInSeconds = CMTimeGetSeconds(asset.duration);

        if(durationInSeconds <= 60)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4",[paths objectAtIndex:0],TimeStamp];
        
            [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:[NSURL fileURLWithPath:videoPath]];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [(AddPostViewController *)delegate dismissViewControllerAnimated:NO completion:nil];
            }else{
                
                [self.popover dismissPopoverAnimated:YES ];
    
            }


        }
        else
        {
            UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a video under a minute." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            self.globalAlert = disableAlert;
            [disableAlert show];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [(AddPostViewController *)delegate dismissViewControllerAnimated:NO completion:nil];
            }else{
                
                [self.popover dismissPopoverAnimated:YES ];
                
                
            }

            

        }
        
        
        
    }
    else
    {
        
    
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    
    HUD.delegate = self;
    [HUD hide:NO];
    [HUD show:YES];
    
    
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset)
         {
             if (asset)
             {
                 [self launchEditorWithAsset:asset];
                 
                 
             }
             else
             {
                 
                 [self launchPhotoEditorWithImage:info[UIImagePickerControllerOriginalImage] highResolutionImage:info[UIImagePickerControllerOriginalImage]];
             }
         }
                            failureBlock:^(NSError *error) {
                                [HUD hide:YES];
                                [HUD show:NO];
                                UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                self.globalAlert = disableAlert;
                                [disableAlert show];
                            }];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [(AddPostViewController *)delegate dismissViewControllerAnimated:NO completion:completion];
    }else{
        
        [self.popover dismissPopoverAnimated:YES ];

        
        UIImage * origImage = info[UIImagePickerControllerOriginalImage];
        [self finishedEditingImage:origImage];
    
    }
        
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [(AddPostViewController *)delegate dismissViewControllerAnimated:YES completion:nil];
    else
        [self.popover dismissPopoverAnimated:YES ];
}

#pragma mark - Popover Methods

- (void) presentViewControllerInPopover:(UIViewController *)controller
{
    CGRect sourceRect = [[self attachPhotoBtn] frame];
    UIPopoverController *popover1 = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popover1 setDelegate:self];
    [self setPopover:popover1];
    [self setShouldReleasePopover:YES];
    
    [popover1 presentPopoverFromRect:sourceRect inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void) dismissPopoverWithCompletion:(void(^)(void))completion
{
    [[self popover] dismissPopoverAnimated:YES];
    [self setPopover:nil];
    
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        completion();
    });
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([self shouldReleasePopover]){
        [self setPopover:nil];
    }
    [self setShouldReleasePopover:YES];
}

#pragma mark - ALAssets Helper Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }else{
        return YES;
    }
}

- (BOOL) shouldAutorotate
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setShouldReleasePopover:NO];
    [[self popover] dismissPopoverAnimated:YES];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self popover]) {
        CGRect popoverRef = [[self attachPhotoBtn] frame];
        [[self popover] presentPopoverFromRect:popoverRef inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



#pragma mark- MilestoneImageUploadManagerDelegate Methods
#pragma mark-
- (void)didReceiveMilestoneImageUpload:(NSDictionary *)milestone
{
    uploadingImages --;
    if(uploadingImages == 0 && isPostClicked)
    {
        isImageUploading = NO;
        isPostClicked = NO;
        
        [imagesArray addObject:[[milestone objectForKey:@"body"] objectForKey:@"key"]];
        
        [self createMilestone];
    }
    else
    {
      
        [imagesArray addObject:[[milestone objectForKey:@"body"] objectForKey:@"key"]];
        HUD.hidden = YES;
    }
    
    if([[milestone objectForKey:@"body"] objectForKey:@"fb_url"] != (id)[NSNull null] && [[milestone objectForKey:@"body"] objectForKey:@"fb_url"]>0)
    {
        imageURL = [[milestone objectForKey:@"body"] objectForKey:@"fb_url"];
    }
    //always set which is good
//    [[SingletonClass sharedInstance] setAttachedImageForInstagram:selectedImage];
    isImageProcessing = NO;
}
- (void)fetchingCreateMilestoneImageUploadFailedWithError:(NSError *)error
{
    uploadingImages --;
    [HUD hide:NO];
    isImageProcessing = NO;
    
    if(uploadingImages == 0 && isPostClicked)
    {
        isImageUploading = NO;
        isPostClicked = NO;
        [self createMilestone];
    }
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
    
}

-(void)destroyView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FACEBOOK_CHECK object:nil];
}

#pragma mark -
#pragma mark Email Methods
- (void)displayMailComposerSheet
{
/*    if([titleMilestoneView.textField.text length] == 0)
    {
        UIAlertView *emptyAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Please select title before sharing" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        self.globalAlert = emptyAlert;
        
        [emptyAlert show];
        return;
    }
    if(selectedImage == nil && tagView.textView.text.length == 0 )
    {
        UIAlertView *emptyAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Please add photo or enter milestone details before sharing" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        self.globalAlert = emptyAlert;
        
        [emptyAlert show];
        return;
        
    }
    
    //[Flurry logEvent:@"Stream_Post_Social_Email"];
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.delegate = self;
    [HUD hide:NO];
    [HUD show:YES];
    
    [shareEmailBtn setEnabled:NO];
    [shareEmailBtn setUserInteractionEnabled:NO];
    [shareEmailBtn setAlpha:0.2];
    if([MFMailComposeViewController canSendMail])
    {
        
        mailComposer= [[MFMailComposeViewController alloc] init];
        [self.mailComposer setMailComposeDelegate:self];
        [self.mailComposer setSubject:@"TingrSCHOOL"];
        
        ///////Attaching image//////////
        if(selectedImage != nil)
        {
            NSData *imageData;
            imageData = UIImagePNGRepresentation(selectedImage);
            [self.mailComposer  addAttachmentData:imageData mimeType:@"image/png" fileName:@"photo"];
        }
        
        //////Attaching Description
        
        NSMutableString *attachText = [NSMutableString string];
        if(!milestoneTitleLabel.hidden)
        {
            [attachText appendString:milestoneTitleLabel.text];
            [self.mailComposer setSubject:[NSString stringWithFormat:@"KidsLink Milestone: %@",milestoneTitleLabel.text]];
            
        }
        else
        {
            [self.mailComposer setSubject:@"View my KidsLink moment"];
        }
        if(tagView.textView.text.length > 0)
        {
            [attachText appendString:@"\n"];
            [attachText appendString:tagView.textView.text];
        }
        
        //
        //        NSString *styles = @"<style type='text/css'>body { font-family: 'HelveticaNeue-Light'; font-size: 20px; color: #7b7a7a; margin: 0; padding: 0; }</style>";
        //        NSString *htmlMsg = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>",styles,attachText];
        [self.mailComposer setMessageBody:attachText isHTML:NO];
        
        self.mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [(AddPostViewController *)delegate presentViewController:self.mailComposer animated:YES completion:^{
            [HUD hide:YES];
            [HUD show:NO];
            [shareEmailBtn setEnabled:YES];
            [shareEmailBtn setUserInteractionEnabled:YES];
            [shareEmailBtn setAlpha:1.0];
            
            
        }];
    }
    else
    {
        [shareEmailBtn setEnabled:YES];
        [shareEmailBtn setUserInteractionEnabled:YES];
        [shareEmailBtn setAlpha:1.0];
        
        [HUD hide:YES];
        [HUD show:NO];
        [HUD removeFromSuperview];
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:@"Mail client not configured on this device. Add a mail account in your device Settings to send an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.globalAlert = alert;
        [alert show];
    }
 */
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString *messageStr = nil;
    switch (result){
            
        case MFMailComposeResultSaved:; //Mail is saved
            messageStr = @"Email saved successfully";
            break;
            
        case MFMailComposeResultSent:; //Mail is sent
            messageStr = @"Email sent successfully";
            break;
            
            
        case MFMailComposeResultFailed:;    //Mail sending id failed.
            //messageStr = @"Email sending failed";
            break;
            
        case MFMailComposeResultCancelled: break; //If we click on the cancle.
            
        default: break;
            
    }
    [(AddPostViewController *)delegate dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled )
    {
        [HUD hide:YES];
        [HUD show:NO];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.globalAlert = alert;
        [alert show];
    }
    
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
{
    [Spinner showIndicator:YES];
  
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=outputURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch (exporter.status)
         {
             case AVAssetExportSessionStatusCompleted:
             {
                 
                 [[NSFileManager defaultManager] removeItemAtURL:inputURL error:nil];
                 NSLog(@"Video Merge SuccessFullt");
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [Spinner showIndicator:NO];
                     
                     
                     isImageSelected = NO;
                     
                     [imagesArray addObject:@{@"url":outputURL}];
                     [_collectionView reloadData];
                     [_collectionView layoutIfNeeded];
                     CGRect frame  = _collectionView.frame;
                     frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
                     _collectionView.frame = frame;
                     
                     contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
                     scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);

                 });
                 
             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@", exporter.error.description);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@", exporter.error);
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"Exporting!");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"Waiting");
                 break;
             default:
                 break;
         }
     }];
    
    
    
    //setup video writer
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark KidTableForTagging
-(void)addkidTableForTagging {
    
    UILabel *chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 133, Devicewidth-28, 24)];
    NSString *content = @"Who is in this post?";
    
    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    UIFont *italicFont = [UIFont fontWithName:@"HelveticaNeue-Italic" size:13];
    
    if ( IDIOM == IPAD ) {

        normalFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
        italicFont = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16];

    }
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:normalFont};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content   attributes:attributes];
    
    
    chooseLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

    chooseLabel.attributedText= attributedString;
    
    [contentDetailsView addSubview:chooseLabel];
    
    UIButton *selectAllBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllBtn setTitle:@"SELECT ALL" forState:UIControlStateNormal];
    [selectAllBtn addTarget:self action:@selector(selectAllTapped) forControlEvents:UIControlEventTouchUpInside];
    [selectAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectAllBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13]];
    selectAllBtn.frame = CGRectMake(contentDetailsView.frame.size.width-110, 144, 100, 30);
    [contentDetailsView addSubview:selectAllBtn];
    

    
    kidTableView = [[UITableView alloc] initWithFrame:CGRectMake(14, 174, Devicewidth-28, contentDetailsView.frame.size.height-174)];
    kidTableView.scrollEnabled = NO;
    kidTableView.delegate = self;
    kidTableView.dataSource = self;
    kidTableView.tableFooterView = [[UIView alloc] init];
    [contentDetailsView addSubview:kidTableView];
    
    kidTableView.frame = CGRectMake(14, 174, Devicewidth-28, kidTableView.contentSize.height);
    CGRect frame = contentDetailsView.frame;
    frame.size.height = kidTableView.contentSize.height+174;
    contentDetailsView.frame = frame;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sharedInstance.profileKids.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *reuseIdentifier = @"RemindersCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    UIImageView *selectImage;
    UIImageView *profileImageView;
    UILabel *nameLabel;
    
    if (cell == nil) {
        
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
        
        selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-60, 12, 20, 20)];
        selectImage.tag = 200;
        [cell.contentView addSubview:selectImage];
        
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 30, 30)];
        profileImageView.tag = 201;
        [cell.contentView addSubview:profileImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 7, 200, 30)];
        nameLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        nameLabel.tag = 202;
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        if ( IDIOM == IPAD ) {

            nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        }
        [cell.contentView addSubview:nameLabel];


    }
    else {
        
        selectImage = (UIImageView *)[cell.contentView viewWithTag:200];
        nameLabel = (UILabel *)[cell.contentView viewWithTag:202];
        profileImageView = (UIImageView *)[cell.contentView viewWithTag:201];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    NSDictionary *kidDict = sharedInstance.profileKids[indexPath.row];
    
    NSString *displayName;
    NSString *shortString;
    
    NSString *parentFname = [kidDict valueForKey:@"fname"];
    NSString *parentLname = [kidDict valueForKey:@"lname"];

    if (parentFname.length>0 && parentLname.length >0)
    {
        displayName = [NSString stringWithFormat:@"%@ %@",parentFname,parentLname];
        shortString = [NSString stringWithFormat:@"%@%@",[[parentFname substringToIndex:1] uppercaseString],[[parentLname substringToIndex:1] uppercaseString]];
    }
    else if(parentFname.length >0)
    {
        displayName = parentFname;
        shortString = [NSString stringWithFormat:@"%@",[[parentFname substringToIndex:1] uppercaseString]];

    }
    else if(parentLname.length >0)
    {
        displayName = parentLname;
        shortString = [NSString stringWithFormat:@"%@",[[parentLname substringToIndex:1] uppercaseString]];

    }
    else if([[kidDict valueForKey:@"nickname"] length] >0)
    {
        displayName = [kidDict valueForKey:@"nickname"];
        
        shortString = [NSString stringWithFormat:@"%@",[[[kidDict valueForKey:@"nickname"] substringToIndex:1] uppercaseString]];

    }
    
    nameLabel.text = displayName;
    
    if([selectedArray containsObject:[kidDict objectForKey:@"kid_klid"] ])
    {
        selectImage.image = [UIImage imageNamed:@"selected"];
    }
    else
    {
        selectImage.image = [UIImage imageNamed:@"not_selcted"];

    }
    
    
    __weak UIImageView *weakSelf = profileImageView;
    for(UIView *view in [weakSelf subviews])
    {
        [view removeFromSuperview];
    }
    NSString *url = [kidDict valueForKey:@"photograph_url"];
    if(url != (id)[NSNull null] && url.length > 0)
    {

        
        [weakSelf setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfile.png"] scaledToSize:CGSizeMake(30,30)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0];
             
         }
                                     failure:nil];
    }
    else
    {
        profileImageView.image = [UIImage imageNamed:@"EmptyProfile.png"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:profileImageView.bounds];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        label.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = shortString;
        [profileImageView addSubview:label];
        
    }
    

    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *kidDict = sharedInstance.profileKids[indexPath.row];

   
    
        
        if([selectedArray containsObject:[kidDict objectForKey:@"kid_klid"] ])
        {
            [selectedArray removeObject:[kidDict objectForKey:@"kid_klid"]];
        }
        else
        {
            [selectedArray addObject:[kidDict objectForKey:@"kid_klid"]];
        }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    
}


-(void)getPresignedURLWithFileUrl:(NSURL *)fileURL withKey:(NSString *)key contentType:(NSString *)contentType{
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    
    
    
    NSMutableDictionary *newImageDetails  = [NSMutableDictionary dictionary];
    
    [newImageDetails setValue:key     forKey:@"asset_key"];
    [newImageDetails setValue:contentType     forKey:@"content_type"];
    
    NSString *command = @"upload_endpoint";
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": userProfile.auth_token,
                               @"command": command,
                               @"body": newImageDetails};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    __weak MilestoneView *weakSelf = self;
    
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        if(weakSelf)
        {
            NSURL *signedURL = [NSURL URLWithString:[[[json objectForKey:@"response"] objectForKey:@"body"] objectForKey:@"endpoint_url"]];
            [[PostDataUpload sharedInstance] uploadFromUrl:fileURL withSignedURL:signedURL withKey:key contentType:contentType];
        }
        
    } failure:^(NSDictionary *json) {
        
        
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(imagesArray.count > 0)
    {
     
        return imagesArray.count+1;
    }
    else {
        return 2;
    }
    
}

-(void)selectAllTapped {
    
    [selectedArray removeAllObjects];
    for(NSDictionary *kidDict in sharedInstance.profileKids) {
        
        [selectedArray addObject:[kidDict objectForKey:@"kid_klid"]];
    }
    [kidTableView reloadData];
    
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    if(indexPath.row == 0)
    {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
        
        UIImageView *thumbImageView = (UIImageView *)[cell viewWithTag:1];
        if(thumbImageView != nil)
        {
            [thumbImageView setImage:[UIImage imageNamed:@"new_plus"]];
        }
        else {
            
            thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 81, 76)];
            [thumbImageView setImage:[UIImage imageNamed:@"new_plus"]];
            thumbImageView.tag = 1;
            [cell addSubview:thumbImageView];
        }
        
        cell.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        cell.layer.shadowOffset = CGSizeMake(0, 1);
        cell.layer.shadowOpacity = 1;
        cell.layer.shadowRadius = 1.0;
        cell.clipsToBounds = YES;

        
    }
    else if(imagesArray.count == 0 && indexPath.row == 1){
     
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"textCell" forIndexPath:indexPath];
        
        addTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _collectionView.frame.size.width-(81+10), 76)];
        [scrollView addSubview:addTextView];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:addTextView.bounds];
        [addTextView addSubview:label1];
        label1.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
        label1.textColor = [UIColor lightGrayColor];
        label1.numberOfLines = 0;
        label1.text = @"a picture is worth a thousand words\n\n\nclick '+' to add as many photos and videos you like";
        label1.textAlignment = NSTextAlignmentCenter;
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake((addTextView.frame.size.width-20)/2, (addTextView.frame.size.height-20)/2-5, 20, 20)];
        [addTextView addSubview:label2];
        label2.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        label2.textColor = [UIColor lightGrayColor];
        label2.numberOfLines = 0;
        label2.text = @"+";
        label2.textAlignment = NSTextAlignmentCenter;

        [cell addSubview:addTextView];

    }
    else {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

        UIImageView *thumbImageView = (UIImageView *)[cell viewWithTag:1];
        
        NSDictionary *detailDict = imagesArray[indexPath.row-1];
        
        NSString *key = [detailDict objectForKey:@"key"];
        NSURL *url = [detailDict objectForKey:@"url"];
        
        if(thumbImageView == nil)
        {
            thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 81, 76)];
            thumbImageView.tag = 1;
            [cell addSubview:thumbImageView];
        }
        if(key != nil && key.length > 0) {
            
            [thumbImageView setImageWithURL:url placeholderImage:nil];
        }
        else {
            
            if([[[url absoluteString] lowercaseString] containsString:@".jpeg"]) {
                
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];
                thumbImageView.image = img;
            }
            else {
             
                
                AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *assetImageGemerator = [[AVAssetImageGenerator alloc] initWithAsset:movieAsset];
                assetImageGemerator.appliesPreferredTrackTransform = YES;
                CGImageRef frameRef = [assetImageGemerator copyCGImageAtTime:CMTimeMake(1, 2) actualTime:nil error:nil];
                UIImage *image = [[UIImage alloc] initWithCGImage:frameRef];
                thumbImageView.image = image;

            }

        }
            
        

        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //seconds
        [cell.contentView addGestureRecognizer:lpgr];

        
        cell.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        cell.layer.shadowOffset = CGSizeMake(0, 1);
        cell.layer.shadowOpacity = 1;
        cell.layer.shadowRadius = 1.0;
        cell.clipsToBounds = YES;

    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 1 && imagesArray.count == 0)
        return CGSizeMake(_collectionView.frame.size.width-(81+10), 76);
    else
        return CGSizeMake(81, 76);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        [self selectPhoto:nil];
    }
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateEnded) {
        
        
        
        
    } else if (longPress.state == UIGestureRecognizerStateBegan) {
        
        UICollectionViewCell *cell = (UICollectionViewCell *)[longPress.view superview];
        NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
        selectedIndex = (int)indexPath.row;
        if(selectedIndex == 0)
            return;
        else
            selectedIndex -= 1;
            
        NSDictionary *details = imagesArray[selectedIndex];
        NSString *url = [[details objectForKey:@"url"] absoluteString];
        NSString *title;
        NSString *message;
        
        
        if([[url lowercaseString] containsString:@".jpeg"])
        {
         
            title = @"Remove image?";
            message = @"Do you want to remove this image from post?";
        }
        else {
            
            title = @"Remove video?";
            message = @"Do you want to remove this video from post?";

        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
           
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *remove = [UIAlertAction actionWithTitle:@"Remove" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                //action on click
                
                [imagesArray removeObjectAtIndex:selectedIndex];
                [_collectionView reloadData];
                [_collectionView layoutIfNeeded];
                CGRect frame  = _collectionView.frame;
                
                frame.size.height = _collectionView.collectionViewLayout.collectionViewContentSize.height;
                _collectionView.frame = frame;
                
                
                contentDetailsView.frame = CGRectMake(0, _collectionView.collectionViewLayout.collectionViewContentSize.height+24, Devicewidth, contentDetailsView.frame.size.height);
                scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentDetailsView.frame.origin.y+contentDetailsView.frame.size.height);

            }];
            
            UIAlertAction *cancel_action=[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertController addAction:remove];
            [alertController addAction:cancel_action];
            
            
            // Remove arrow from action sheet.
            [alertController.popoverPresentationController setPermittedArrowDirections:0];
            //For set action sheet to middle of view.
            CGRect rect = self.frame;
            rect.origin.x = self.frame.size.width / 20;
            rect.origin.y = self.frame.size.height / 20;
            alertController.popoverPresentationController.sourceView = self;
            alertController.popoverPresentationController.sourceRect = rect;
            
            [(AddPostViewController *)self.delegate presentViewController:alertController animated:YES completion:nil];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                           message:message
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Remove", nil];
            alert.tag = 1;
            [alert show];

            
        }
    }
    
}

@end
