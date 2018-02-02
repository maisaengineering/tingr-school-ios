//
//  KidProfileView.m
//  KidsLink
//
//  Created by Dale McIntyre on 4/13/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "KidProfileView.h"
#import "KidProfileSimpleLayout.h"
#import "KidProfileMultiLayout.h"
//#import "KidProfileEdit.h"
#import "Base64.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "KidProfileDocDentLayout.h"
#import "AlertUtils.h"
#import "ParentLayout.h"
@interface KidProfileView()



@end

@implementation KidProfileView
{
    UIImageView *profileImage;
    UIScrollView *childDetailsScrollView;
    UIView *modalParent;
    UIView *editButtonsParent;
    UIButton *btnEditSave;
    UIButton *btnEditCancel;
  //  KidProfileEdit *kidProfileEdit;
    UILabel *lblEyes;
    UILabel *lblIdea;
    UILabel *lblIdeaDetail;
    UIImageView *exception_indicator;
    UITapGestureRecognizer *singleTap;
    //form fields
    UILabel *lblName;
    UILabel *lblAge;
    KidProfileSimpleLayout *nameLayout;
    KidProfileSimpleLayout *preferredLayout;
    KidProfileSimpleLayout *birthdayLayout;
    KidProfileSimpleLayout *ageLayout;
    KidProfileSimpleLayout *genderLayout;
    KidProfileMultiLayout *addressLayout;
    KidProfileMultiLayout *otherDetailsLayout;
    KidProfileDocDentLayout *doctorLayout;
    KidProfileDocDentLayout *dentistLayout;
    KidProfileMultiLayout *medicinesLayout;
    KidProfileMultiLayout *allergiesLayout;
    KidProfileMultiLayout *drugAllergiesLayout;
    KidProfileMultiLayout *medIssuesLayout;
    KidProfileMultiLayout *specialNeedsLayout;
    KidProfileMultiLayout *otherHealthLayout;
    NSMutableArray *sessions;
    BOOL animated;
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *photoDateUtils;
    AppDelegate *appDelegate;
    //it is used to hold the number of doctor or dentist
    NSString *phoneNumber;
}

@synthesize person;
@synthesize mailComposer;
@synthesize parent;
@synthesize imagePreviewView;
@synthesize singletonObj;
@synthesize borderView;
@synthesize lblProfileEditName;
@synthesize  assetLibrary;
@synthesize  sessions;
@synthesize myowner;

// for aviary
@synthesize btnProfileEditPhoto;
@synthesize popover;
@synthesize shouldReleasePopover;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;
@synthesize HUD;

