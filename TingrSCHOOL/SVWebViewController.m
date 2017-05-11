//
//  SVWebViewController.m
//


//#import "SVWebViewControllerActivityChrome.h"
//#import "SVWebViewControllerActivitySafari.h"
#import "SVWebViewController.h"
//#import "LoginApiCalls.h"
#import "MBProgressHUD.h"
//#import "OnboardingWellnessLogoViewController.h"
@interface SVWebViewController () <UIWebViewDelegate,MBProgressHUDDelegate>
{
//    LoginApiCalls *apiCalls;
    NSString *title;
}
@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *URL;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (void)loadURL:(NSURL*)URL;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation SVWebViewController
@synthesize isHide;
@synthesize isPopup;
#pragma mark - Initialization

- (void)dealloc {
    [self.webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.delegate = nil;
}

- (id)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    
    if(self = [super init]) {
        self.URL = pageURL;
    }
    
    return self;
}

- (void)loadURL:(NSURL *)pageURL {
    [self.webView loadRequest:[NSURLRequest requestWithURL:pageURL]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    
    if(isPopup)
    {
        UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [navigationView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:navigationView];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, navigationView.frame.size.height - 1, self.view.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        [navigationView addSubview:bottomBorder];
        
        //put in Done button
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnDone setTitle:@"Back" forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnDone.frame = CGRectMake(15, 20, 44, 36);
        [btnDone setTitleColor:[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] forState:UIControlStateNormal];
        [navigationView addSubview:btnDone];
    }
    [self loadURL:self.URL];
    
    title = self.title;
    if ([title isEqualToString:@"Sign up"])
    {
        
    }
    else
    {
        [self updateToolbarItems];
    }
    
    

}
-(IBAction)doneButtonClicked:(id)sender
{
    //dispatch a call back to parent to be handled
    //TODO: OR just animate back down and set the page to a blank one
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_WEBVIEW" object:nil userInfo:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _actionBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([title isEqualToString:@"Sign up"])
        {
            [self.navigationController setToolbarHidden:YES animated:animated];
        }
        else
        {
            [self.navigationController setToolbarHidden:NO animated:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([title isEqualToString:@"Sign up"])
        {
            
           
                [self.navigationController setToolbarHidden:NO animated:animated];
        }
        else
        {
            [self.navigationController setToolbarHidden:YES animated:animated];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SHOW_TABS" object:nil];
    
    NSMutableArray *array = [[self.navigationController viewControllers] mutableCopy];
    [array removeObject:self];
    self.navigationController.viewControllers = array;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Getters

- (UIWebView*)webView {
    if(!_webView) {
        if(isHide)
        {
            CGRect rect = [UIScreen mainScreen].bounds;
            rect.size.height += 48.5;
            _webView = [[UIWebView alloc] initWithFrame:rect];
        }
        else
            _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/SVWebViewControllerBack"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goBackClicked:)];
        _backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
        _forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/SVWebViewControllerNext"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(goForwardClicked:)];
        _forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        _refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    if (!_stopBarButtonItem) {
        _stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return _stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return _actionBarButtonItem;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = self.self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.self.webView.canGoForward;
    self.actionBarButtonItem.enabled = !self.self.webView.isLoading;
    
    UIBarButtonItem *refreshStopBarButtonItem = self.self.webView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;
        
        /*  NSArray *items = [NSArray arrayWithObjects:
         fixedSpace,
         refreshStopBarButtonItem,
         fixedSpace,
         self.backBarButtonItem,
         fixedSpace,
         self.forwardBarButtonItem,
         fixedSpace,
         self.actionBarButtonItem,
         nil];
         */
        
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          refreshStopBarButtonItem,
                          fixedSpace,
                          self.backBarButtonItem,
                          fixedSpace,
                          self.forwardBarButtonItem,fixedSpace,
                          nil];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        toolbar.tintColor = [UIColor blueColor];
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }
    
    else
    {
        /*  NSArray *items = [NSArray arrayWithObjects:
         fixedSpace,
         self.backBarButtonItem,
         flexibleSpace,
         self.forwardBarButtonItem,
         flexibleSpace,
         refreshStopBarButtonItem,
         flexibleSpace,
         self.actionBarButtonItem,
         fixedSpace,
         nil];*/
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.backBarButtonItem,
                          flexibleSpace,
                          self.forwardBarButtonItem,
                          flexibleSpace,
                          refreshStopBarButtonItem,
                          nil];
        
        [self.navigationController.toolbar setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x,
                                                               self.view.frame.size.height - 44,
                                                               self.navigationController.toolbar.frame.size.width,
                                                               self.navigationController.toolbar.frame.size.height)];
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f];
        
        self.toolbarItems = items;
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([title isEqualToString:@"Sign up"])
    {
        
    }
    else
    {
        [self updateToolbarItems];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([title isEqualToString:@"Sign up"])
    {
        
    }
    else
    {
        [self updateToolbarItems];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([title isEqualToString:@"Sign up"])
    {
        
    }
    else
    {
        [self updateToolbarItems];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
//    [self gotoPreTour];
//    return NO;
    NSString *url = [[request URL] absoluteString];
    
    static NSString *kidsLinkPrefix = @"kidslink://pop";
    DebugLog(@"URL Passed In: %@.", url);
    if([url hasPrefix:kidsLinkPrefix])
    {
        DebugLog(@"url:%@.", url);
        
        //NSString *command = [url stringByReplacingOccurrencesOfString:@"kidslink://" withString:@""]; //do what we need to with this command
        //TODO: When we centrallize to one UIWebView, this command will be important
        // To hide the bottom nav bar
        [self.navigationController setToolbarHidden:YES animated:YES];
        //This web view uses the "pop" command
        //  kidslink://pop/utk="trfdg"
        
        [Spinner showIndicator:YES];
       /* NSString *utoken = [url stringByReplacingOccurrencesOfString:@"kidslink://pop/utk=" withString:@""];
        apiCalls = [[LoginApiCalls alloc] init];
        apiCalls.navigationCntrl = self.navigationController;
        apiCalls.delegate = self;
        [apiCalls performSelector:@selector(callLoginApiFromInvitation:) withObject:utoken afterDelay:0.0];
       */
        return YES;
    }
    
    return YES;
    
}

-(void)gotoPreTour {
 
    /*
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreTourViewController *preTourViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PreTourViewController"];
    //preTourViewController.onBoardingPartnerDetails = [[NSMutableDictionary alloc]initWithDictionary:[onBoardingPartnerDetails mutableCopy]];
  //  [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:preTourViewController animated:YES];
    

    */
}
#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [self.webView stopLoading];
    if ([title isEqualToString:@"Sign up"])
    {
        
    }
    else
    {
        [self updateToolbarItems];
    }}

- (void)actionButtonClicked:(id)sender {
    /*    NSArray *activities = @[[SVWebViewControllerActivitySafari new], [SVWebViewControllerActivityChrome new]];
     NSURL *url = self.webView.request.URL ? self.webView.request.URL : self.URL;
     UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:activities];
     [self presentViewController:activityController animated:YES completion:nil];
     */
}

#pragma mark -
#pragma mark Methods to auto login
-(void)loginSuccessFul
{
    [Spinner hide:YES];
}

@end
