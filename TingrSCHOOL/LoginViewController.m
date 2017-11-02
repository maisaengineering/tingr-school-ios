
#import "LoginViewController.h"
//#import "PendingTasks.h"
#import "SVWebViewController.h"
//#import "MainTabViewController.h"
#import "ProfileDateUtils.h"
#import "MenuViewController.h"
@interface LoginViewController ()
{
    ProfileDateUtils *photoDateUtils;
    BOOL isLogin;
}
@end

@implementation LoginViewController

@synthesize txtConfirmPasssword;
@synthesize txtPassword;
@synthesize singletonObj;
@synthesize onoff;
@synthesize isRememberClicked;
@synthesize appDelegate;
@synthesize isPwdChanged;
@synthesize isSignUp;
@synthesize email;
@synthesize gotoResult;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View controller Life cycle
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    singletonObj = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    photoDateUtils = [ProfileDateUtils alloc];
    //singletonObj.mainNavigatinCtrl = self.navigationController;
    
    
    UIImageView *wallpaperImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h"]];
    if(IDIOM == IPAD) {
        
        wallpaperImage.image = [UIImage imageNamed:@"Default-Portrait"];
    }

    wallpaperImage.clipsToBounds = YES;
    wallpaperImage.frame = self.view.bounds;
    [self.view addSubview:wallpaperImage];

    
    [self createView];
    

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(popToLogin:)
     name:POP_TO_LOGIN
     object:nil ];
    
}
-(void)createView {
    
    
    self.backgroundImageViewScrollView = [[TPKeyboardAvoidingScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundImageViewScrollView];
    
    //put in password
    
    txtEmail = [[UITextField alloc] initWithFrame:CGRectMake(35,  Deviceheight - 230 , Devicewidth - 70, 40)];
    txtEmail.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [txtEmail setBackgroundColor:[UIColor clearColor]];
    txtEmail.textAlignment = NSTextAlignmentCenter;
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [txtEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    NSMutableParagraphStyle *style = [txtEmail.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = txtEmail.font.lineHeight - (txtEmail.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:15].lineHeight) / 2.0;
    NSDictionary *placeHolderAttributes = @{
                                            NSForegroundColorAttributeName: [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0.8],
                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:15],
                                            NSParagraphStyleAttributeName : style
                                            };
    

    txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                                attributes:placeHolderAttributes
                                                 ];
    
    txtEmail.textColor = [UIColor whiteColor];
    txtEmail.delegate = self;
    [self.backgroundImageViewScrollView addSubview:txtEmail];
    
    UIImageView *lineImageUnderPassword = [[UIImageView alloc]init];
    lineImageUnderPassword.frame = CGRectMake(35,txtEmail.frame.origin.y+31,Devicewidth - 70, 0.5);
    lineImageUnderPassword.backgroundColor = [UIColor whiteColor];
    lineImageUnderPassword.alpha = 0.7;
    [self.backgroundImageViewScrollView addSubview:lineImageUnderPassword];

    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btnLogin.frame = CGRectMake(Devicewidth - 105, lineImageUnderPassword.frame.origin.y + 15, 70, 28);
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin setBackgroundColor:UIColorFromRGB(0x3CADE5)];
    btnLogin.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    btnLogin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnLogin.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [btnLogin.layer setCornerRadius:4];
    btnLogin.clipsToBounds = YES;
    [self.backgroundImageViewScrollView addSubview:btnLogin];
    
    
    
    //forgot button
    UIButton *btnForgot = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnForgot addTarget:self action:@selector(forgotButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnForgot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnForgot setTitle:@"forgot password?" forState:UIControlStateNormal];
    btnForgot.titleEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
    [btnForgot.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd" size:15]];
    [self.backgroundImageViewScrollView addSubview:btnForgot];

    //back button
    
    //put in username
        txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(35, txtEmail.frame.origin.y + txtEmail.frame.size.height + 1, Devicewidth - 70, 40)];
        txtPassword.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        
        txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                                    attributes:placeHolderAttributes
                                                     ];
        txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        txtPassword.textAlignment = NSTextAlignmentCenter;
        txtPassword.textColor = [UIColor whiteColor];
        [txtPassword setBackgroundColor:[UIColor clearColor]];
        [txtPassword setKeyboardType:UIKeyboardTypeEmailAddress];
        txtPassword.delegate = self;
        txtPassword.secureTextEntry = YES;
        [self.backgroundImageViewScrollView addSubview:txtPassword];
        
        UIImageView *lineImageUnderEmail = [[UIImageView alloc]init];
        lineImageUnderEmail.frame = CGRectMake(35,txtPassword.frame.origin.y+31,Devicewidth - 70, 0.5);
        lineImageUnderEmail.backgroundColor = [UIColor whiteColor];
        lineImageUnderEmail.alpha = 0.7;
        [self.backgroundImageViewScrollView addSubview:lineImageUnderEmail];
        
    
        btnLogin.frame = CGRectMake(Devicewidth - 105, lineImageUnderEmail.frame.origin.y + 15, 70, 28);

        btnForgot.frame = CGRectMake(35, btnLogin.frame.origin.y , 128, 28);


    if ( IDIOM == IPAD ) {

        txtPassword.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        [btnForgot.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd" size:20]];
        btnLogin.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];

    
        txtEmail.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        style = [txtEmail.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
        style.minimumLineHeight = txtEmail.font.lineHeight - (txtEmail.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:20].lineHeight) / 2.0;
        NSDictionary *placeHolderAttributes = @{
                                                NSForegroundColorAttributeName: [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0.8],
                                                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:20],
                                                NSParagraphStyleAttributeName : style
                                                };
        
        
        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                         attributes:placeHolderAttributes
                                          ];
        txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                            attributes:placeHolderAttributes
                                             ];

        
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.toolbar.hidden = YES;
    
    self.view.hidden = YES;
    
    
    BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];
    if(key)
    {
        if([[ModelManager sharedModel] accessToken] == nil)
        {
            ModelManager *shared = [ModelManager sharedModel];
            AccessToken *token = [[AccessToken alloc] init];
            NSMutableDictionary *parsedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
            
            NSMutableDictionary *profilesListResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"];
            UserProfile *userProfile = [[UserProfile alloc] init];
            userProfile.auth_token   = [[profilesListResponse valueForKey:@"body"] valueForKey:@"auth_token"];
       //     userProfile.onboarding   = [[[profilesListResponse valueForKey:@"body"] valueForKey:@"onboarding"] boolValue];
            NSDictionary *dic = [profilesListResponse valueForKey:@"body"];
            userProfile.teacher_klid = [dic valueForKey:@"teacher_klid"];
            userProfile.fname = [dic valueForKey:@"fname"];
            userProfile.lname = [dic valueForKey:@"lname"];
            userProfile.email = [dic valueForKey:@"email"];
            userProfile.rooms = [dic valueForKey:@"rooms"];
            userProfile.photograph = [dic valueForKey:@"photograph"];
            userProfile.org_logo = [dic valueForKey:@"org_logo"];

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            
            //TODO: This is overriding the original user profile and items like the verfified phone number
            //are not being put in
            //we should have the user profile once and in one place
            
            shared.userProfile = userProfile;
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"selecteRoom"])
                singletonObj.selecteRoom = [[NSUserDefaults standardUserDefaults] objectForKey:@"selecteRoom"];

            
            if([userDefaults objectForKey:@"selecteRoom"])
                singletonObj.selecteRoom = [userDefaults objectForKey:@"selecteRoom"];
            for (NSString *key in parsedObject)
            {
                if ([token respondsToSelector:NSSelectorFromString(key)]) {
                    
                    [token setValue:[parsedObject valueForKey:key] forKey:key];
                }
            }
            
            shared.accessToken = token;
        }
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
     /*
        UIStoryboard *sBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabViewController *detailsController = [sBoard instantiateViewControllerWithIdentifier:@"MainTabViewController"];
        [self.navigationController pushViewController: detailsController animated:NO];
      */
        
    }
    else if(isPwdChanged)
    {
        self.isPwdChanged = NO;
        [self performSelectorInBackground:@selector(getAccessToken) withObject:nil];
    }
    
    self.view.hidden = NO;
    
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [txtPassword setDelegate:nil];
    [txtEmail setDelegate:nil];
    [super viewWillDisappear:YES];
}
- (void)tapGestureUpdated:(UIGestureRecognizer *)recognizer
{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
}
- (void) flip: (id) sender
{
    UISwitch *onoffSwitch = (UISwitch *) sender;
    NSString *checkStatus = onoffSwitch.on ? @"On" : @"Off";
    if ([checkStatus isEqualToString:@"On"])
    {
        isRememberClicked = YES;
//        [appDelegate setIsRememberMe:YES];
    }
    else
    {
        isRememberClicked = NO;
  //      [appDelegate setIsRememberMe:NO];
    }
    
    DebugLog(@"%i", isRememberClicked);
}