- (void)baseInit {
    
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    //create the center uiview
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    
    photoUtils = [ProfilePhotoUtils alloc];
    photoDateUtils = [ProfileDateUtils alloc];
    
    animated = FALSE;
    
    [self setBackgroundColor:[UIColor colorWithRed:(0/255.f) green:(0/255.f) blue:(0/255.f) alpha:0]];
    
    //this is the background modal screen
    modalParent = [[UIView alloc] initWithFrame:CGRectMake(0,screenHeight,screenWidth,screenHeight)];
    
    [self addSubview:modalParent];
    
    float yPosition = appDelegate.topSafeAreaInset > 0 ?appDelegate.topSafeAreaInset:20;
    
    //this is the white screen
    profileParent = [[UIView alloc] initWithFrame:CGRectMake(20,yPosition,screenWidth - 40,screenHeight-20-yPosition)];
    [profileParent setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
    profileParent.layer.cornerRadius = 5;
    profileParent.layer.masksToBounds = YES;
    [modalParent addSubview:profileParent];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnClose setImage:[UIImage imageNamed:@"btnKidProfileClose.png"] forState:UIControlStateNormal];
    btnClose.frame = CGRectMake(profileParent.frame.size.width - 40, 10, 35, 35);
    [profileParent addSubview:btnClose];
    
    profileImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyProfile.png"]];
    profileImage.frame = CGRectMake(20,20,100,100);
    [profileParent addSubview:profileImage];
    [self AddPhotoToControl];
    
    lblName = [[UILabel alloc] initWithFrame: CGRectMake(135, 45, 125, 45)];
    lblName.text = [self.person valueForKey:@"nickname"];
    lblName.font =[UIFont fontWithName:@"Archer-MediumItalic" size:30];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    lblName.textColor = [UIColor colorWithRed:(72/255.f) green:(187/255.f) blue:(234/255.f) alpha:1];
    [profileParent addSubview:lblName];
    
    // Changed as per the new requirement #90258522
    // Changed the width to avoid the word cut off
    lblAge = [[UILabel alloc] initWithFrame: CGRectMake(135, 80, 140, 25)];
    
    NSString *serverDateStr = [NSString stringWithFormat:@"%@",[self.person valueForKey:@"birthdate"]];
    
    NSString *deviceDateStr = [self getTodaysDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *serverDate = [dateFormatter dateFromString:serverDateStr];
    NSDate *deviceDate = [dateFormatter dateFromString:deviceDateStr];
    
    
    if ([serverDate compare:deviceDate] == NSOrderedDescending)
    {
        // future
        //deviceDate is old than Server date.
        // if the date is future date, then get the month and date in the required format
        NSDate *date = serverDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MMM d"];
        NSString *dateString = [dateFormat stringFromDate:date];
        lblAge.text = [NSString stringWithFormat:@"due %@",dateString];
    }
    else if ([serverDate compare:deviceDate] == NSOrderedAscending)
    {
        // old
        // Server date is old than deviceDate
        
        NSString *start = serverDateStr; //@"2010-09-01";
        NSString *end = deviceDateStr;   //@"2010-12-01";
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"MM/dd/yyyy"];
        
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        endDate =  [endDate dateByAddingTimeInterval:60*60*24*1];
        
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:startDate
                                           toDate:endDate
                                           options:0];
        
        NSString *suffix = @"";
        NSInteger prefix = 0;
        
        if(ageComponents.year > 1)
        {
            prefix = ageComponents.year;
            suffix = @"years old";
        }
        else if(ageComponents.year == 1||ageComponents.month > 0)
        {
            prefix = ageComponents.year*12+ageComponents.month;
            suffix = prefix > 1?@"months old":@"month old";
        }
        else if(ageComponents.day == 1)
        {
            prefix = ageComponents.day;
            suffix = @"day old";
        }
        else  if(ageComponents.day > 1)
        {
            prefix = ageComponents.day;
            suffix = @"days old";
        }
        
        NSString *finalAge = [NSString stringWithFormat:@"%ld %@", (long)prefix, suffix];
        
        lblAge.text = finalAge;
    }
    else if([serverDate compare:deviceDate] == NSOrderedSame)
    {
        DebugLog(@"today");
        // Here, checking the response date is matches with current date. then displayed as 1 day
        lblAge.text =  @"1 day old";
    }
    
    lblAge.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:17];
    [lblAge setTextAlignment:NSTextAlignmentLeft];
    lblAge.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [profileParent addSubview:lblAge];
    
    //loop through and add all the sub controls here
    //put a scroll view in it first
    [self resetFormData];
    //this is the edit buttons
    
    
    
    //label
    lblProfileEditName = [[UILabel alloc] initWithFrame: CGRectMake(20, 7, 200, 30)];
    lblProfileEditName.text = [[self.person valueForKey:@"nickname"] stringByAppendingString:@"'s details"];
    lblProfileEditName.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    [lblProfileEditName setTextAlignment:NSTextAlignmentLeft];
    lblProfileEditName.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [editButtonsParent addSubview:lblProfileEditName];
    
    //label
    lblEyes= [[UILabel alloc] initWithFrame: CGRectMake(20, 32, 200, 30)];
    lblEyes.text = @"who can see? family, caregivers, schools, etc.";
    lblEyes.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:12];
    lblEyes.numberOfLines = 2;
    [lblEyes setTextAlignment:NSTextAlignmentLeft];
    lblEyes.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [editButtonsParent addSubview:lblEyes];
    
    //image 40x13
  /*  exception_indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exception_indicator.png"]];
    exception_indicator.frame = CGRectMake(138,36,40,13);
    [editButtonsParent addSubview:exception_indicator];
  */

    //label
    lblIdea = [[UILabel alloc] initWithFrame: CGRectMake(20, 53.5, 200, 30)];
    lblIdea.text = @"Idea:";
    lblIdea.font =[UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    [lblIdea setTextAlignment:NSTextAlignmentLeft];
    lblIdea.textColor = [UIColor colorWithRed:(72/255.f) green:(187/255.f) blue:(234/255.f) alpha:1];
    [editButtonsParent addSubview:lblIdea];
    
    //label
    lblIdeaDetail = [[UILabel alloc] initWithFrame: CGRectMake(55, 55, 200, 30)];
    lblIdeaDetail.text = @"Share with your babysitter via email";
    lblIdeaDetail.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:13];
    [lblIdeaDetail setTextAlignment:NSTextAlignmentLeft];
    lblIdeaDetail.textColor = [UIColor colorWithRed:(72/255.f) green:(187/255.f) blue:(234/255.f) alpha:1];
    [editButtonsParent addSubview:lblIdeaDetail];
    
    UIButton *btnProfileEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnProfileEdit addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnProfileEdit setImage:[UIImage imageNamed:@"btnProfileEdit.png"] forState:UIControlStateNormal];
    btnProfileEdit.frame = CGRectMake(20, 90, 50, 22);
    [editButtonsParent addSubview:btnProfileEdit];
    
    btnProfileEditPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnProfileEditPhoto addTarget:self action:@selector(editPhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnProfileEditPhoto setImage:[UIImage imageNamed:@"btnProfileEditPhoto.png"] forState:UIControlStateNormal];
    btnProfileEditPhoto.frame = CGRectMake(100, 90, 99, 20);
    [editButtonsParent addSubview:btnProfileEditPhoto];
    
    btnProfileShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnProfileShare addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnProfileShare setImage:[UIImage imageNamed:@"btnProfileShare.png"] forState:UIControlStateNormal];
    btnProfileShare.frame = CGRectMake(220, 90, 73, 20);
    [btnProfileShare setEnabled:YES];
    [btnProfileShare setUserInteractionEnabled:YES];
    [btnProfileShare setAlpha:1.0];
    [editButtonsParent addSubview:btnProfileShare];
    
    //TODO: Move these to a custom contrl
    btnEditSave = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnEditSave addTarget:self action:@selector(editSaveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnEditSave.frame = CGRectMake(202, 20, 63, 31);
    [btnEditSave setImage:[UIImage imageNamed:@"btnEditSave.png"] forState:UIControlStateNormal];
    //btnEditSave.backgroundColor = [UIColor redColor];
    
    
    btnEditSave.alpha = 0;
    [editButtonsParent addSubview:btnEditSave];
    
    btnEditCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEditCancel addTarget:self action:@selector(editCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnEditCancel.frame = CGRectMake(253, 20, 60, 31);
    [btnEditCancel setImage:[UIImage imageNamed:@"btnEditCancel.png"] forState:UIControlStateNormal];
    //btnEditCancel.backgroundColor = [UIColor blueColor];
    btnEditCancel.alpha = 0;
    [editButtonsParent addSubview:btnEditCancel];
    
    
    
    
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];
    
    // Allocate Sessions Array
    NSMutableArray * sessions1 = [NSMutableArray new];
    [self setSessions:sessions1];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    
    
    [profileParent addGestureRecognizer:singleTap];
    
}
/*
 - (void)removeFromSuperview
 {
 self.globalAlert = nil;
 }
 */
