//
//  PostDetailedViewController.m
//  TingrSCHOOL
//
//  Created by maisapride on 01/02/18.
//  Copyright © 2018 Maisa Pride. All rights reserved.
//

#import "PostDetailedViewController.h"
#import "StreamDisplayView.h"
#import "HeartersViewController.h"
#import "CommentViewController.h"
#import "SVWebViewController.h"
@interface PostDetailedViewController ()<StreamDisplayViewDelegate>
{
    
    AppDelegate *appDelegate;
    StreamDisplayView *streamView;
    NSMutableArray *storiesArray;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;

}
@end

@implementation PostDetailedViewController
@synthesize post_ID;
@synthesize comment_ID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    sharedInstance = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.title = @"Moment";
    streamView = [StreamDisplayView alloc];
    streamView.isMainView = NO;
    [streamView setDelegate:self];
    
    streamView.post_ID = post_ID;
    streamView.comment_ID = comment_ID;
    streamView = [streamView initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight - appDelegate.bottomSafeAreaInset)];
    [self.view addSubview:streamView];
    // back button
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

    
    [self postDetailsAPI];
    // Do any additional setup after loading the view.
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        
        [alert show];
    }
    else
    {
        if(streamView.isCommented)
        {
            streamView.isCommented = NO;
            
            [streamView.streamTableView reloadData];
        }
        else
        {
            if(streamView.isEdited)
            {
                streamView.isEdited = NO;
                [streamView.streamTableView reloadData];
            }
            
            
        }
    }
    
}
-(void)postDetailsAPI {
    
        NSString *kl_id = [NSString stringWithFormat:@"%@",post_ID];
        
        [Spinner showIndicator:YES];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString* command = @"post_view";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body":@{@"post_klid": kl_id}
                               };
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        
            NSDictionary *body = [[json objectForKey:@"response"] objectForKey:@"body"];
            streamView.storiesArray = [NSMutableArray arrayWithObject:[[body objectForKey:@"post"] mutableCopy]];
            [streamView.streamTableView reloadData];
        
        [Spinner showIndicator:NO];
        
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
    }];
    
}



#pragma mark -
#pragma mark Stream Api
- (void)tableScrolled:(float)index {
    
    
}
- (void)commentClick:(int)index
{
    streamView.commemtIndex = index;
    CommentViewController *commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentViewController.streamView = streamView;
    commentViewController.selectedStoryDetails = [[NSMutableDictionary alloc]initWithDictionary:[streamView.storiesArray objectAtIndex:index]];
    [self.navigationController pushViewController:commentViewController animated:YES];
    
}
- (void)readArticleClicked:(NSString *)index
{
    //ReadArticleViewController *readArticleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadArticleViewController"];
    //readArticleViewController.html = index;
    //[self.navigationController pushViewController:readArticleViewController animated:YES];
    
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:index]];
    webViewController.isHide = YES;
    webViewController.title = @"Article";
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HIDE_TABS" object:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)heartersClick:(int)index
{
    streamView.commemtIndex = index;
    streamView.isCommented = YES;
    HeartersViewController *heartersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeartersViewController"];
    heartersViewController.selectedStoryDetails = [[NSMutableDictionary alloc]initWithDictionary:[streamView.storiesArray objectAtIndex:index]];
    [self.navigationController pushViewController:heartersViewController animated:YES];
    
}
- (void)addHeartClick:(int)index withCommand:(NSString *)commandName
{
    streamView.commemtIndex = index;
    
    NSString *kl_id = [NSString stringWithFormat:@"%@",[[streamView.storiesArray objectAtIndex:index] objectForKey:@"kl_id"]];
    sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    // NSString* postCommand = @"add_heart";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": commandName,
                               };
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,kl_id];
    
    DebugLog(@"URL:%@",urlAsString);
    DebugLog(@"postData:%@",postData);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         //DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             NSString *command = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"command"]];
             if ([command isEqualToString:@"add_heart"])
             {
                 NSMutableDictionary *dict = [[streamView.storiesArray objectAtIndex:streamView.commemtIndex] mutableCopy];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"asset_base_url"]  forKey:@"asset_base_url"];
                 
                 [dict setObject:[NSNumber numberWithBool:NO] forKey:@"local_change"];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"heart_icon"]  forKey:@"heart_icon"];
                 
                 [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"hearted"];
                 
                 [streamView.storiesArray replaceObjectAtIndex:streamView.commemtIndex withObject:dict];
                 [streamView.streamTableView reloadData];
             }
             else if ([command isEqualToString:@"remove_heart"])
             {
                 NSMutableDictionary *dict = [[streamView.storiesArray objectAtIndex:streamView.commemtIndex] mutableCopy];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"asset_base_url"]  forKey:@"asset_base_url"];
                 
                 [dict setObject:[NSNumber numberWithBool:NO] forKey:@"local_change"];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"heart_icon"]  forKey:@"heart_icon"];
                 
                 [dict setObject:[NSNumber numberWithBool:NO]  forKey:@"hearted"];
                 
                 [streamView.storiesArray replaceObjectAtIndex:streamView.commemtIndex withObject:dict];
                 [streamView.streamTableView reloadData];
             }
             
         }
         else
         {
             //[HUD hide:YES];
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (error.code == -1005)
         {
             
             [self addHeartClick:index withCommand:commandName];
             return ;
         }
         DebugLog(@"add heart failure");
         DebugLog(@"error:%@",error.description);
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at server while hearting a post"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
         
     }];
    
    [operation start];
}

- (void)showVerifiedPhone {
    
}


- (void)streamCountReturned:(int)total {
    
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