-(void)clearUserDefaults
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"streamArray"];
    [prefs removeObjectForKey:@"tokens"];
    [prefs removeObjectForKey:@"userProfile"];
    [prefs removeObjectForKey:@"profileKids"];
    [prefs removeObjectForKey:@"profileParents"];
    [prefs removeObjectForKey:@"profileOnboarding"];
    [prefs removeObjectForKey:@"sortedParentKidDetails"];
    [prefs removeObjectForKey:@"sortedKidDetails"];
    [prefs removeObjectForKey:@"arrayKidsLinkUsers"];
    [prefs removeObjectForKey:@"arrayShowProfiles"];
    [prefs removeObjectForKey:@"NewKidStreamEmptyData"];
    [prefs setBool:NO forKey:@"isRemember"];
    [prefs setBool:NO forKey:@"isVerified"];
    [prefs setBool:NO forKey:@"isPersonality"];
    [prefs removeObjectForKey:@"inviteTotal"];
    [prefs removeObjectForKey:@"oneWayFriendsCount"];
    [prefs removeObjectForKey:@"selecteRoom"];

    [prefs synchronize]; 
}
-(void)popToLogin: (NSNotification *) notification
{

    
    [self clearUserDefaults];
    
    
    [self.navigationController popToViewController:self animated:YES];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    [singletonObj clear];
    [sharedModel clear];
    singletonObj.selecteOrganisation = nil;
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        [self performSelectorInBackground:@selector(getAccessToken) withObject:nil];
    }
    
    
    if(!isLogin) {
        txtEmail.text = @"";
        txtPassword.text = @"";
    }

}
-(void)newPoptoLogin
{
 /*   //Remove the user from all channels
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.channels = [NSArray arrayWithObjects:nil];
    [currentInstallation saveEventually];
    
    [txtPassword setText:@""];
    //[txtConfirmPasssword setText:@""]; //do not clear this field
    [self clearUserDefaults];
    
    if([[appDelegate timer] isValid])
        [[appDelegate timer] invalidate];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    [singletonObj clear];
    [sharedModel clear];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        [self performSelectorInBackground:@selector(getAccessToken) withObject:nil];
    }
  
  */
}
  
  

