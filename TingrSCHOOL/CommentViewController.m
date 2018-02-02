//
//  CommentViewController.m
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 16/04/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "CommentViewController.h"
#import "StreamDisplayView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface CommentViewController ()
{
    UITextView *commentsFields;
    UITextView *commentsFields2;
    UIButton *btnPrivacy;
    int numberOfTrails;
}
@end

@implementation CommentViewController

@synthesize selectedStoryDetails;
@synthesize streamView;
@synthesize btnPost;
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
#pragma mark - View Controller Life Cycle
#pragma mark -
- (void)viewDidLoad
{
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(keyboardWillShow:)
    //                                                 name:UIKeyboardWillShowNotification
    //                                               object:nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1]];
    
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    //    UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0,60,screenWidth,75)];
    //    [message setBackgroundColor:[UIColor colorWithRed:(252/255.f) green:(252/255.f) blue:(252/255.f) alpha:1]];
    //    [self.view addSubview:message];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 1)];
    topBorder.backgroundColor = [UIColor grayColor];
    [self.view addSubview:topBorder];
    
    //    UILabel *lblShare = [[UILabel alloc] initWithFrame: CGRectMake(10, 8, screenWidth-20, 65)];
    //    [lblShare setTextAlignment:NSTextAlignmentCenter];
    //    lblShare.text = @"Enter your comment. \nIt will only be viewable by mutual friends.";
    //    lblShare.lineBreakMode = NSLineBreakByWordWrapping;
    //    lblShare.numberOfLines = 3;
    //    lblShare.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    //    lblShare.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14];
    //    [message addSubview:lblShare];
    
    //    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, message.frame.size.height, self.view.frame.size.width, 1)];
    //    bottomBorder.backgroundColor = [UIColor grayColor];
    //    [message addSubview:bottomBorder];
    
    //wierd bug - leave this control here
    commentsFields = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [commentsFields setBackgroundColor:[UIColor whiteColor]];
    commentsFields.font = [UIFont systemFontOfSize:17];
    commentsFields.keyboardType = UIKeyboardTypeDefault;
    commentsFields.returnKeyType = UIReturnKeyDone;
    commentsFields.autocorrectionType = UITextAutocorrectionTypeYes;
    [commentsFields setDelegate:self];
    commentsFields.layer.cornerRadius = 5;
    [self.view addSubview:commentsFields];
    UIView *bottomView = [[UIView alloc]init];
    bottomView.layer.cornerRadius = 5;
    float topSape = 0;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.topSafeAreaInset)
    {
        topSape = 40;
    }
    
    commentsFields2 = [[UITextView alloc] initWithFrame:CGRectMake(15,80+topSape,Devicewidth-30, 150)];
    bottomView.frame = CGRectMake(15, commentsFields2.frame.origin.y + commentsFields2.frame.size.height + 15, 290, 37);
    [commentsFields2 setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [commentsFields2 setBackgroundColor:[UIColor whiteColor]];
    [commentsFields2 setReturnKeyType:UIReturnKeyDefault];
    commentsFields2.autocorrectionType = UITextAutocorrectionTypeYes;
    [commentsFields2 setDelegate:self];
    commentsFields2.layer.cornerRadius = 5;
    [self.view addSubview:commentsFields2];
    
    
    
    
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
    [button1 addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;
   
}
-(void)viewWillAppear:(BOOL)animated
{
    streamView.isCommented = YES;
    [commentsFields resignFirstResponder];
    [commentsFields2 becomeFirstResponder];
    
    [super viewWillAppear:YES];
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewDidUnload
{
    [super viewDidUnload];
    self.globalAlert = nil;
}
#pragma mark-
#pragma mark- Button Actions
-(void)privacyTapped:(id)sender
{
    [commentsFields resignFirstResponder];
    [commentsFields2 resignFirstResponder];
    
    ModelManager *modelManager= [ModelManager sharedModel];
    NSString *fname = modelManager.userProfile.fname;
    NSString *lname = modelManager.userProfile.lname;
    
    
    if (lname.length>0 && fname.length >0)
    {
        NSString *lInitial = [NSString stringWithFormat:@"%@'s circle",[lname substringToIndex:1]];
        reqName = [[NSString stringWithFormat:@"%@ %@",fname, lInitial] capitalizedString];
    }
    NSString *ownerName = [[selectedStoryDetails valueForKey:@"author_name"] capitalizedString];
    
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          [NSString stringWithFormat:@"%@'s circle",ownerName], @"Only mutual connections", nil];
    addImageActionSheet.tag = 1;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)postClicked:(id)sender
{
    [commentsFields resignFirstResponder];
    [commentsFields2 resignFirstResponder];
    //[self commentButtonTapped:textView];
}
- (void)keyboardWillShow:(NSNotification *)note {
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneButtonNormal.png"] forState:UIControlStateNormal];
    //[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
            [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
            [keyboardView addSubview:doneButton];
            [keyboardView bringSubviewToFront:doneButton];
            
            [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02
                                  delay:.0
                                options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                             animations:^{
                                 self.view.frame = CGRectOffset(self.view.frame, 0, 0);
                             } completion:nil];
        });
    }else {
        // locate keyboard view
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            UIView* keyboard;
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard view found; add the custom button to it
                if([[keyboard description] hasPrefix:@"UIKeyboard"] == YES)
                    [keyboard addSubview:doneButton];
            }
        });
    }
}


