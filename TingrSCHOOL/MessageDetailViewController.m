//
//  MessageDetailViewController.m
//  Tingr
//
//  Created by Maisa Pride on 1/21/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "UIImageView+AFNetworking.h"
@interface MessageDetailViewController ()
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    AppDelegate *appDelegate;
    CGRect originalPostion;
    UIView *inputView;
    CGRect keyboardFrameBeginRect;
    UILabel *placeholderLabel;
    ModelManager *sharedModel;
    BOOL bProcessing;
    BOOL isDragging;
    BOOL isMoreAvailabel;
    NSMutableArray *sortedKeys;
    UIRefreshControl *refreshControl;
}
@end

@implementation MessageDetailViewController

@synthesize messagesData;
@synthesize messageDetailTableView;
@synthesize messageDictFromLastPage;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedModel   = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = @"Messages";
    
    messageDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight - 40 - appDelegate.bottomSafeAreaInset)];
    [messageDetailTableView setDelegate:self];
    [messageDetailTableView setDataSource:self];
    messageDetailTableView.tableFooterView = [[UIView alloc] init];
    messageDetailTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:messageDetailTableView];

    refreshControl = [[UIRefreshControl alloc]init];
    
    refreshControl.transform = CGAffineTransformMakeScale(0.75, 0.75);

    [messageDetailTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    
    originalPostion = messageDetailTableView.frame;
    
    messagesData = [[NSMutableDictionary alloc] init];
    [self createMessageView];
    
    
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
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.navigationController setNavigationBarHidden:NO];

    [self getMessages];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)setupTableViewHeader
{
    // set up label
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    //    label.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    //    label.textAlignment = NSTextAlignmentCenter;
    //    label.text = @"Loading";
    //    self.footerLabel = label;
    //    [footerView addSubview:label];
    
    // 29=05-2014 changes
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = headerView.center
    ;
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [headerView addSubview:activityIndicatorView];
    
    
    messageDetailTableView.tableHeaderView = headerView;
}

-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createMessageView {
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, messageDetailTableView.frame.origin.y+messageDetailTableView.frame.size.height, Devicewidth, 40)];
    self.commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth-70, 40)];
    self.txt_comment.delegate = self;
    [self.txt_comment setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:17]];
    
    [self.commentView addSubview:self.txt_comment];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, self.txt_comment.frame.size.width - 15.0, 40)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"type your message here...";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:17]];
    [placeholderLabel setTextColor:[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0]];
    [self.txt_comment addSubview:placeholderLabel];
    
    
    //Upvote
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(Devicewidth-60, 0, 50, 40)];
    [sendBtn setTitleColor:UIColorFromRGB(0x6fa8dc) forState:UIControlStateNormal];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Light" size:17]];
    [sendBtn addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:sendBtn];
    
    //Upvote
    UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, Devicewidth, 0.5)];
    line.font =[UIFont fontWithName:@"SanFranciscoText-Light" size:10];
    [line setTextAlignment:NSTextAlignmentLeft];
    line.backgroundColor = [UIColor colorWithRed:(200/255.f) green:(200/255.f) blue:(200/255.f) alpha:1];
    [self.commentView addSubview:line];
    
    
    inputView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 40)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.56f
                                                  green:0.59f
                                                   blue:0.63f
                                                  alpha:1.0f]];
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(Devicewidth-70, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:17]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:donebtn];

}