- (void)getAccessToken
{
    
    NSError* error;
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"KidsApp"};
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:&error];
    
    //convert data to string
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //DebugLog(@"AccessToken--Request: %@", jsonString);
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    //DebugLog(@"AccessToken---URL: %@", urlAsString);
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    //DebugLog(@"AccessToken---URL: %@", urlAsString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSHTTPURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error)
    {
        
    }
    else
    {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        DebugLog(@"parsedObject:%@",parsedObject);
        
        [[NSUserDefaults standardUserDefaults] setObject:parsedObject forKey:@"tokens"];
        
        NSMutableArray *tokens = [[NSMutableArray alloc] init];
        AccessToken *token = [[AccessToken alloc] init];
        
        for (NSString *key in parsedObject)
        {
            if ([token respondsToSelector:NSSelectorFromString(key)]) {
                [token setValue:[parsedObject valueForKey:key] forKey:key];
            }
        }
        
        [tokens addObject:token];
        
        sharedModel.accessToken = [tokens objectAtIndex:0];
    }
}

- (void)loginButtonPressed:(id)sender
{
    
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
    }
    else
    {
        AccessToken* token = sharedModel.accessToken;
        if(!token.access_token) {
            [self performSelectorInBackground:@selector(getAccessToken) withObject:nil];
            return;
        }

        

        if([self validateFields:txtEmail] && [self validateFields:txtPassword])
        {
            
            if ([self validateEmailWithString:txtEmail.text])
            {
                
                [self callLoginApi];
                

                
            }
            
            else
            {
                // If user enters invalid email , shows the alert
                [self validationAlert:EMAIL_INVALID];
            }
            
        }
        else
        {
            [self validationAlert:ALL_FIELDS_REQUIRED];
            
        }
    }
}

- (void)forgotButtonPressed:(id)sender
{
    [self performSegueWithIdentifier: @"ForgotPasswordSegue" sender: self];
}
/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if ([segue.identifier isEqualToString:@"ForgotPasswordSegue"]) {
 ForgotPasswordViewController *destViewController = segue.destinationViewController;
 destViewController.loginCntrl = self;
 }
 }
 */
- (IBAction)inviteButtonPressed:(id)sender
{
    //[self performSegueWithIdentifier: @"ForgotPasswordSegue" sender: self];
    //NSDictionary *dictionary = [NSDictionary dictionaryWithObject:REDEEM_INVITATION forKey:@"URL"];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_WEBVIEW" object:nil userInfo:dictionary];
    
    
    NSURL *URL = [NSURL URLWithString:REDEEM_INVITATION];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    webViewController.title = @"Sign up";
    //webViewController.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:webViewController animated:YES];
}