-(IBAction)commentButtonTapped:(id)sender
{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Please connect to network and try again"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        [alert show];
    }
    else
        
    
    {
        if (commentsFields2.text.length >0)
        {
            [commentsFields resignFirstResponder];
            [commentsFields2 resignFirstResponder];
            
            [btnPost setEnabled: NO];
            [btnPost setUserInteractionEnabled:NO];
            [self.postButton setEnabled:NO];
            //Tracking
            //[Flurry logEvent:@"Stream_AddComment_Post"];
            
            numberOfTrails = 0;
          
                [self callCommentAPIWithScope:@"public"];
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"TingrSCHOOL"
                                                                message:@"Please write a comment"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            self.globalAlert = alertView;
            [alertView show];
        }
    }
}
- (void)callCommentAPIWithScope:(NSString *)scope
{
    [self.postButton setEnabled:NO];
    
    [Spinner showIndicator:YES];

    
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken* token          = sharedModel.accessToken;
    UserProfile *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    [bodyRequest setValue:[selectedStoryDetails valueForKey:@"slug"]        forKey:@"post_slug"];
    [bodyRequest setValue:commentsFields2.text            forKey:@"text"];
    [bodyRequest setValue:scope                forKey:@"scope"];
    
    
    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    [finalRequest setValue:@"create"                forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    DebugLog(@"finalRequest:%@",finalRequest);
    NSString *urlString = [NSString stringWithFormat:@"%@comments",BASE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         [Spinner showIndicator:NO];

    
         DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
        
         if ([stringStatus1 isEqualToString:@"200"])
         {
             //[HUD hide:YES];
             NSMutableDictionary *dict = [[streamView.storiesArray objectAtIndex:streamView.commemtIndex] mutableCopy];
             NSMutableArray *array = [[NSMutableArray alloc] init];
             [array addObjectsFromArray:[dict objectForKey:@"comments"]];
             [array addObject:[responseObject objectForKey:@"body"]];
             [dict setObject:array forKey:@"comments"];
             
             //This lets the comments utils know that a comment was added
             [dict setValue:@"true" forKey:@"comment_added"];
             

             [streamView.storiesArray replaceObjectAtIndex:streamView.commemtIndex withObject:dict];
             [streamView.streamTableView reloadData];
                          [self.navigationController popViewControllerAnimated:YES];
             
         }
         else
         {
             //[HUD hide:YES];
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
         [Spinner showIndicator:NO];
         
            if (error.code == -1005)
            {
                if(numberOfTrails <= 100)
                {
                    numberOfTrails ++;
                    if(isvisible)
                        [self callCommentAPIWithScope:@"public"];
                    else
                        [self callCommentAPIWithScope:@"private"];
                    return ;
                }
                
            }
         
         
             [btnPost setEnabled:YES];
             [btnPost setUserInteractionEnabled:YES];
             [self.postButton setEnabled:YES];
             [self.postButton setEnabled:YES];
             
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while creating a  comment"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
            self.globalAlert = alertView;
             [alertView show];
     }];
    
    [operation start];
}
#pragma mark- UIActionSheet Delegate Methods
#pragma mark-
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    NSString *ownerName = [[selectedStoryDetails valueForKey:@"author_name"] capitalizedString];
                    
                    [btnPrivacy setFrame:CGRectMake(5, 4, 80, 30)];
                    [visible setFrame:CGRectMake(80, 9, 120, 20)];
                    visible.text = [NSString stringWithFormat:@"%@'s circle",ownerName];
                    friendsImageView.hidden = NO;
                    isvisible = YES;
                    NSUserDefaults *commentsDefaults = [NSUserDefaults standardUserDefaults];
                    [commentsDefaults setBool:YES forKey:@"isComment"];
                    [commentsDefaults synchronize];
                    break;
                }
                case 1:
                {
                    [btnPrivacy setFrame:CGRectMake(0, 4, 80, 30)];
                    [visible setFrame:CGRectMake(75, 9, 150, 20)];
                    visible.text = @"Only mutual connections";
                    friendsImageView.hidden = YES;
                    isvisible = NO;
                    NSUserDefaults *commentsDefaults = [NSUserDefaults standardUserDefaults];
                    [commentsDefaults setBool:NO forKey:@"isComment"];
                    [commentsDefaults synchronize];
                    break;
                }
                case 2 :
                {
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
#pragma mark- UITextView Delegate Methods
#pragma mark-
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
//    if ([text isEqualToString:@"\n"])
//    {
//        // The "Go" key was pressed, so submit the comment.
//        [textView resignFirstResponder];
//        //[self commentButtonTapped:textView];
//        return NO;
//    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