-(void)getMessages
{
    if(bProcessing)
        return;
    
    bProcessing = YES;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"kid_klid"] forKeyPath:@"kid_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"organization_id"] forKeyPath:@"organization_id"];
    
    
    if(messagesData.count > 0)
    {
        NSArray *detailsArray = [messagesData objectForKey:[sortedKeys firstObject]];
        NSDictionary *detailsDict = [detailsArray firstObject];
        [dict setValue:[detailsDict objectForKey:@"created_at"] forKeyPath:@"last_message_time"];
    }
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"messages",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"messages"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        [weakSelf didRecievedMessages:[json objectForKey:@"response"]];

    } failure:^(NSDictionary *json) {
        [weakSelf didFailedToRecieveMessages:[json objectForKey:@"response"]];
    
    }];

    
}
-(void)didRecievedMessages:(NSDictionary *)parsedObject {
    
    [self.activityIndicator stopAnimating];
    
    NSMutableArray *unreadMessages = [[NSMutableArray alloc] init];
    NSDictionary *messagesDict = [[parsedObject objectForKey:@"body"] objectForKey:@"messages"];
    
    NSArray *keysArray = [messagesDict allKeys];
    for(NSString *key in keysArray)
    {
        NSArray *msgArray = [messagesDict objectForKey:key];
        
        NSArray *array  = [msgArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_message != 1"]];
        
        if([[messageDictFromLastPage objectForKey:@"conversation_klid"] length] == 0)
        {
            [messageDictFromLastPage setObject:[[msgArray firstObject] objectForKey:@"conversation_klid"] forKey:@"conversation_klid"];
        }
        
        if(array.count > 0)
            [unreadMessages addObjectsFromArray:array];
    }

    
        if([messagesData count] > 0)
        {
            for(NSString *key in keysArray)
            {
                NSArray *msgArray = [messagesDict objectForKey:key];
                NSMutableArray *currentDateArray = [[messagesData objectForKey:key] mutableCopy];
                if(currentDateArray == nil)
                {
                    currentDateArray = msgArray.mutableCopy;

                }
                else
                {
                    for(int i= (int)msgArray.count-1; i>=0; i--)
                    {
                        NSDictionary *dict = msgArray[i];
                        [currentDateArray insertObject:dict atIndex:0];
                    }
                }
                [messagesData setObject:currentDateArray forKey:key];
            }
            
        }
        else
        {
            messagesData = [[[parsedObject objectForKey:@"body"] objectForKey:@"messages"] mutableCopy];

        }
    
        if([messagesDict count] == 0)
        {
            messageDetailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            isMoreAvailabel = NO;
        }
        else
        {
           // [self setupTableViewHeader];
            isMoreAvailabel  = YES;
        }
    
    NSArray *aUnsorted = [messagesData allKeys];
    sortedKeys= [[aUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        NSDate *d1 = [df dateFromString:(NSString*) obj1];
        NSDate *d2 = [df dateFromString:(NSString*) obj2];
        return [d1 compare: d2];
    }] mutableCopy];

    
    [messageDetailTableView reloadData];
    bProcessing = NO;
    
  //  if(!isDragging)
   // [messageDetailTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
    if(unreadMessages.count)
        [self callReadMessages:unreadMessages];
    
    [refreshControl endRefreshing];
    
    [[SingletonClass sharedInstance] setMessageCount:@"0"];
}

-(void)didFailedToRecieveMessages:(NSDictionary *)parsedObject {
    
    
    [refreshControl endRefreshing];
    
    [self.activityIndicator stopAnimating];
    bProcessing = NO;
    
}


-(void)callReadMessages:(NSArray *)array{
   
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if([[messageDictFromLastPage objectForKey:@"conversation_klid"] length] >0)
        [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    else
        [dict setValue:[[array firstObject] objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:sharedModel.userProfile.teacher_klid forKeyPath:@"profile_klid"];
    
    NSMutableArray *msgIdsArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in array)
    {
        [msgIdsArray addObject:[dict objectForKey:@"kl_id"]];
    }
    
    
    [dict setValue:msgIdsArray forKeyPath:@"messages_klid"];
    

    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"read_message",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"read_message"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
    } failure:^(NSDictionary *json) {

    }];
    
    
}

