//
//  HeartersViewController.m
//  KidsLink
//
//  Created by Maisa Solutions on 1/23/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import "HeartersViewController.h"
#import "StringConstants.h"
#import "UIImageView+AFNetworking.h"
@interface HeartersViewController ()
{
    int numberOfTrails;
}
@end

@implementation HeartersViewController
@synthesize selectedStoryDetails;
@synthesize sharedModel;
@synthesize heartersList;
@synthesize heartersTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Hearters";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(69/255.f) green:(199/255.f) blue:(242/255.f) alpha:1];
    
    

    
    photoUtils = [ProfilePhotoUtils alloc];
    heartersList = [[NSMutableArray alloc]init];
    
    sharedModel = [ModelManager sharedModel];
    // init table view
    heartersTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    
    
    // heartersTableView.backgroundColor = [UIColor cyanColor];
    
    // add to canvas
    [self.view addSubview:heartersTableView];
    numberOfTrails = 0;
    NSString *kl_id = [NSString stringWithFormat:@"%@",[selectedStoryDetails objectForKey:@"kl_id"]];
    [self callHeartersListAPIWithKL_ID:kl_id];
    
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
    
    
}


-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)bakButtonTapped:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)callHeartersListAPIWithKL_ID:(NSString *)kl_id
{
    heartersTableView.delegate   = self;
    heartersTableView.dataSource = self;
    
    //this sets the line style for IOS 7 but checks for support of this property before applying in case previos IOS
    if ([heartersTableView respondsToSelector:@selector(setSeparatorStyle:)]) {
        [heartersTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    heartersTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString* postCommand = @"hearters";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": postCommand,
                               };
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,kl_id];
    
    DebugLog(@"heart postdata %@",postData);
    
    //DebugLog(@"URL:%@",urlAsString);
    //DebugLog(@"postData:%@",postData);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             heartersList = [[responseObject objectForKey:@"body"] objectForKey:@"hearters"];
             [heartersTableView setDelegate:self];
             [heartersTableView setDataSource:self];
             [heartersTableView reloadData];
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
             
             if(numberOfTrails <= 100)
             {
                 numberOfTrails ++;
                 
                 [self callHeartersListAPIWithKL_ID:kl_id];
                 
                 return ;
             }
         }
         
         DebugLog(@"hearters failure");
         DebugLog(@"error:%@",error.description);
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while calling hearters"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
         
     }];
    
    [operation start];
}


#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [heartersList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}


// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"HeartersCell";
    UILabel *hearterLabel;
    UIImageView *parentThumb;
    UILabel *firstInitialLabel;
    UILabel *secondInitialLabel;
    // Similar to UITableViewCell, but
    cell = [heartersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //(UITableViewCell *)[heartersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        hearterLabel = [[UILabel alloc] initWithFrame:CGRectMake(79,17.5,Devicewidth-79-10,28)];
        [hearterLabel setBackgroundColor:[UIColor clearColor]];
        [hearterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
        [hearterLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [hearterLabel setTextAlignment:NSTextAlignmentLeft];
        hearterLabel.tag= 110;
        [cell.contentView addSubview:hearterLabel];
        
        parentThumb = [[UIImageView alloc]initWithFrame:CGRectMake(15,10, 44, 44)];
        parentThumb.tag = 220;
        [cell.contentView addSubview:parentThumb];
        
        firstInitialLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+4, 10+1, 24, 44)];
        //firstInitialLabel.backgroundColor =  [UIColor redColor];
        firstInitialLabel.textAlignment = NSTextAlignmentRight;
        firstInitialLabel.tag = 111;
        
        
        firstInitialLabel.font =[UIFont fontWithName:@"Archer-Bold" size:22];
        firstInitialLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        firstInitialLabel.hidden = YES;
        [cell.contentView addSubview:firstInitialLabel];
        
        secondInitialLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 10+1, 20, 44)];
        //secondInitialLabel.backgroundColor =  [UIColor blueColor];
        secondInitialLabel.textAlignment = NSTextAlignmentLeft;
        secondInitialLabel.tag= 112;
        secondInitialLabel.font =[UIFont fontWithName:@"Archer-Light" size:22];
        secondInitialLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        secondInitialLabel.hidden = YES;
        [cell.contentView addSubview:secondInitialLabel];
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }else{
        
        hearterLabel = (UILabel *)[cell.contentView viewWithTag:110];
        parentThumb = (UIImageView *)[cell.contentView viewWithTag:220];
        firstInitialLabel =  (UILabel *)[cell.contentView viewWithTag:111];
        secondInitialLabel =  (UILabel *)[cell.contentView viewWithTag:112];
        
    }
    // Just want to test, so I hardcode the data
    
    
    [hearterLabel setText:[NSString stringWithFormat:@"%@ %@",[[heartersList objectAtIndex:indexPath.row] objectForKey:@"fname"],[[[heartersList objectAtIndex:indexPath.row] objectForKey:@"lname"] substringToIndex:1]]];
    
    
    
    NSString *url = [[heartersList objectAtIndex:indexPath.row] objectForKey:@"photograph_url"];
    
#pragma mark- Profile Image pics
#pragma mark-
    UIImageView *profileImage = parentThumb;
    
    __weak UIImageView *weakSelf = profileImage;
    if(url != (id)[NSNull null] && url.length > 0)
    {
        firstInitialLabel.hidden = YES;
        secondInitialLabel.hidden= YES;
        cell.tag = indexPath.row;
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"default_icon_3.png"] scaledToSize:CGSizeMake(43,43)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(43, 43)] withRadious:0];
             
         }
                                     failure:nil];
    }
    else
    {
        parentThumb.image = [UIImage imageNamed:@"EmptyProfileParent_hearters.png"];
        firstInitialLabel.hidden = NO;
        secondInitialLabel.hidden=NO;
        NSString *parentFnameInitial = [[[[heartersList objectAtIndex:indexPath.row] objectForKey:@"fname"] substringToIndex:1] uppercaseString];
        firstInitialLabel.text = [[parentFnameInitial substringToIndex:1] uppercaseString];
        NSString *parentLnameInitial = [[[[heartersList objectAtIndex:indexPath.row] objectForKey:@"lname"] substringToIndex:1] uppercaseString];
        secondInitialLabel.text = [[parentLnameInitial substringToIndex:1] uppercaseString];
        //[parentThumb addSubview:[photoUtils GrabInitials:43 :parentFnameInitial :parentLnameInitial]];
        
    }
    
    
    return cell;
}

#pragma mark- TO Avoid the Default Separator inset
#pragma mark- UITableView separator inset 0 not working
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(void)viewDidLayoutSubviews
{
    if ([heartersTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [heartersTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([heartersTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [heartersTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
*/
//Setup your cell margins:
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
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
    if ([self.heartersTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.heartersTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.heartersTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.heartersTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected row:%@", [heartersList objectAtIndex:indexPath.row]);
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
