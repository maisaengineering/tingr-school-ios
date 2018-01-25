
//
//  SettingsMenuViewController.m
//  Msocl_iOS
//
//  Created by Maisa Solutions on 4/13/15.
//  Copyright (c) 2015 Maisa Solutions. All rights reserved.
//

#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "ModelManager.h"
//#import "MainStreamsViewController.h"
#import "ProfilePhotoUtils.h"
#import "SettingsViewController.h"
#import "MyScheduleViewController.h"
#import "MyClassViewController.h"
#import "UserProfileViewController.h"
@implementation MenuViewController
{
    ModelManager *sharedModel;
    ProfilePhotoUtils *photoUtils;
    
}
@synthesize selectedIndex;
#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    sharedModel = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    
    if ( IDIOM == IPAD ) {

        CGRect frame = self.tableView.frame;
        frame.size = CGSizeMake(350, Deviceheight);
        self.tableView.frame = frame;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView)
                                                 name:@"UPDATE_MENU"
                                               object:nil];

    
    
    selectedIndex = 2;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
        return 105;
    else return 44;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftTopCell"];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
        __weak UIImageView *weakSelf = profileImage;
        
        for(UIView *view in [profileImage subviews])
            [view removeFromSuperview];
        NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
        if( [sharedModel.userProfile.fname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
        if( [sharedModel.userProfile.lname length] >0)
            [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];

        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                               attributes:nil];
        NSRange range;
        
        if(parentFnameInitial.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x6fa8dc),NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:20]}
                                    range:range];
        }
        if(parentFnameInitial.length > 1)
        {
            range.location = 1;
            range.length = 1;
            [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x6fa8dc),NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:20]}
                                    range:range];
        }
        
        
        //add initials
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        initial.attributedText = attributedText;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];
        
        CGRect frame = profileImage.frame;
        frame.origin.x = (tableView.frame.size.width - frame.size.width)/2.0;
        profileImage.frame = frame;
        
        [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.photograph]] placeholderImage:[UIImage imageNamed:@"EmptyProfile.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(35, 35)] withRadious:0];
             [initial removeFromSuperview];
             
         }failure:nil];
        if(sharedModel.userProfile.fname.length >0 || sharedModel.userProfile.lname.length > 0)
            [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
        
        [(UILabel *)[cell viewWithTag:2] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
        [(UILabel *)[cell viewWithTag:2] setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        
        UILabel *emailLabel = (UILabel *)[cell viewWithTag:3];
        emailLabel.text = sharedModel.userProfile.email;
        [emailLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];

        UIButton *editButton = (UIButton *)[cell viewWithTag:4];
        [editButton addTarget:self action:@selector(editTapped) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        
        frame = editButton.frame;
        frame.origin.x = tableView.frame.size.width - 10 - frame.size.width;
        editButton.frame = frame;
        
        frame = emailLabel.frame;
        frame.origin.x = (tableView.frame.size.width - frame.size.width)/2.0;;
        emailLabel.frame = frame;

        frame = nameLabel.frame;
        frame.origin.x = (tableView.frame.size.width - frame.size.width)/2.0;;
        nameLabel.frame = frame;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 104.5, tableView.frame.size.width, 0.5)];
        [label setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:label];
        
        if ( IDIOM == IPAD ) {

        
            [(UILabel *)[cell viewWithTag:2] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
            [emailLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
            [editButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
        }
        
        return cell;
        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    
    if ( IDIOM == IPAD ) {
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];

    }
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];

    cell.textLabel.textColor = UIColorFromRGB(0x6fa8dc);
    cell.backgroundColor = [UIColor clearColor];

    
    
    switch (indexPath.row)
    {
        case 2:
        {
            cell.textLabel.text = @"My Schedule";
            if(selectedIndex == 2) {
                
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = UIColorFromRGB(0x6fa8dc);
                cell.imageView.image = [UIImage imageNamed:@"menu_schedule_selected.png"];

            }
            else {
                
                cell.imageView.image = [UIImage imageNamed:@"menu_schedule.png"];

            }
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"My Class";
            if(selectedIndex == 1) {
                
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = UIColorFromRGB(0x6fa8dc);
                cell.imageView.image = [UIImage imageNamed:@"menu_myclass_selected.png"];

            }
            else  {
                
                cell.imageView.image = [UIImage imageNamed:@"menu_myclass.png"];

            }
            
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = @"Settings";
            cell.imageView.image = [UIImage imageNamed:@"menu_settings.png"];

        }

            break;

            
    }
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        switch (indexPath.row)
        {
                
            case 2:
            {
                selectedIndex = (int)indexPath.row;
                [tableView reloadData];

                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyScheduleViewController"];

                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
            }
                break;
            case 1:
            {
                selectedIndex = (int)indexPath.row;
                [tableView reloadData];

                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyClassViewController"];

                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
            }
                break;
                
                
            case 3:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                         bundle: nil];
                
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                
                [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
            }            break;
                
                break;
                
             
                
                
            default:
                break;
        }
    
    
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
     
     
}
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

-(void)editTapped {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UserProfileViewController *destViewController = (UserProfileViewController*)[mainStoryboard
                                                                               instantiateViewControllerWithIdentifier: @"UserProfileViewController"];
    
    [[SlideNavigationController sharedInstance] pushViewController:destViewController animated:YES];
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
}
-(void)updateView {
    
    [self.tableView reloadData];
}
@end