- (void)callLoginApi
{
    isLogin = YES;
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    
    //DebugLog(@"token.access_token:%@",token.access_token);
    
    NSDictionary* bodyData = @{@"user_email": txtEmail.text,
                               @"password": txtPassword.text,
                               @"remember_me":[NSNumber numberWithBool:YES]};
    
    NSString *command = @"authentication";
    
  
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(weakSelf)
        {
            isLogin = NO;
            id profiles = [Factory userProfileFromJSON:[json objectForKey:@"response"]];
            [weakSelf didReceiveProfile:profiles];
        }
        
    } failure:^(NSDictionary *json) {
        
        
        [weakSelf fetchingProfileFailedWithError:json];
    }];

    
}
- (void)callCreateUserApi
{
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    
    //DebugLog(@"token.access_token:%@",token.access_token);
    
    NSDictionary* bodyData = @{@"email": email,
                               @"password": txtPassword.text,
                               @"password_confirmation":txtConfirmPasssword.text};
    
    NSString *command = @"signup_user";
    

    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        
        id profiles = [Factory userProfileFromJSON:[json objectForKey:@"response"]];
        [self didReceiveProfile:profiles];
        
    } failure:^(NSDictionary *json) {
        
        [self fetchingProfileFailedWithError:[json objectForKey:@"response"]];
    }];
    
    
    
}


-(void)validationAlert: (NSString *) comment
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Alert"
                          message:comment
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    self.globalAlert = alert;
    
    [alert show];
}

-(void)goToOnboardingWithOnBoardingPartnerDetails:(NSMutableDictionary *)onBoardingPartnerDetails
{/*
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OnboardingWellnessLogoViewController *_onboardingWellnessLogoViewController = [storyBoard instantiateViewControllerWithIdentifier:@"OnboardingWellnessLogoViewController"];
    _onboardingWellnessLogoViewController.onBoardingPartnerDetails = [[NSMutableDictionary alloc]initWithDictionary:[onBoardingPartnerDetails mutableCopy]];
    [self.navigationController pushViewController:_onboardingWellnessLogoViewController animated:YES];
  */
}

-(void)goToVerifiedPhoneNumber
{
    
        [self performSegueWithIdentifier: @"GoToVerify" sender: self];
}

-(void)goToMainTabs
{
    [self performSegueWithIdentifier: @"MainAppSegue" sender: self];
    
    
    [appDelegate askForNotificationPermission];
    [appDelegate subscribeUserToFirebase];
}

-(void)goToPostSignUP
{
    [self performSegueWithIdentifier: @"PostSignUp" sender: self];
}
#pragma mark- AuthenticationManagerDelegate Methods
#pragma mark-

- (void)didReceiveProfile:(id)profiles
{
    
    _userProfile = [profiles objectAtIndex:0];
    sharedModel.userProfile = _userProfile;
    
    //reset the badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //set the Parse user id
    
    //unregister user for any other channels
   // [NotificationUtils resetParseChannels];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HAS_REGISTERED_KLID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    appDelegate.leftMenu.selectedIndex = 2;
    
    if(_userProfile.onboarding)
    {
        
        [self removeSpinner];
        [self goToTour];
    }
    else
    {
        
        
        [self removeSpinner];
        [self goToMainTabs];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isRemember"];

}



- (void)fetchingProfileFailedWithError:(NSDictionary *)error
{
    isLogin = NO;
    
    [Spinner showIndicator:NO];
    
    if([[error objectForKey:@"message"] length] >0)
        [self validationAlert:[error objectForKey:@"message"]];
    else
        [self validationAlert:FAILED_LOGIN];
}

#pragma mark- Email Validation Method
#pragma mark-
- (BOOL)validateFields:(UITextField *)textField
{
    NSString *trimvalue;
    BOOL isValidField;
    trimvalue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isValidField = trimvalue.length > 0;
    return isValidField;
}

- (BOOL)validateEmailWithString:(NSString*)email1
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email1];
}

#pragma mark- UITextFieldDelegate Methods
#pragma mark-
// User login and immediately logout
// he try to edit the email field or password field
// To AVOID the crash
// ALLOW THE USER TO EDIT FIELDS

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // became first responder
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtPassword)
    {
        BOOL _isAllowed = YES;
        
        NSString *tempString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        if ([self.txtPassword.text isEqualToString:tempString])
        {
            _isAllowed =  NO;
        }
        
        return   _isAllowed;
    }
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)checkTour
{
    //HERE we need to check if the tour images have downloaded, if not put in a 3 second timer
    //for now just send it there
    [self goToTour];
}

-(void)goToTour
{
    singletonObj.isStreamsDownloaded = YES;
   // [[PendingTasks sharedInstance] getStreamsDataInBackground];
    [self performSegueWithIdentifier: @"TourView" sender: self];
}


-(void) askForNotificationPermission
{
 //   [appDelegate askForNotificationPermission];
}
-(void)fetchingProfileListWithError:(NSError *)error
{
    [self removeSpinner];
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
    [self validationAlert:[error localizedDescription]];
}
-(void)CheckTour
{
    
}
-(void)removeSpinner
{
    [Spinner showIndicator:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