-(NSString *)getTodaysDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
    //DebugLog(@"Todays date is = %@",dateString);
}
#pragma mark- UITapGestureRecognizer Method
#pragma mark-
- (void)oneTap:(UIGestureRecognizer *)gesture
{
    if (animated == FALSE)
    {
        animated = TRUE;
        [self animateBottomDown];
    }
    else if (animated == TRUE)
    {
        animated = FALSE;
        [self animateBottomUp];
    }
}
-(void)didFetchKidInfo:(NSDictionary *)kidInfo
{
    
}

-(void)resetFormData
{
    lblName.text = [self.person valueForKey:@"nickname"];
    self.parent.lblName.text = [self.person valueForKey:@"nickname"];
    self.parent.lblGrouping.text = [self.person valueForKey:@"nickname"];
    lblProfileEditName.text = [[self.person valueForKey:@"nickname"] stringByAppendingString:@"'s details"];
    
    NSString *serverDateStr = [NSString stringWithFormat:@"%@",[self.person valueForKey:@"birthdate"]];
    NSString *deviceDateStr = [self getTodaysDate];
    
    // Changed as per the new requirement #90258522
    DebugLog(@"serverDateStr--%@",serverDateStr);
    DebugLog(@"deviceDateStr--%@",deviceDateStr);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *serverDate = [dateFormatter dateFromString:serverDateStr];
    NSDate *deviceDate = [dateFormatter dateFromString:deviceDateStr];
    
    
    if ([serverDate compare:deviceDate] == NSOrderedDescending)
    {
        // future
        //deviceDate is old than Server date
        
        NSDate *date = serverDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MMM d"];
        NSString *dateString = [dateFormat stringFromDate:date];
        lblAge.text = [NSString stringWithFormat:@"due %@",dateString];
    }
    else if ([serverDate compare:deviceDate] == NSOrderedAscending)
    {
        // old
        // Server date is old than deviceDate
        
        NSString *start = serverDateStr; //@"2010-09-01";
        NSString *end = deviceDateStr;   //@"2010-12-01";
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"MM/dd/yyyy"];
        
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        endDate =  [endDate dateByAddingTimeInterval:60*60*24*1];
        
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                           fromDate:startDate
                                           toDate:endDate
                                           options:0];
        
        NSString *suffix = @"";
        NSInteger prefix = 0;
        
        if(ageComponents.year > 1)
        {
            prefix = ageComponents.year;
            suffix = @"years old";
        }
        else if(ageComponents.year == 1||ageComponents.month > 0)
        {
            prefix = ageComponents.year*12+ageComponents.month;
            suffix = prefix > 1?@"months old":@"month old";
        }
        else if(ageComponents.day == 1)
        {
            prefix = ageComponents.day;
            suffix = @"day old";
        }
        else  if(ageComponents.day > 1)
        {
            prefix = ageComponents.day;
            suffix = @"days old";
        }
        
        NSString *finalAge = [NSString stringWithFormat:@"%ld %@", (long)prefix, suffix];
        
        lblAge.text = finalAge;
    }
    else if([serverDate compare:deviceDate] == NSOrderedSame)
    {
        DebugLog(@"today");
        // Here, checking the response date is matches with current date. then displayed as 1 day
        lblAge.text =  @"1 day old";
    }
    
    //create the center uiview
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [childDetailsScrollView removeFromSuperview];
    childDetailsScrollView = nil;
    childDetailsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 140, screenWidth, screenHeight-140)];
    childDetailsScrollView.delegate = self;
    childDetailsScrollView.userInteractionEnabled=YES;
    
    [profileParent addSubview:childDetailsScrollView];
    [childDetailsScrollView addGestureRecognizer:singleTap];
    
    int spacingBetween = 15;
    int startingY = 0;
    
    nameLayout = [KidProfileSimpleLayout alloc];
    nameLayout.layout_label = @"Full Name";
    nameLayout.layout_value = [NSString stringWithFormat:@"%@ %@ %@", [self.person valueForKey:@"fname"], [self.person valueForKey:@"mname"], [self.person valueForKey:@"lname"]];
    nameLayout = [nameLayout initWithFrame:CGRectMake(0,startingY,screenWidth,40)];
    [childDetailsScrollView addSubview:nameLayout];
    
    preferredLayout = [KidProfileSimpleLayout alloc];
    preferredLayout.layout_label = @"Preferred Name";
    preferredLayout.layout_value = [self.person valueForKey:@"nickname"];
    preferredLayout.is_visible_to_friends = TRUE;
    preferredLayout = [preferredLayout initWithFrame:CGRectMake(0,startingY + nameLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:preferredLayout];
    
    birthdayLayout = [KidProfileSimpleLayout alloc];
    birthdayLayout.layout_label = @"Birthday";
    
    // Changed as per the new requirement #90258522
    
    NSString *birthdate = [self.person valueForKey:@"birthdate"];
    NSString *end = [self getTodaysDate];   //@"2010-12-01";
    
    // Here, checking the response date is matches with current date. then displayed birthdate
    if ([birthdate isEqualToString:end])
    {
        birthdayLayout.layout_value = [self.person valueForKey:@"birthdate"];
    }
    else
    {
        //otherwise checking the date is future date or not
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"MM/dd/yyyy"];
        NSDate *startDate = [f dateFromString:[self.person valueForKey:@"birthdate"]];
        NSDate *endDate = [f dateFromString:end];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int finalDays = (int)[components day];
        if (finalDays < 1)
        {
            // if the date is future date, then prefix with due to server date
            birthdayLayout.layout_value = [NSString stringWithFormat:@"due %@",[self.person valueForKey:@"birthdate"]];
        }
        else
        {
            // displayed the server date
            birthdayLayout.layout_value = [self.person valueForKey:@"birthdate"];
        }
    }
    
    birthdayLayout.is_visible_to_friends = TRUE;
    birthdayLayout = [birthdayLayout initWithFrame:CGRectMake(0,preferredLayout.frame.origin.y + preferredLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:birthdayLayout];
    
    //    ageLayout = [KidProfileSimpleLayout alloc];
    //    ageLayout.layout_label = @"Age";
    //    ageLayout.layout_value = [self.person valueForKey:@"age"];
    //    ageLayout = [ageLayout initWithFrame:CGRectMake(0,birthdayLayout.frame.origin.y + birthdayLayout.frame.size.height + spacingBetween,screenWidth,40)];
    //    [childDetailsScrollView addSubview:ageLayout];
    
    genderLayout = [KidProfileSimpleLayout alloc];
    genderLayout.layout_label = @"Gender";
    genderLayout.layout_value = [self.person valueForKey:@"gender"];
    genderLayout = [genderLayout initWithFrame:CGRectMake(0,birthdayLayout.frame.origin.y + birthdayLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:genderLayout];
    
    addressLayout = [KidProfileMultiLayout alloc];
    addressLayout.layout_label = @"Address";
    NSString *address = [NSString stringWithFormat:@"%@ \n%@ %@, %@", [self.person valueForKey:@"address1"], [self.person valueForKey:@"city"],[self.person valueForKey:@"state"],[self.person valueForKey:@"zipcode"]];
    addressLayout.layout_value = address;
    //addressLayout = [addressLayout initWithFrame:CGRectMake(0,genderLayout.frame.origin.y + genderLayout.frame.size.height + spacingBetween,screenWidth,0)];
    //[childDetailsScrollView addSubview:addressLayout];
    
    otherDetailsLayout = [KidProfileMultiLayout alloc];
    otherDetailsLayout.layout_label = @"Other Basic Details";
    otherDetailsLayout.layout_value = [self.person valueForKey:@"other_basic_details"];
    otherDetailsLayout = [otherDetailsLayout initWithFrame:CGRectMake(0,genderLayout.frame.origin.y + genderLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:otherDetailsLayout];
    
    // doctor
    doctorLayout = [KidProfileDocDentLayout alloc];
    doctorLayout.layout_label = @"Primary Doctor";
    doctorLayout.parentView = self;
    NSMutableDictionary *doctor = [self.person valueForKey:@"doctor"];
    doctorLayout.contactDetails = doctor;
    doctorLayout = [doctorLayout initWithFrame:CGRectMake(0,otherDetailsLayout.frame.origin.y + otherDetailsLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:doctorLayout];
    
    // dentist
    dentistLayout = [KidProfileDocDentLayout alloc];
    dentistLayout.layout_label = @"Dentist";
    dentistLayout.parentView = self;
    NSMutableDictionary *dentist = [self.person valueForKey:@"dentist"];
    dentistLayout.contactDetails  = dentist;
    dentistLayout = [dentistLayout initWithFrame:CGRectMake(0,doctorLayout.frame.origin.y + doctorLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:dentistLayout];
    
    medicinesLayout = [KidProfileMultiLayout alloc];
    medicinesLayout.layout_label = @"Medicines";
    medicinesLayout.layout_value = [self.person valueForKey:@"medicines"];
    medicinesLayout = [medicinesLayout initWithFrame:CGRectMake(0,dentistLayout.frame.origin.y + dentistLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:medicinesLayout];
    
    allergiesLayout = [KidProfileMultiLayout alloc];
    allergiesLayout.layout_label = @"Food Allergies";
    allergiesLayout.layout_value = [self.person valueForKey:@"food_allergies"];
    allergiesLayout = [allergiesLayout initWithFrame:CGRectMake(0,medicinesLayout.frame.origin.y + medicinesLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:allergiesLayout];
    
    drugAllergiesLayout = [KidProfileMultiLayout alloc];
    drugAllergiesLayout.layout_label = @"Drug Allergies";
    drugAllergiesLayout.layout_value = [self.person valueForKey:@"drug_allergies"];
    drugAllergiesLayout = [drugAllergiesLayout initWithFrame:CGRectMake(0,allergiesLayout.frame.origin.y + allergiesLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:drugAllergiesLayout];
    
    medIssuesLayout = [KidProfileMultiLayout alloc];
    medIssuesLayout.layout_label = @"Medical Issues";
    medIssuesLayout.layout_value = [self.person valueForKey:@"medical_issues"];
    medIssuesLayout = [medIssuesLayout initWithFrame:CGRectMake(0,drugAllergiesLayout.frame.origin.y + drugAllergiesLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:medIssuesLayout];
    
    specialNeedsLayout = [KidProfileMultiLayout alloc];
    specialNeedsLayout.layout_label = @"Special Needs";
    specialNeedsLayout.layout_value = [self.person valueForKey:@"special_needs"];
    specialNeedsLayout = [specialNeedsLayout initWithFrame:CGRectMake(0,medIssuesLayout.frame.origin.y + medIssuesLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:specialNeedsLayout];
    
    otherHealthLayout = [KidProfileMultiLayout alloc];
    otherHealthLayout.layout_label = @"Other Health/Wellness";
    otherHealthLayout.layout_value = [self.person valueForKey:@"other_concerns"];
    otherHealthLayout = [otherHealthLayout initWithFrame:CGRectMake(0,specialNeedsLayout.frame.origin.y + specialNeedsLayout.frame.size.height + spacingBetween,screenWidth,40)];
    [childDetailsScrollView addSubview:otherHealthLayout];
    
    NSArray *parentArray = [self.person valueForKey:@"parents"];
    float ypostion = otherHealthLayout.frame.origin.y + otherHealthLayout.frame.size.height + spacingBetween;
    for(NSDictionary *dict in parentArray)
    {
        
       ParentLayout *parentLayout = [ParentLayout alloc];
        parentLayout.parentView = self;
        parentLayout.contactDetails  = dict;
        parentLayout = [parentLayout initWithFrame:CGRectMake(0,ypostion,screenWidth,40)];
        [childDetailsScrollView addSubview:parentLayout];

        ypostion = parentLayout.frame.origin.y + parentLayout.frame.size.height ;
    }
    
    
    childDetailsScrollView.contentSize = CGSizeMake(screenWidth, ypostion + 50);
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

-(void)openControl
{
    [self resetFormData];
    [self setHidden:NO];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         modalParent.frame = CGRectMake(self.frame.origin.x, 0, screenWidth, screenHeight);
                         [self setBackgroundColor:[UIColor colorWithRed:(0/255.f) green:(0/255.f) blue:(0/255.f) alpha:.6]];
                         editButtonsParent.frame = CGRectMake(self.frame.origin.x, screenHeight-125, screenWidth, screenHeight);
                     }
     ];
    
}

- (IBAction)closeButtonTapped:(id)sender
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         modalParent.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
                         [self setBackgroundColor:[UIColor colorWithRed:(0/255.f) green:(0/255.f) blue:(0/255.f) alpha:0]];
                         editButtonsParent.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
                     }
                     completion:^(BOOL finished) {
                         //do smth after animation finishes
                         [self removeFromSuperview];
                     }
     ];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SHOW_TABS" object:nil];
}

-(void)profilePhotoEditTapped
{
    //
}



-(void)AddPhotoToControl
{
    NSString *url = [self.person valueForKey:@"photograph_url"];
    profileImage.image = [UIImage imageNamed:@"EmptyProfile.png"];
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *img = [UIImage imageWithData: imageData];
    
    if (url.length > 0 && img != nil)
    {
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void)
                       {
                           NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                           
                           UIImage* image = [[UIImage alloc] initWithData:imageData];
                           if (image) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(100.0, 100.0)]];
                                   
                               });
                           }
                       });
        
    }
    else
    {
        
        NSString *nickname = [self.person valueForKey:@"nickname"];
        
        NSString *nicknameInitial;
        if(nickname != (id)[NSNull null] && nickname.length > 0)
            nicknameInitial = [[nickname substringToIndex:1] uppercaseString];
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(19, 20, 58, 58)];
        initial.text = nicknameInitial;
        initial.font =[UIFont fontWithName:@"Archer-Bold" size:30]; //Archer-Bold
        initial.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];
        
        // DebugLog(@"Row Initial %@", initial.text);
    }
    
}

