//
//  EditNotesViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/13/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "EditNotesViewController.h"

@interface EditNotesViewController ()
{
    UIView *inputView;
    UILabel *placeholderLabel;
    UIButton *deletButton;
}
@end

@implementation EditNotesViewController
@synthesize kid_klid;
@synthesize kidDict;
@synthesize textView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(Devicewidth - 70 - 20, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];
    
    
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
    [button1 addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    

    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10,0,self.view.frame.size.width-20, self.view.frame.size.height - 60)];
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14]};
    [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [textView setTextColor:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1]];
    [textView setBackgroundColor:[UIColor whiteColor]];
    textView.autocorrectionType = UITextAutocorrectionTypeYes;
    [textView setDelegate:self];
    [self.view addSubview:textView];

    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, textView.frame.size.width - 15.0, 20)];
    placeholderLabel.text = @"type your notes...";
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [textView addSubview:placeholderLabel];

    
    deletButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deletButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deletButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deletButton.frame = CGRectMake((Devicewidth-100)/2, (self.view.frame.size.height - (appDelegate.bottomSafeAreaInset > 0 ? appDelegate.bottomSafeAreaInset+30 : 40)) , 100, 30);
    [deletButton addTarget:self action:@selector(deleteTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deletButton];
    
    if(kidDict == nil)
    {
        self.title = @"Add Notes";
        deletButton.hidden = YES;
    }
    else {
        
        self.title = @"Edit Notes";
        deletButton.hidden = NO;
        textView.text = [kidDict objectForKey:@"description"];
        [placeholderLabel removeFromSuperview];

    }
    

}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitButtonTapped:(id)sender
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
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
        if([textView hasText])
        {
            [textView resignFirstResponder];
            [self callNotesAPI];
        }
        else
        {
            [self validationAlert:@"Please enter notes"];
            
        }
        
    }

}
-(void)deleteTapped {
    
    UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Sure you want to delete this notes?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    
    [cautionAlert setTag:9988];
    
    [cautionAlert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Delete Caution Alert
    if (alertView.tag == 9988)
    {
        if (buttonIndex == 0)
        {
            [self callDeleteAPI];
        }
        else if (buttonIndex == 1)
        {
            // Cancel
        }
    }
}

-(void)callDeleteAPI {
    
    [Spinner showIndicator:YES];
    
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@notes/%@",BASE_URL,[kidDict objectForKey:@"kl_id"]];
    NSString *command = @"delete";
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setValue:token.access_token               forKey:@"access_token"];
    [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
    [postData setValue:command            forKey:@"command"];
    [postData setValue:bodyRequest                      forKey:@"body"];
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf notesSuccess:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
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
    [alert show];
}

-(void)doneClick:(id)sender
{
    [textView resignFirstResponder];
}

-(void)callNotesAPI {
    
    [Spinner showIndicator:YES];
    
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@notes",BASE_URL];
    NSString *command = @"create";
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    [bodyRequest setValue:textView.text                 forKey:@"description"];
    
    if(kidDict == nil)
    {
        [bodyRequest setValue:kid_klid                  forKey:@"kid_klid"];
        [bodyRequest setValue:[[[SingletonClass sharedInstance] selecteRoom]objectForKey:@"organization_id"]                  forKey:@"organization_id"];
    }
    else {
        
        urlAsString = [NSString stringWithFormat:@"%@notes/%@",BASE_URL,[kidDict objectForKey:@"kl_id"]];
        command = @"edit";
    }
    
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setValue:token.access_token               forKey:@"access_token"];
    [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
    [postData setValue:command            forKey:@"command"];
    [postData setValue:bodyRequest                      forKey:@"body"];
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf notesSuccess:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
        
        if([json objectForKey:@"message"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:[json objectForKey:@"message"]
                                                          delegate:nil cancelButtonTitle:@"Ok"
                                  
                                                 otherButtonTitles:nil,nil];
            [alert show];

        }
        

        
    }];
    

}
-(void)notesSuccess:(NSDictionary *)dict {
    
    [Spinner showIndicator:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [textView setInputAccessoryView:inputView];
    [placeholderLabel removeFromSuperview];
    
    return YES;
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView1 {
    
    [textView setInputAccessoryView:inputView];
    [placeholderLabel removeFromSuperview];
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![textView hasText])
    {
        [textView addSubview:placeholderLabel];
    }
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView hasText])
    {
        [textView addSubview:placeholderLabel];
    }
    else if ([[textView subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
    
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    
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
