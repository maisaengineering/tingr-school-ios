//
//  NotesListViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/13/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "NotesListViewController.h"
#import "EditNotesViewController.h"
@interface NotesListViewController ()
{
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    UIView *emptyContentMsgView;
}
@end

@implementation NotesListViewController
@synthesize kid_klid;
@synthesize notesTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Notes";
    
    sharedModel = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    
    self.notesTableView.tableFooterView = [[UIView alloc] init];
    
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
    
    
    UIImageView *imageView1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
    [imageView1 setTintColor:[UIColor redColor]];
    
    
    UIView *view1=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView1.frame.size.width+space, imageView1.frame.size.height)];
    
    view1.bounds=CGRectMake(view1.bounds.origin.x-10, view1.bounds.origin.y-1, view1.bounds.size.width, view1.bounds.size.height);
    [view1 addSubview:imageView1];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:view1.frame];
    [button1 addTarget:self action:@selector(plusButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;

    
    CGRect frame = notesTableView.frame;
    frame.size.width = Devicewidth;
    frame.size.height = Deviceheight;
    notesTableView.frame = frame;
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self callNotesAPI];
    [super viewWillAppear:YES];
}
-(void)plusButtonTapped {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    EditNotesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"EditNotesViewController"];
    vc.kid_klid = kid_klid;
    [self.navigationController pushViewController:vc animated:YES];

}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)callNotesAPI {
    
    
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"list";
    NSDictionary *body = @{
                           @"organization_id":[sharedInstance.selecteRoom objectForKey:@"organization_id"],
                           @"kid_klid":kid_klid
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@notes",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf reciedNotes:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
    } failure:^(NSDictionary *json) {
        
        [Spinner showIndicator:NO];
    }];
    

}

-(void)reciedNotes:(NSDictionary *)list {
    
    [Spinner showIndicator:NO];
    
    self.notesListArray = [list objectForKey:@"notes"];
    [self.notesTableView reloadData];
    [self checkToHideEmptyMessage];
}

-(void)showEmptyContentMessageView {
    
    
    if(emptyContentMsgView == nil)
    {
        emptyContentMsgView = [[UIView alloc] initWithFrame:self.notesTableView.bounds];
        emptyContentMsgView.backgroundColor = [UIColor whiteColor];
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        NSString *message = @"start taking handy student notes today…notes are private to kid/school—never shared with any parent. only your co-teacher can see your notes.";
        
        UIButton *plustButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [plustButton addTarget:self action:@selector(plusButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [plustButton setTag:1];
        [plustButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [emptyContentMsgView addSubview:plustButton];
        
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
        
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.attributedText = attributedString;
        [emptyContentMsgView addSubview:messageLabel];
        
        
        
        
        
        CGSize  expectedLabelSize = [message boundingRectWithSize:CGSizeMake(300, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName: [UIFont italicSystemFontOfSize:14]} context:nil].size;
        
        float height = expectedLabelSize.height;
        
        float yCoOrdinate =   (emptyContentMsgView.frame.size.height - height-50)/2.0 ;
        
        messageLabel.frame = CGRectMake(10, yCoOrdinate, 300, expectedLabelSize.height +5);
        [plustButton setFrame:CGRectMake((Devicewidth-45)/2.0, messageLabel.frame.origin.y+5+messageLabel.frame.size.height, 45, 45)];
        
    }
    
    [self.view addSubview:emptyContentMsgView];
    emptyContentMsgView.hidden = NO;
    
}
-(void)checkToHideEmptyMessage {
    
    if(self.notesListArray.count == 0)
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        [emptyContentMsgView removeFromSuperview];
    }
}
#pragma mark -
#pragma mark TableView
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notesListArray.count;
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
    
    NSDictionary *notesDict = self.notesListArray[indexPath.row];
    NSArray *array = [[notesDict valueForKey: @"description"] componentsSeparatedByString: @"\n"];
    
    NSString *titleStr;
    
    NSMutableString *detailString = [[NSMutableString alloc] init];
    
    if([array count] > 0)
        titleStr = [[[notesDict valueForKey: @"description"] componentsSeparatedByString: @"\n"] objectAtIndex:0];
    else
        titleStr = [notesDict valueForKey: @"description"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
    NSDate *startdate = [dateFormatter dateFromString:[notesDict objectForKey:@"created_at"]];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    [detailString appendString:[dateFormatter stringFromDate:startdate]];
    
    if([array count] > 1)
    {
        [detailString appendString:[NSString stringWithFormat:@" %@",array[1]]];
    }
    
    
    cell.textLabel.text = titleStr;
    cell.detailTextLabel.text = detailString;
    cell.textLabel.textColor = [UIColor colorWithRed:113/255.0f green:113/255.0f blue:113/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    
    if ( IDIOM == IPAD ) {
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *notesDict = self.notesListArray[indexPath.row];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    EditNotesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"EditNotesViewController"];
    vc.kidDict = notesDict;
    [self.navigationController pushViewController:vc animated:YES];

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
