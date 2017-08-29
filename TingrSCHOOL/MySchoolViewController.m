//
//  MySchoolViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/11/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MySchoolViewController.h"

@interface MySchoolViewController ()<UIWebViewDelegate>
{
    UIWebView *webView;
}
@end

@implementation MySchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My School";
    // Do any additional setup after loading the view.
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    
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

    [self callSchoolAPI];
}

-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)callSchoolAPI {
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSMutableDictionary *changePasswordDetails = [[NSMutableDictionary alloc]init];
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"school_info",
                               @"body": changePasswordDetails};
    
    NSDictionary *userInfo = @{@"command":@"school_info"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@teachers",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    [Spinner showIndicator:YES];
    __weak __typeof(self)weakSelf = self;
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(weakSelf){
            
            [Spinner showIndicator:NO];
            [self loadUrl:[[[json objectForKey:@"response"] objectForKey:@"body"] objectForKey:@"url"]];
            
        }
        
    } failure:^(NSDictionary *json) {
        
        if(weakSelf){
            
            [Spinner showIndicator:NO];
            
        }
        
    }];

    
    
}
-(void)loadUrl:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
  /*  NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
   */
    
    [webView loadRequest:request];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