#pragma mark- ImageUploading to server

-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
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
        ModelManager *sharedModel   = [ModelManager sharedModel];
        AccessToken  *token          = sharedModel.accessToken;
        UserProfile  *_userProfile   = sharedModel.userProfile;
        
        NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
        [bodyRequest setValue:[person valueForKey:@"kl_id"]          forKey:@"profile_id"];
        [bodyRequest setValue:name                                   forKey:@"name"];
        [bodyRequest setValue:contentType                                forKey:@"content_type"];
        [bodyRequest setValue:content                                forKey:@"content"];
        
        NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
        [finalRequest setValue:token.access_token       forKey:@"access_token"];
        [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
        [finalRequest setValue:@"change_photograph"     forKey:@"command"];
        [finalRequest setValue:bodyRequest              forKey:@"body"];
        
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalRequest options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/document-vault",BASE_URL]]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
             DebugLog(@"response-code: %ld", (long)httpResponse.statusCode);
             
             if (connectionError)
             {
                 DebugLog(@"ERROR CONNECTING DATA FROM SERVER: %@", connectionError.localizedDescription);
                 
                 //401 REPLACE WITH ERROR CODE
            //     [AlertUtils errorAlert];
                 
             }
             else
             {
                 NSError *error;
                 
                 NSMutableDictionary *dictionaryResponseAll = [NSJSONSerialization JSONObjectWithData: data
                                                               //1
                                                                                              options:kNilOptions
                                                                                                error:&error];
                 DebugLog(@"dictionaryResponseAll=%@",dictionaryResponseAll);
                 if(dictionaryResponseAll==nil)
                 {
                     UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
                     
                     self.globalAlert = wrongFormatImage;
                     
                     [wrongFormatImage show];
                     return;
                     
                 }
                 NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
                 NSString *stringStatus1 = [validResponseStatus stringValue];
                 
                 if ([stringStatus1 isEqualToString:@"200"])
                 {
                     for(UIView *view in [profileImage subviews])
                         [view removeFromSuperview];
                     for(UIView *view in [self.parent.profileImage subviews])
                         [view removeFromSuperview];
                     profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(100.0, 100.0)]];
                     
                     self.parent.profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(100.0, 100.0)]];
                     
                     [self.person setValue:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
                     [self.parent.person setValue:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
                     
                 }
                 
             }
         }];
        
        
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    // DebugLog(@"_responseData=%@",_responseData);
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSMutableDictionary *dictionaryResponseAll = [NSJSONSerialization JSONObjectWithData:_responseData //1
                                                                                 options:kNilOptions
                                                                                   error:&error];
    DebugLog(@"dictionaryResponseAll=%@",dictionaryResponseAll);
    if(dictionaryResponseAll==nil)
    {
        UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        
        self.globalAlert = wrongFormatImage;
        
        [wrongFormatImage show];
        return;
        
    }
    NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    
    if ([stringStatus1 isEqualToString:@"200"])
    {
        for(UIView *view in [profileImage subviews])
            [view removeFromSuperview];
        for(UIView *view in [self.parent.profileImage subviews])
            [view removeFromSuperview];
        profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(100.0, 100.0)]];
        
        self.parent.profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(100.0, 100.0)]];
        
        [self.person setValue:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
        if ([self.parent respondsToSelector:@selector(person)])
        {
            [self.parent.person setValue:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
        }
        
    }
    else if ([stringStatus1 isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:dictionaryResponseAll forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    else
    {
        UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid Image Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
        
        self.globalAlert = wrongFormatImage;
        
        [wrongFormatImage show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DebugLog(@"%@",[error description]);
    // The request has failed for some reason!
    // Check the error var
}


-(void)fetchKidInfoError:(NSError *)error
{
    
}

- (IBAction)editButtonPressed:(id)sender
{
    [self.parent performSegueWithIdentifier: @"KidProfileDetailEditSegue" sender: self];
    
}



- (void)editCancelButtonTapped:(id)sender
{
    [self resetFormData];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    [UIView animateWithDuration:0.5f animations:^{
        btnEditSave.alpha = 0;
        btnEditCancel.alpha = 0;
        editButtonsParent.frame = CGRectMake(0,screenHeight-125,screenWidth,screenHeight);
        
        lblProfileEditName.frame = CGRectMake(lblProfileEditName.frame.origin.x,
                                              lblProfileEditName.frame.origin.y - 10,
                                              lblProfileEditName.frame.size.width,
                                              lblProfileEditName.frame.size.height);
        
        lblEyes.frame = CGRectMake(lblEyes.frame.origin.x,
                                   lblEyes.frame.origin.y - 10,
                                   lblEyes.frame.size.width,
                                   lblEyes.frame.size.height);
        
        lblIdea.frame = CGRectMake(lblIdea.frame.origin.x,
                                   lblIdea.frame.origin.y - 10,
                                   lblIdea.frame.size.width,
                                   lblIdea.frame.size.height);
        
        lblIdeaDetail.frame = CGRectMake(lblIdeaDetail.frame.origin.x,
                                         lblIdeaDetail.frame.origin.y - 10,
                                         lblIdeaDetail.frame.size.width,
                                         lblIdeaDetail.frame.size.height);
        
        btnEditSave.frame = CGRectMake(btnEditSave.frame.origin.x,
                                       btnEditSave.frame.origin.y - 10,
                                       btnEditSave.frame.size.width,
                                       btnEditSave.frame.size.height);
        
        btnEditCancel.frame = CGRectMake(btnEditCancel.frame.origin.x,
                                         btnEditCancel.frame.origin.y - 10,
                                         btnEditCancel.frame.size.width,
                                         btnEditCancel.frame.size.height);
        
        exception_indicator.frame = CGRectMake(exception_indicator.frame.origin.x,
                                               exception_indicator.frame.origin.y - 10,
                                               exception_indicator.frame.size.width,
                                               exception_indicator.frame.size.height);
        
        
        
        
    } completion:^(BOOL check){
    }];
    //dismiss keyboard
    //   [self endEditing:YES];
}

- (void)editSaveButtonTapped:(id)sender
{
    
    //dismiss keyboard
    //  [self endEditing:YES];
}


- (void)shareButtonTapped:(UIButton *)sender
{
    [btnProfileShare setEnabled:NO];
    [btnProfileShare setUserInteractionEnabled:NO];
    [btnProfileShare setAlpha:0.2];
    
    [self displayMailComposerSheet];
}

- (void)displayMailComposerSheet
{
    if([MFMailComposeViewController canSendMail])
    {
        mailComposer= [[MFMailComposeViewController alloc] init];
        [self.mailComposer setMailComposeDelegate:self];
        [self.mailComposer setSubject:[NSString stringWithFormat:@"Tingr Profile Detail on %@", [self.person valueForKey:@"nickname"]]];
        
        NSString *kidDetails= @"";
        
        NSString *fullName = @"";
        NSString *preferredname = @"";
        NSString *birthDate = @"";
        NSString *age = @"";
        NSString *gender = @"";
        NSString *other_basic_details = @"";
        NSString *dentistDetails = @"";
        NSString *doctorDetails = @"";
        NSString *medicines = @"";
        NSString *food_allergies = @"";
        NSString *drug_allergies = @"";
        NSString *medical_issues = @"";
        NSString *special_needs = @"";
        NSString *other_concerns = @"";
        // fullName
        if ([[self.person valueForKey:@"fname"] length]>0)
            fullName =[self.person valueForKey:@"fname"];
        if ([[self.person valueForKey:@"mname"] length]>0)
            fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@",[self.person valueForKey:@"mname"]]];
        if ([[self.person valueForKey:@"lname"] length]>0)
            fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@",[self.person valueForKey:@"lname"]]];
        
        // preferredname
        if ([[self.person valueForKey:@"nickname"] length]>0)
            preferredname =[self.person valueForKey:@"nickname"];
        
        // birthDate
        if ([[self.person valueForKey:@"birthdate"] length]>0)
            birthDate =[self.person valueForKey:@"birthdate"];
        
        // age
        if ([[self.person valueForKey:@"age"] length]>0)
            age =[self.person valueForKey:@"age"];
        
        // gender
        if ([[self.person valueForKey:@"gender"] length]>0)
            gender =[self.person valueForKey:@"gender"];
        
        // other_basic_details
        if ([[self.person valueForKey:@"other_basic_details"] length]>0)
            other_basic_details =[self.person valueForKey:@"other_basic_details"];
        
        // dentist
        NSMutableDictionary *dentist = [self.person valueForKey:@"dentist"];
        
        if ([[dentist valueForKey:@"email"] length]>0)
            dentistDetails = [dentist valueForKey:@"email"];
        if ([[dentist valueForKey:@"name"] length]>0)
            dentistDetails = [dentistDetails stringByAppendingString:[NSString stringWithFormat:@"\n%@",[dentist valueForKey:@"name"]]];
        if ([[dentist valueForKey:@"phone_no"] length]>0)
            dentistDetails = [dentistDetails stringByAppendingString:[NSString stringWithFormat:@"\n%@",[dentist valueForKey:@"phone_no"]]];
        //DebugLog(@"dentist:*%@*",dentistDetails);
        
        // doctor
        NSMutableDictionary *doctor = [self.person valueForKey:@"doctor"];
        
        if ([[doctor valueForKey:@"email"] length]>0)
            doctorDetails = [doctor valueForKey:@"email"];
        if ([[doctor valueForKey:@"name"] length]>0)
            doctorDetails = [doctorDetails stringByAppendingString:[NSString stringWithFormat:@"\n%@",[doctor valueForKey:@"name"]]];
        if ([[doctor valueForKey:@"phone_no"] length]>0)
            doctorDetails = [doctorDetails stringByAppendingString:[NSString stringWithFormat:@"\n%@",[doctor valueForKey:@"phone_no"]]];
        //DebugLog(@"doctor:*%@*",doctorDetails);
        
        // medicines
        if ([[self.person valueForKey:@"medicines"] length]>0)
            medicines =[self.person valueForKey:@"medicines"];
        
        // food_allergies
        if ([[self.person valueForKey:@"food_allergies"] length]>0)
            food_allergies =[self.person valueForKey:@"food_allergies"];
        
        // drug_allergies
        if ([[self.person valueForKey:@"drug_allergies"] length]>0)
            drug_allergies =[self.person valueForKey:@"drug_allergies"];
        
        // medical_issues
        if ([[self.person valueForKey:@"medical_issues"] length]>0)
            medical_issues =[self.person valueForKey:@"medical_issues"];
        
        // special_needs
        if ([[self.person valueForKey:@"special_needs"] length]>0)
            special_needs =[self.person valueForKey:@"special_needs"];
        
        // other_concerns
        if ([[self.person valueForKey:@"other_concerns"] length]>0)
            other_concerns =[self.person valueForKey:@"other_concerns"];
        
        if (fullName.length >0)
        {
            kidDetails = [NSString stringWithFormat:@"Full Name:           \n"];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",fullName]];
        }
        
        if (preferredname.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Preferred Name:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",preferredname]];
        }
        if (birthDate.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Birthday:        \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",birthDate]];
        }
        if (age.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Age:             \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",age]];
        }
        if (gender.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Gender:          \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",gender]];
        }
        
        if (other_basic_details.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Other Basic Details:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",other_basic_details]];
        }
        if (doctorDetails.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Primary Doctor:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",doctorDetails]];
        }
        if (dentistDetails.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Dentist:         \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",dentistDetails]];
        }
        if (medicines.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Medicines:       \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",medicines]];
        }
        if (food_allergies.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Food Allergies:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",food_allergies]];
        }
        if (drug_allergies.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Drug Allergies:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",drug_allergies]];
        }

        if (medical_issues.length >0){
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Medical Issues:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n",medical_issues]];
        }
        if (special_needs.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Special Needs:   \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",special_needs]];
        }
        if (other_concerns.length >0)
        {
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@" Other Health/Wellness:  \n"]];
            kidDetails = [kidDetails stringByAppendingString:[NSString stringWithFormat:@"%@\n\n",other_concerns]];
        }
        
        [self.mailComposer setMessageBody:kidDetails isHTML:NO];
        self.mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [parent presentViewController:self.mailComposer animated:YES completion:NULL];
        [btnProfileShare setEnabled:YES];
        [btnProfileShare setUserInteractionEnabled:YES];
        [btnProfileShare setAlpha:1.0];
    }
    else
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:@"Mail client not configured on this device. Add a mail account in your device Settings to send an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        self.globalAlert = alert;
        
        [alert show];
    }
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
    [parent dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled )
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        self.globalAlert = alert;
        
        [alert show];
    }
    
}



