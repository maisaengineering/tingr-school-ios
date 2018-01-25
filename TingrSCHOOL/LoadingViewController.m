
#import "ModelManager.h"
#import "VOAccessToken.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "StringConstants.h"
//#import "InitialViewController.h"
#import "MyScheduleViewController.h"
@interface LoadingViewController ()
{
    
}
@end

@implementation LoadingViewController
@synthesize singletonObj;
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

#pragma mark- ViewController Life Cycle Method
#pragma mark-
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    singletonObj = [SingletonClass sharedInstance];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //add image with the frame set so the bottom stays the same
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait"]];
    if(IDIOM == IPAD) {
        
        background.image = [UIImage imageNamed:@"Default-Portrait"];
    }
    background.frame = CGRectMake(0, 0, Devicewidth, Deviceheight);
    [self.view addSubview:background]; //screenHeight - 1136
    background.contentMode = UIViewContentModeScaleAspectFill;
    UILabel *lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0,100,320, 41)];
    [lblLoading setText:LOADING];
    [lblLoading setBackgroundColor:[UIColor clearColor]];
    [lblLoading setTextAlignment:NSTextAlignmentCenter];
    [lblLoading setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [lblLoading setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
   // [self.view addSubview:lblLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];
    
    if(key)
    {
        [self goToLogin];
    }
    else
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
            [self callAccessTokenApi];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.globalAlert = nil;
}
- (void)callAccessTokenApi
{
   
    [Spinner showIndicator:YES];
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"KidsApp"};
    NSDictionary* userInfo = @{@"command": @"userInfo"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    __weak __typeof(self)weakSelf = self;
        API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(weakSelf) {
            NSArray *tokenArray = [Factory tokenFromJSON:json];
            [weakSelf didReceiveTokens:tokenArray];
        }
        
    } failure:^(NSDictionary *json) {
        
        [weakSelf fetchingTokensFailedWithError:json];
        
    }];
    

    
}
-(void)goToLogin
{
    
 
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];

        
        if(key)
        {
            
            
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *initialViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                
                [[NSNotificationCenter defaultCenter]
                 addObserver:initialViewController
                 selector:@selector(popToLogin:)
                 name:POP_TO_LOGIN
                 object:nil ];
                
                MyScheduleViewController *mainTabViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MyScheduleViewController"];
                NSMutableArray *viewCntlArray = self.navigationController.viewControllers.mutableCopy;
                [viewCntlArray addObjectsFromArray:@[initialViewController,mainTabViewController]];
                [self.navigationController setViewControllers:viewCntlArray animated:YES];
        }
        else
        {
            [self performSegueWithIdentifier: @"LoginSegue" sender: self];
        }
    });
  
  
}

- (void)dismissSelf
{
    [self performSegueWithIdentifier: @"WelcomeSegue" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   /* if ([[segue identifier] isEqualToString:@"InitialSegue"])
    {
        InitialViewController *destViewCntrl = (InitialViewController *)[segue destinationViewController];
        [[NSNotificationCenter defaultCenter]
         addObserver:destViewCntrl
         selector:@selector(popToLogin:)
         name:POP_TO_LOGIN
         object:nil ];
        
    }
    */
}

#pragma mark- AccessTokenManagerDelegate Methods
#pragma mark-
- (void)didReceiveTokens:(NSArray *)tokens
{
    [Spinner showIndicator:NO];
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    
    [self goToLogin];
}



- (void)fetchingTokensFailedWithError:(NSDictionary *)error
{
    [Spinner showIndicator:NO];
    
    [self goToLogin];
}

#pragma mark- Memory warning Method
#pragma mark-
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
