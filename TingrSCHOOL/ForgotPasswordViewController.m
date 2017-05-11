
#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize singletonObj;
@synthesize emailField;
@synthesize loginCntrl;

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
#pragma mark- Viewcontroller Delegate Methods
#pragma mark-
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    singletonObj = [SingletonClass sharedInstance];
    
    [self.navigationController setNavigationBarHidden:NO];
    //[self.navigationController setTitle:@"Forgot password"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;

    self.navigationItem.title = @"Forgot password";

    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_arrow.png"]];
    [imageView setTintColor:[UIColor redColor]];
    
    int space=6;
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView.frame.size.width+space, imageView.frame.size.height)];
    
    view.bounds=CGRectMake(view.bounds.origin.x+12, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(bakButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    UIImageView *imageView1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
    [imageView1 setTintColor:[UIColor redColor]];
    
    
    UIView *view1=[[UIView alloc] initWithFrame:CGRectMake(20, 0,60, 60)];
    
    
    imageView1.center = view1.center;
    [view1 addSubview:imageView1];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:view1.frame];
    [button1 addTarget:self action:@selector(resetPasswordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    [rightButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = rightButton;

    
    
    

    
    UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0,64,screenWidth,75)];
    [message setBackgroundColor:[UIColor colorWithRed:(252/255.f) green:(252/255.f) blue:(252/255.f) alpha:1]];
    [self.view addSubview:message];
    
    UILabel *lblShare = [[UILabel alloc] initWithFrame: CGRectMake(0, 8, screenWidth, 65)];
    [lblShare setTextAlignment:NSTextAlignmentCenter];
    lblShare.text = @"To reset your password, \nenter your email address below:";
    lblShare.lineBreakMode = NSLineBreakByWordWrapping;
    lblShare.textAlignment = NSTextAlignmentCenter;
    lblShare.numberOfLines = 2;
    lblShare.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    lblShare.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:17.0];
    [message addSubview:lblShare];
    
    
    UIImageView *bottomBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    bottomBorder.frame = CGRectMake(0, message.frame.origin.y+message.frame.size.height, self.view.frame.size.width, 1);
    [message addSubview:bottomBorder];
    
    
    UILabel *emailAddressLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, bottomBorder.frame.origin.y + 10, self.view.frame.size.width, 30)];
    [emailAddressLabel setTextAlignment:NSTextAlignmentLeft];
    emailAddressLabel.text = @"Your email address";
    emailAddressLabel.textColor = [UIColor colorWithRed:(114/255.f) green:(114/255.f) blue:(114/255.f) alpha:1];
    emailAddressLabel.highlighted = YES;
    emailAddressLabel.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14.0];
    [self.view addSubview:emailAddressLabel];

    emailField = [[UITextField alloc] initWithFrame:CGRectMake(20, emailAddressLabel.frame.origin.y + 25, self.view.frame.size.width-40, 41)];
    emailField.borderStyle = UITextBorderStyleNone;
    emailField.delegate = self;
    emailField.placeholder = @"Email";
    emailField.layer.borderColor = UIColor.whiteColor.CGColor;
    emailField.backgroundColor = UIColor.whiteColor;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    emailField.leftView = paddingView;
    emailField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:emailField];
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.globalAlert = nil;
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark- Actions
#pragma mark-
- (IBAction)resetPasswordButtonTapped:(id)sender
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        [alert show];
    }
    else
    {
        if (emailField.text.length > 0)
        {
            if([self validateEmailWithString:emailField.text])
            {
                [emailField resignFirstResponder];
            
                [Spinner showIndicator:YES];
                NSString *username = emailField.text;
                ModelManager *sharedModel = [ModelManager sharedModel];
                NSString* token = sharedModel.accessToken.access_token;
                
                NSDictionary* bodyData = @{@"email": username};
                
                //build an info object and convert to json
                NSDictionary* postData = @{@"command": @"forgot_password",
                                           @"access_token": token,
                                           @"body": bodyData};
                NSDictionary *userInfo = @{@"command":@"forgot_password"};
                
                NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
                
                NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
                API *api = [[API alloc] init];
                [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
                    
                    [Spinner showIndicator:NO];
                    [self sendSuccess];
                    
                } failure:^(NSDictionary *json) {
                    
                    [Spinner showIndicator:NO];
                    [self sendFailedWithError:json];
                }];
                
                
                
            }
            else
            {
                [self validationAlert:EMAIL_INVALID];
            }
        }
        else
        {
            [self validationAlert:ALL_FIELDS_REQUIRED];
            
        }
    }
}

-(void)cancelTapped
{
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)validationAlert: (NSString *) comment
{
    
    //[self removeActivityView];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Alert"
                          message:comment
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    self.globalAlert = alert;
    [alert show];
    
}

#pragma mark- ForgotPasswordManagerDelegate Methods
#pragma mark-
- (void)sendSuccessWithDetails:(NSMutableDictionary *)responseDetails
{
    
}

- (void)sendSuccess
{

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Success"
                          message:FORGOT_PASS_SUCCESS_MESSAGE
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    self.globalAlert = alert;
    [alert show];
    self.loginCntrl.isPwdChanged  =YES;
    [self.navigationController popViewControllerAnimated:NO];

}

- (void)sendFailedWithError:(NSDictionary *)error
{
    [self validationAlert:[error objectForKey:@"message"]];
}
#pragma mark- UITextFieldDelegate Methods
#pragma mark-
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