- (void)setupView
{
    // Set View Background Color
    //    UIColor * backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    //    [[self view] setBackgroundColor:backgroundColor];
    
    // Set Up Image View and Border
    borderView = [UIView new];
    UIColor * borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"border.png"]];
    [borderView setBackgroundColor:borderColor];
    
    CALayer * borderLayer = [borderView layer];
    [borderLayer setCornerRadius:10.0f];
    [borderLayer setBorderColor:[[UIColor blackColor] CGColor]];
    [borderLayer setBorderWidth:2.0f];
    [borderLayer setMasksToBounds:YES];
    [self setBorderView:borderView];
    [[self.parent view] addSubview:borderView];
    
    UIImageView * previewView = [UIImageView new];
    [previewView setContentMode:UIViewContentModeCenter];
    [previewView setImage:[UIImage imageNamed:@"splash.png"]];
    [borderView addSubview:previewView];
    [self setImagePreviewView:previewView];
    
    // Customize UI Components
    //    UIImage * blueButton = [[UIImage imageNamed:@"blue_button.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:0.0f];
    //    UIImage * blueButtonActive = [[UIImage imageNamed:@"blue_button_pressed.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:0.0f];
    //    [[self btnEditPhoto] setBackgroundImage:blueButton forState:UIControlStateNormal];
    //    [[self btnEditPhoto] setBackgroundImage:blueButtonActive forState:UIControlStateHighlighted];
    
    //    UIImage * darkButton = [[UIImage imageNamed:@"dark_button.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:0.0f];
    //    UIImage * darkButtonActive = [[UIImage imageNamed:@"dark_button_pressed.png"] stretchableImageWithLeftCapWidth:7.0f topCapHeight:0.0f];
    //    [[self editSampleButton] setBackgroundImage:darkButton forState:UIControlStateNormal];
    //    [[self editSampleButton] setBackgroundImage:darkButtonActive forState:UIControlStateHighlighted];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //DebugLog(@"Did Scroll %f", scrollView.contentOffset.y);
    
    float index = scrollView.contentOffset.y;
    
    if (index > 25 && animated == FALSE)
    {
        animated = TRUE;
        [self animateBottomDown];
    }
    if (index < 1 && animated == TRUE)
    {
        animated = FALSE;
        [self animateBottomUp];
    }
}

