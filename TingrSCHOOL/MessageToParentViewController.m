//
//  MessageToParentViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/20/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MessageToParentViewController.h"

@interface MessageToParentViewController ()
{
    UITextView *txt_comment;
    UIView *inputView;
    UILabel *placeholderLabel;
     UITextView *commentsFields;
    ModelManager *sharedModel;
}
@end

@implementation MessageToParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Message";
    
    sharedModel = [ModelManager sharedModel];
    
    commentsFields = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [commentsFields setBackgroundColor:[UIColor whiteColor]];
    commentsFields.font = [UIFont systemFontOfSize:15];
    commentsFields.keyboardType = UIKeyboardTypeDefault;
    commentsFields.returnKeyType = UIReturnKeyDone;
    commentsFields.autocorrectionType = UITextAutocorrectionTypeYes;
    [commentsFields setDelegate:self];
    commentsFields.layer.cornerRadius = 5;
    [self.view addSubview:commentsFields];
    
    float topSape = 0;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.topSafeAreaInset)
    {
        topSape = 40;
    }
    
    txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(15,80+topSape,Devicewidth-30, 150)];
    [txt_comment setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [txt_comment setBackgroundColor:[UIColor whiteColor]];
    [txt_comment setReturnKeyType:UIReturnKeyDefault];
    txt_comment.autocorrectionType = UITextAutocorrectionTypeYes;
    [txt_comment setDelegate:self];
    txt_comment.layer.cornerRadius = 5;
    txt_comment.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txt_comment.layer.borderWidth = 1;
    [self.view addSubview:txt_comment];

    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 2, txt_comment.frame.size.width - 15.0, 30)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"type your message here...";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
    [placeholderLabel setTextColor:[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0]];
    [txt_comment addSubview:placeholderLabel];


    
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
    
    
    UIView *view1=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView1.frame.size.width+space, imageView1.frame.size.height)];
    
    view1.bounds=CGRectMake(view1.bounds.origin.x-10, view1.bounds.origin.y-1, view1.bounds.size.width, view1.bounds.size.height);
    [view1 addSubview:imageView1];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:view1.frame];
    [button1 addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;

    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(Devicewidth-70, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];

}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneClick:(id)sender
{
    [txt_comment resignFirstResponder];
}



-(void)sendButtonTapped
{
    
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if(txt_comment.text.length ==  0 || ([[txt_comment.text stringByTrimmingCharactersInSet: set] length] == 0))
    {
        ShowAlert(PROJECT_NAME, @"Please enter message", @"OK");
        return;
    }
    
    
    
    
    [txt_comment resignFirstResponder];
    
    
    [Spinner showIndicator:YES];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:sharedModel.userProfile.teacher_klid forKeyPath:@"sender_klid"];
    [dict setValue:_kid_klid forKeyPath:@"kid_klid"];
    [dict setValue:([[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"])?[[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"]:@"" forKeyPath:@"organization_id"];
    
    [dict setValue:[[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"session_id"] forKeyPath:@"session_id"];

    [dict setValue:[[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"season_id"] forKeyPath:@"season_id"];

    [dict setValue:txt_comment.text forKeyPath:@"text"];
    
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"send_message",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"send_message"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;

    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(weakSelf)
        {
            NSDictionary *body = [json objectForKey:@"response"];
            ShowAlert(PROJECT_NAME, ([[body objectForKey:@"message"] length] >0)?[body objectForKey:@"message"]:@"Message Successfully Sent.", @"OK");

            [self.navigationController popViewControllerAnimated:YES];
        }
        [Spinner showIndicator:NO];
    } failure:^(NSDictionary *json) {
        [Spinner showIndicator:NO];
    }];
    
    [txt_comment addSubview:placeholderLabel];
    txt_comment.text = @"";
}

- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [placeholderLabel removeFromSuperview];
    [textView1 setInputAccessoryView:inputView];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [textView1 setInputAccessoryView:inputView];
    [placeholderLabel removeFromSuperview];
    
    return YES;
    
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![txtView hasText])
        [txtView addSubview:placeholderLabel];
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView1 hasText])
    {
        [textView1 addSubview:placeholderLabel];
    }
    else if ([[textView1 subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    
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
