//
//  FormsDocsViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "FormsDocsViewController.h"
#import "FromDetailViewController.h"
@interface FormsDocsViewController ()
{
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    UILabel *emptyContentLabel;
}
@end

@implementation FormsDocsViewController
@synthesize formsTableView;
@synthesize formsList;
@synthesize kid_klid;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharedModel = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    self.title = @"Forms & Documents";

    self.formsTableView.tableFooterView = [[UIView alloc] init];
    
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect frame = formsTableView.frame;
    frame.size.width = Devicewidth;
    frame.size.height = Deviceheight - appDelegate.bottomSafeAreaInset;
    formsTableView.frame = frame;

    

    [self callFormsAPI];
    
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)callFormsAPI {
    
    
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"forms_and_documents";
    NSDictionary *body = @{
                           @"session_id":[[sharedInstance selecteRoom] objectForKey:@"session_id"],
                           @"season_id":[[sharedInstance selecteRoom] objectForKey:@"season_id"],
                           @"kid_klid":kid_klid
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
        
        [weakSelf recievedFroms:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
    } failure:^(NSDictionary *json) {
        
        [weakSelf failedToRecievFroms];
        
    }];
    
    
}

-(void)failedToRecievFroms {
    
    [self checkToHideEmptyMessage];
    [Spinner showIndicator:NO];
}
-(void)recievedFroms:(NSDictionary *)list {
    
    [Spinner showIndicator:NO];
    
    self.formsList = [list mutableCopy];
    [self.formsTableView reloadData];
    [self checkToHideEmptyMessage];
}

-(void)showEmptyContentMessageView {
    
    
    if(emptyContentLabel == nil)
    {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        NSString *message = @"No Forms or Documents.";
        
        
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName:[UIFont italicSystemFontOfSize:17]}];
        
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.attributedText = attributedString;
        messageLabel.frame = self.view.bounds;
        
        emptyContentLabel = messageLabel;
        
    }
    
    [self.view addSubview:emptyContentLabel];
    emptyContentLabel.hidden = NO;
    
}
-(void)checkToHideEmptyMessage {
    
    NSArray *formsArray = [self.formsList objectForKey:@"forms"];
    NSArray *docArray = [self.formsList objectForKey:@"documents"];
    if(formsArray.count == 0 && docArray.count == 0)
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.formsList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        NSArray *formsArray = [self.formsList objectForKey:@"forms"];
        return formsArray.count;
        
    }
    else if(section == 1) {
        
        NSArray *docArray = [self.formsList objectForKey:@"documents"];
        return docArray.count;
    }

    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString *reuseIdentifier = @"RemindersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
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
    
    NSDictionary *notesDict;
    if(indexPath.section == 0)
    {
        NSArray *formsArray = [self.formsList objectForKey:@"forms"];
        notesDict = formsArray[indexPath.row];
    }
    else if(indexPath.section == 1)
    {
        NSArray *docArray = [self.formsList objectForKey:@"documents"];
        notesDict = docArray[indexPath.row];
    }
    
    NSString *titleStr = [notesDict objectForKey:@"name"];
    
    cell.textLabel.text = titleStr;
    if ( IDIOM == IPAD ) {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    }
    
    cell.textLabel.textColor = UIColorFromRGB(0x6fa8dc);
    
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *notesDict;
    if(indexPath.section == 0)
    {
        NSArray *formsArray = [self.formsList objectForKey:@"forms"];
        notesDict = [formsArray[indexPath.row] mutableCopy];
        [notesDict setObject:@"form" forKey:@"type"];
        
    }
    else if(indexPath.section == 1)
    {
        NSArray *docArray = [self.formsList objectForKey:@"documents"];
        notesDict = [docArray[indexPath.row] mutableCopy];
        [notesDict setObject:@"document" forKey:@"type"];
    }
    [notesDict setObject:self.kid_klid forKey:@"kid_klid"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    FromDetailViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FromDetailViewController"];
    vc.detailDict = notesDict;
    [self.navigationController pushViewController:vc animated:YES];

    
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