//The event handling method
- (void)animateBottomDown
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        editButtonsParent.frame = CGRectMake(self.frame.origin.x, screenHeight, screenWidth, screenHeight);
        
    }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
    
}

- (void)animateBottomUp
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         editButtonsParent.frame = CGRectMake(self.frame.origin.x, screenHeight-125, screenWidth, screenHeight);
                     }
     ];
    
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (IBAction)editPhotoButtonPressed:(id)sender
{
    // [self setupView];
    
    if ([self hasValidAPIKey]) {
        
        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                              @"Take photo", @"Choose existing", nil];
        addImageActionSheet.tag = 1000;
        [addImageActionSheet setDelegate:self];
        [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    }
}

- (BOOL) hasValidAPIKey
{
    if ([kAFAviaryAPIKey isEqualToString:@"<YOUR-API-KEY>"] || [kAFAviarySecret isEqualToString:@"<YOUR-SECRET>"])
    {
        UIAlertView *forgotKeyAlert =  [[UIAlertView alloc] initWithTitle:@"Oops!"
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
#pragma mark- UIActionSheet Delegate Methods
#pragma mark-

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
                        isImageSelected = YES;
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        //[parent presentViewController:imagePicker animated:YES completion:NULL];
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
                    [self lauchPicker];
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        isImageSelected = YES;
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        //[parent presentViewController:imagePicker animated:YES completion:NULL];
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
                    [self lauchPicker];
                    break;
                }
                case 2:
                {
                    
                }
                    
                default:
                    break;
            }
        }
            break;
            
        case 100:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
                    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
                    [[UIApplication sharedApplication] openURL:telURL];
                    
                    break;
                }
                case 1:
                {
                    [self showSMS];
                    break;
                }
                case 2:
                {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:phoneNumber];
                    break;
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
-(void)lauchPicker
{
    if (isImageSelected == YES)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.parent presentViewController:imagePicker animated:YES completion:NULL];
        }else{
            //        [self presentViewControllerInPopover:imagePicker];
        }
    }
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
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Present the photo editor.
    [self.parent presentViewController:photoEditor animated:NO completion:^{ [HUD hide:YES];
        [HUD show:NO];
    }];
}

