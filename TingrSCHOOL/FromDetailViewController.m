//
//  FromDetailViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "FromDetailViewController.h"

@interface FromDetailViewController ()
{
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    UILabel *emptyContentLabel;
}
@end

@implementation FromDetailViewController
@synthesize webView;
@synthesize kid_klid;
@synthesize detailDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedModel = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    self.title = [detailDict objectForKey:@"name"];
    
    NSURL *url = [NSURL URLWithString:[detailDict objectForKey:@"url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    [self checkToHideEmptyMessage];

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

    
    UIImageView *imageView1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share.png"]];
    [imageView1 setTintColor:[UIColor redColor]];
    
    
    UIView *view1=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView1.frame.size.width+space, imageView1.frame.size.height)];
    
    view1.bounds=CGRectMake(view1.bounds.origin.x-10, view1.bounds.origin.y-1, view1.bounds.size.width, view1.bounds.size.height);
    [view1 addSubview:imageView1];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:view1.frame];
    [button1 addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    CGRect frame = webView.frame;
    frame.size.width = Devicewidth;
    frame.size.height = Deviceheight - appDelegate.bottomSafeAreaInset;
    webView.frame = frame;

    
    
}
-(void)showEmptyContentMessageView {
    
    
    if(emptyContentLabel == nil)
    {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        NSString *message = @"No documents available.";
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
        
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.attributedText = attributedString;
        messageLabel.frame = self.view.bounds;
        
        emptyContentLabel = messageLabel;
        
    }
    
    [self.view addSubview:emptyContentLabel];
    emptyContentLabel.hidden = NO;
    
}
-(void)checkToHideEmptyMessage {
    
    if([[detailDict objectForKey:@"url"] length] == 0)
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        [emptyContentLabel removeFromSuperview];
    }
}


-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)shareButtonTapped {
 
    UIActionSheet *addImageActionSheet;
    
    if([[detailDict objectForKey:@"url"] length] >0)
    {
        addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Request", @"Print", nil];
    }
    else {
        
        addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                               @"Request", nil];

        
    }
    addImageActionSheet.tag = 1000;
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

    
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
                    [self callRequestAPI];
                    break;
                }
                case 1:
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[detailDict objectForKey:@"url"]]];

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

-(void)callRequestAPI {
    
    
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"request_form_doc";
    NSDictionary *body = @{
                           @"id":[detailDict objectForKey:@"id"],
                           @"season_id":[[sharedInstance selecteRoom] objectForKey:@"season_id"],
                           @"organization_id":[[sharedInstance selecteRoom] objectForKey:@"organization_id"],
                           @"type":[detailDict objectForKey:@"type"],
                           @"kid_klid":[detailDict objectForKey:@"kid_klid"]
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@organizations",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf requestSuccessfull:[json objectForKey:@"response"]];
        
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
    }];
    
    
}

-(void)requestSuccessfull:(NSDictionary *)dict {
    
    NSString *string = [NSString stringWithFormat:@"%@ requested successfully",[detailDict objectForKey:@"type"]];
    
    if([dict objectForKey:@"message"])
        string = [dict objectForKey:@"message"];
    UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [disableAlert show];
    
    [Spinner showIndicator:NO];
    
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
