//
//  RemindersViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "RemindersViewController.h"

@interface RemindersViewController ()
{
    
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    UILabel *emptyContentLabel;
}
@end

@implementation RemindersViewController
@synthesize remindersListArray;
@synthesize remindersTableView;
@synthesize kid_klid;
- (void)viewDidLoad {
    
    sharedModel = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    self.title = @"Reminders";
    
    self.remindersTableView.tableFooterView = [[UIView alloc] init];
    
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
    

    
    CGRect frame = remindersTableView.frame;
    frame.size.width = Devicewidth;
    frame.size.height = Deviceheight;
    remindersTableView.frame = frame;
    
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self callRemindersAPI];
    [super viewWillAppear:YES];
}

-(void)callRemindersAPI {
    
    
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"list";
    NSDictionary *body = @{
                           @"teacher_klid":_userProfile.teacher_klid,
                           @"kid_klid":kid_klid
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@reminders",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf reciedReminders:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
    }];
    
    
}

-(void)reciedReminders:(NSDictionary *)list {
    
    [Spinner showIndicator:NO];
    
    self.remindersListArray = [[list objectForKey:@"reminders"] mutableCopy];
    [self.remindersTableView reloadData];
    [self checkToHideEmptyMessage];
}


-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)showEmptyContentMessageView {
    
    
    if(emptyContentLabel == nil)
    {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        NSString *message = @"no reminders for you.";
        
        
        
        
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
    
    if(self.remindersListArray.count == 0)
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        [emptyContentLabel removeFromSuperview];
    }
}

#pragma mark -
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.remindersListArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IDIOM == IPAD ) {
        
        return 50;
    }
    else  {
        
        return 44;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *reuseIdentifier = @"RemindersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:reuseIdentifier];
    }
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    NSDictionary *notesDict = self.remindersListArray[indexPath.row];
    
    NSString *titleStr = [notesDict objectForKey:@"text"];
    
    NSMutableString *detailString = [[NSMutableString alloc] init];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
    NSDate *startdate = [dateFormatter dateFromString:[notesDict objectForKey:@"created_at"]];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    [detailString appendString:[dateFormatter stringFromDate:startdate]];
    

    cell.textLabel.text = titleStr;
    cell.detailTextLabel.text = detailString;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    if([[notesDict objectForKey:@"read"] boolValue])
        cell.textLabel.textColor = [UIColor lightGrayColor];
    else
        cell.textLabel.textColor = UIColorFromRGB(0x6fa8dc);
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    
    if ( IDIOM == IPAD ) {
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSMutableDictionary *notesDict = [self.remindersListArray[indexPath.row] mutableCopy];
    [notesDict setObject:[NSNumber numberWithBool:YES] forKey:@"read"];
    [self.remindersListArray replaceObjectAtIndex:indexPath.row withObject:notesDict];
    [self.remindersTableView reloadData];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self callReadAPI:notesDict];
    UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"" message:[notesDict objectForKey:@"text"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [disableAlert show];

    
}

-(void)callReadAPI:(NSDictionary *)detailsDict {
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"read_reminder";
    NSDictionary *body = @{
                           @"reminder_klid":[detailsDict objectForKey:@"kl_id"],
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@reminders",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
    } failure:^(NSDictionary *json) {
        
    }];
    

    
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