-(void)sendButtonTapped
{
    
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if(self.txt_comment.text.length ==  0 || ([[self.txt_comment.text stringByTrimmingCharactersInSet: set] length] == 0))
    {
        ShowAlert(PROJECT_NAME, @"Please enter message", @"OK");
        return;
    }
    
    
    
    
    [self.txt_comment resignFirstResponder];
    
    
    [Spinner showIndicator:YES];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:sharedModel.userProfile.teacher_klid forKeyPath:@"sender_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"kid_klid"] forKeyPath:@"kid_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"organization_id"] forKeyPath:@"organization_id"];
    [dict setValue:self.txt_comment.text forKeyPath:@"text"];
    
    
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
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self addCurrentMessage:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
        [Spinner showIndicator:NO];
    } failure:^(NSDictionary *json) {
        [Spinner showIndicator:NO];
    }];

    [self.txt_comment addSubview:placeholderLabel];
    self.txt_comment.text = @"";
}
-(void)addCurrentMessage:(NSDictionary *)message {
    
    
    if([[messageDictFromLastPage objectForKey:@"conversation_klid"] length] == 0)
    {
        NSMutableDictionary *dict = [messageDictFromLastPage mutableCopy];
        [dict setObject:[message objectForKey:@"conversation_klid"] forKey:@"conversation_klid"];
        messageDictFromLastPage = dict;
    }

    
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *key  = [formatter stringFromDate:date];
    
    NSMutableArray *currentDateArray = [[messagesData objectForKey:key] mutableCopy];
    if(currentDateArray == nil)
    {
        currentDateArray = [[NSMutableArray alloc] init];
        [currentDateArray addObject:message];
    }
    else
    {
        [currentDateArray addObject:message];
    }
    
    [messagesData setObject:currentDateArray forKey:key];
    
    NSArray *aUnsorted = [messagesData allKeys];
    sortedKeys= [[aUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        NSDate *d1 = [df dateFromString:(NSString*) obj1];
        NSDate *d2 = [df dateFromString:(NSString*) obj2];
        return [d1 compare: d2];
    }] mutableCopy];

    
    [messageDetailTableView reloadData];
    
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[messagesData.count-1]];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: detailsArray.count-1  inSection: messagesData.count-1];
    [messageDetailTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];

    
    
}
-(void)doneClick:(id)sender
{
    [self.txt_comment resignFirstResponder];
    messageDetailTableView.frame = originalPostion;
}


