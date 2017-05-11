//
//  EditProfileViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
@synthesize txtLastName;
@synthesize txtFirstName;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Edit Profile";
    
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
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    txtFirstName.text = sharedModel.userProfile.fname;
    txtLastName.text = sharedModel.userProfile.lname;
    
    CGRect frame = txtFirstName.frame;
    frame.size.width = (Devicewidth-32);
    txtFirstName.frame = frame;
     frame = txtLastName.frame;
    frame.size.width = (Devicewidth-32);
    txtLastName.frame = frame;


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
        if([self validateFields:txtFirstName] && [self validateFields:txtLastName])
        {
            [txtFirstName resignFirstResponder];
            [txtLastName resignFirstResponder];
            [self callUpdateAPI];
        }
        else
        {
            [self validationAlert:ALL_FIELDS_REQUIRED];

        }
        
    }

    
}
-(void)callUpdateAPI {
    
    [Spinner showIndicator:YES];
    
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    [bodyRequest setValue:txtFirstName.text                 forKey:@"fname"];
    [bodyRequest setValue:txtLastName.text                  forKey:@"lname"];
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setValue:token.access_token               forKey:@"access_token"];
    [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
    [postData setValue:@"update_teacher"            forKey:@"command"];
    [postData setValue:bodyRequest                      forKey:@"body"];
    
    NSDictionary *userInfo = @{@"command":@"update_teacher"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@profiles/%@",BASE_URL, _userProfile.teacher_klid];
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self receivedJSON:[json objectForKey:@"response"]];
    } failure:^(NSDictionary *json) {
        
        [self fetchingJSONFailedWithError:nil];
    }];

    
}
- (void)receivedJSON:(NSDictionary *)jsonResponse
{
    ModelManager *sharedModel   = [ModelManager sharedModel];
    
    
    DebugLog(@"jsonResponse %@",jsonResponse);
    NSNumber *validResponseStatus = [jsonResponse valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSDictionary *dict = [jsonResponse objectForKey:@"body"];
        sharedModel.userProfile.fname = [dict valueForKey:@"fname"];
        sharedModel.userProfile.lname = [dict valueForKey:@"lname"];
        
        
        
        NSMutableDictionary *profilesListResponse = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"] mutableCopy];
        
        NSMutableDictionary *body =  [[profilesListResponse objectForKey:@"body"] mutableCopy];
        [body setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
        [body setObject:[dict objectForKey:@"lname"] forKey:@"lname"];
        [profilesListResponse setObject:body forKey:@"body"];
        [[NSUserDefaults standardUserDefaults] setObject:profilesListResponse forKey:@"userProfile"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    [Spinner showIndicator:NO];
    
    
}

- (void)fetchingJSONFailedWithError:(NSError *)error
{
    [Spinner showIndicator:NO];
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

- (IBAction)returnTapped:(id)sender {
    [sender resignFirstResponder];
}
@end