- (void) setupHighResContextForPhotoEditor:(AVYPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    id<AVYPhotoEditorRender> render = [photoEditor enqueueHighResolutionRenderWithImage:highResImage
                                                                             completion:^(UIImage *result, NSError *error) {
                                                                                 if (result) {
                                                                                     UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
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
    image = [photoUtils compressForUpload:image :0.67];
    
    isImageSelected = NO;
    changedImage = image;
    [[self imagePreviewView] setImage:image];
    [[self imagePreviewView] setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.parent dismissViewControllerAnimated:YES completion:nil];
    
    NSData *imageData1 = UIImageJPEGRepresentation(image, 0.7);
    
    /*
     // Here we are not using the fileExtension any where
     // To avoid the memory leak comment the below statement
     
     NSString *fileExtension = [singletonObj contentTypeForImageData:imageData1];
     DebugLog(@"fileExtension:*%@*",fileExtension);
     
     */
    
    imageExtension = @"JPEG";
    
    
    NSString *imageDataEncodedeString = [imageData1 base64EncodedString];
    [self sendImageInfoToServerWithName:[NSString stringWithFormat:@"temp.%@",imageExtension] contentType:[NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]] content:imageDataEncodedeString];
    [borderView removeFromSuperview];
    
    
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    [self.parent dismissViewControllerAnimated:YES completion:nil];
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
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    
    HUD.delegate = self;
    [HUD hide:NO];
    [HUD show:YES];
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                [self launchEditorWithAsset:asset];
            }
            else
            {
                [self launchPhotoEditorWithImage:info[UIImagePickerControllerOriginalImage] highResolutionImage:info[UIImagePickerControllerOriginalImage]];
            }
        } failureBlock:^(NSError *error) {
            [HUD hide:YES];
            [HUD show:NO];
            UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            self.globalAlert = disableAlert;
            
            [disableAlert show];
        }];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.parent dismissViewControllerAnimated:NO completion:completion];
    }else{
        //[self dismissPopoverWithCompletion:completion];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.parent dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Popover Methods

- (void) presentViewControllerInPopover:(UIViewController *)controller
{
    CGRect sourceRect = [[self btnProfileEditPhoto] frame];
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
        CGRect popoverRef = [[self btnProfileEditPhoto] frame];
        [[self popover] presentPopoverFromRect:popoverRef inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

#pragma mark - Status Bar Style

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Methods to display mail and message composer
-(void)showMailComposerWithEmailID:(NSString *)email
{
    if([MFMailComposeViewController canSendMail])
    {
        [self.HUD hide:YES];
        [self.HUD show:NO];
        self.HUD = nil;
        
        mailComposer= [[MFMailComposeViewController alloc] init];
        [self.mailComposer setMailComposeDelegate:self];
        [self.mailComposer setToRecipients:[NSArray arrayWithObject:email]];
        self.mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        //[self setHidden:YES];
        [parent presentViewController:self.mailComposer animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:@"Mail client not configured on this device. Add a mail account in your device Settings to send an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        self.globalAlert = alert;
        
        [alert show];
    }
}
-(void)tappedOnPhoneNumber:(NSString *)phoneNumber1
{
    phoneNumber = phoneNumber1;
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Call", @"Send a text message", @"Copy to clipboard",nil];
    addImageActionSheet.tag = 100;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}

#pragma mark -
#pragma mark Message Composer Methods
- (void)showSMS
{
    
    if(![MFMessageComposeViewController canSendText])
    {
        [HUD setHidden:YES];
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.globalAlert = warningAlert;
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = [NSArray arrayWithObject:phoneNumber];
    
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    
    // Present message view controller on screen
    [parent presentViewController:messageController animated:YES completion:^{ [HUD setHidden:YES];}];
}

//This method is called when a button is clicked in the native send SMS popup
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
            
        }
            break;
            
        case MessageComposeResultFailed:
        {
            
            break;
        }
            
        case MessageComposeResultSent:
        {
            break;
            
        }
            break;
            
        default:
            break;
    }
    
    [parent dismissViewControllerAnimated:YES completion:nil];
    
}


@end