#pragma mark 
#pragma TableVie Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    long int count = messagesData.count;
    return count;

    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[section]];
    return detailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[indexPath.section]];
    NSDictionary *detailsDict = detailsArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];
    NSString *childName = [detailsDict objectForKey:@"child_name"];
    NSString *childRelationship = [detailsDict objectForKey:@"child_relationship"];

    
    NSString *content = [NSString stringWithFormat:@"%@\n%@",name,text];
    
    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
    
    if ( IDIOM == IPAD ) {

        normalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        textFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
    }


    NSString *relationText = @"";
    if(childName.length >0 && childRelationship.length >0)
    {
        relationText = [NSString stringWithFormat:@"%@'s %@",childName,childRelationship];
        content = [NSString stringWithFormat:@"%@ %@\n%@",name,relationText,text];
    }

    
        NSDictionary *attributes = @{NSFontAttributeName : normalFont};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content   attributes:attributes];
    
    NSRange redTextRange = [content rangeOfString:name];
    [attributedString setAttributes:@{NSFontAttributeName:textFont}
                            range:redTextRange];
    
    NSRange relationTextRange = [content rangeOfString:relationText];
    [attributedString setAttributes:@{NSFontAttributeName:redFont}
                              range:relationTextRange];

    
    
        NIAttributedLabel *textView = [NIAttributedLabel new];
        textView.numberOfLines = 0;
        textView.attributedText = attributedString;
        CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-116, 9999)];
    
    float height = 0;
        if(expectedLabelSize.height > 47) //if there is a lot of text
        {
            height+=expectedLabelSize.height+10;
        }
        else //set a default size
        {
            height+=47+10;
        }
    return height;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 30)];
    view.backgroundColor = [UIColor whiteColor];
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
    upperBorder.frame = CGRectMake(0, 30, Devicewidth , 1.0f);
    [view.layer addSublayer:upperBorder];

    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    [label setText:sortedKeys[section]];
    label.textAlignment = NSTextAlignmentCenter;
    label.font =[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16];
    if ( IDIOM == IPAD ) {
        label.font =[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16];
    }
    label.textColor = [UIColor lightGrayColor];
    [view addSubview:label];
    
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }

    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[indexPath.section]];
    NSDictionary *detailsDict = detailsArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];
    NSString *url = [detailsDict objectForKey:@"photograph"];
    NSString *childName = [detailsDict objectForKey:@"child_name"];
    NSString *childRelationship = [detailsDict objectForKey:@"child_relationship"];

    
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 47, 47)];
        [imagVw setImage:[UIImage imageNamed:@"tag_thumbnail.png"]];
        //add initials
    
        NSString *firstName = [[name substringToIndex:1]uppercaseString];;
    
        
        NSMutableString *commenterInitial = [[NSMutableString alloc] init];
        [commenterInitial appendString:firstName];
    
        NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
        
        NSRange range;
        if(firstName.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:20]}
                                              range:range];
        }
    
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
        initial.attributedText = attributedTextForComment;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [imagVw addSubview:initial];
        //end add initials
        
        __weak UIImageView *weakSelf = imagVw;
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [weakSelf setImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(51, 51)] withRadious:0]];
                 [initial removeFromSuperview];
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }
        
        [cell.contentView addSubview:imagVw];
    
    
    
    NSString *relationText = @"";
    NSString *content = [NSString stringWithFormat:@"%@\n%@",name,text];
    if(childName.length >0 && childRelationship.length >0)
    {
        relationText = [NSString stringWithFormat:@"%@'s %@",childName,childRelationship];
        content = [NSString stringWithFormat:@"%@ %@\n%@",name,relationText,text];
    }

    
    
    
    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    UIFont *redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
    
    if ( IDIOM == IPAD ) {
        
        normalFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        textFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
        redFont = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
    }
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:normalFont};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content   attributes:attributes];
    
    NSRange redTextRange = [content rangeOfString:name];
    [attributedString setAttributes:@{NSFontAttributeName:textFont}
                              range:redTextRange];
    
    NSRange relationTextRange = [content rangeOfString:relationText];
    [attributedString setAttributes:@{NSFontAttributeName:redFont}
                              range:relationTextRange];

    
    NIAttributedLabel *textView = [NIAttributedLabel new];
    textView.numberOfLines = 0;
    textView.delegate = self;
    textView.autoDetectLinks = YES;
    textView.attributedText = attributedString;
    [cell.contentView addSubview:textView];
    
   CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-116, 9999)];
    
    textView.frame =  CGRectMake(58, 5, Devicewidth-116, expectedLabelSize.height);


    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 58, 0.0, 0.0)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//If all fails, you may brute-force your Table View margins:
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([messageDetailTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [messageDetailTableView setSeparatorInset:UIEdgeInsetsMake(0.0, 58, 0.0, 0.0)];
    }
    
    if ([messageDetailTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [messageDetailTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (bProcessing) return;
    
    
    if (scrollView.contentOffset.y <= 0)
    {
        // ask next page only if we haven't reached last page
        if(isMoreAvailabel)
        {
            isDragging = YES;
            [self.activityIndicator startAnimating];
            [self getMessages];
            // fetch next page of results
        }
    }
}
 */
-(void)refreshTable {

    if(isMoreAvailabel)
    {
        [self getMessages];
    }
    else {
        
        [refreshControl endRefreshing];

    }
    
}


- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if (result.resultType == NSTextCheckingTypeLink) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
}


#pragma mark 
#pragma KeyBoard Notification Methods
- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect frame = messageDetailTableView.frame;
    frame.size.height -= keyboardFrameBeginRect.size.height;
    messageDetailTableView.frame = frame;
}
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    
    messageDetailTableView.frame = originalPostion;
}


#pragma mark -
#pragma mark TextView Delegate Methods
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

@end
