//
//  KidProfileDocDentLayout.m
//  KidsLink
//
//  Created by Maisa Solutions on 12/3/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "KidProfileDocDentLayout.h"
#import "KidProfileView.h"

@implementation KidProfileDocDentLayout

@synthesize layout_label;
@synthesize layout_value;
@synthesize lblLayoutValue;
@synthesize contactDetails;
@synthesize parentView;

- (void)baseInit
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    //horizontal line
    UIImageView *hrImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hr_profile.png"]];
    hrImage.frame = CGRectMake(20,0,screenWidth - 80,1);
    [self addSubview:hrImage];
    
    //label
    UILabel *lblLayoutName = [[UILabel alloc] initWithFrame: CGRectMake(20, 5, 200, 30)];
    lblLayoutName.text = layout_label;
    lblLayoutName.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:17];
    [lblLayoutName setTextAlignment:NSTextAlignmentLeft];
    lblLayoutName.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [self addSubview:lblLayoutName];
    
    
    //value
    //layout_value = @"this is some text1 this is some text2 this is some text3 this is some text4 this is some text5";
    
    CGSize maximumSize = CGSizeMake(screenWidth - 80, 9999);
    NSDictionary *attribs = @{
                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17]
                              };
    int yPosition = 30;
    if ([contactDetails valueForKey:@"name"] != (id)[NSNull null] && [[contactDetails valueForKey:@"name"] length] > 0)
    {
        NSString *doctorName = [NSString stringWithFormat:@"%@",[contactDetails valueForKey:@"name"]];
        NSString *docName  = [NSString stringWithFormat:@"%@",doctorName.capitalizedString];
        
        CGSize myStringSize = [docName boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        UILabel *lblName = [[UILabel alloc] initWithFrame: CGRectMake(20, yPosition, screenWidth - 80, myStringSize.height)];
        lblName.text = docName;
        lblName.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        lblName.numberOfLines = 0;
        lblName.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        [self addSubview:lblName];
        
        yPosition += myStringSize.height;
        
    }
    if ([contactDetails valueForKey:@"email"] != (id)[NSNull null] && [[contactDetails valueForKey:@"email"] length] > 0)
    {
        NSString *email = [NSString stringWithFormat:@"%@",[contactDetails valueForKey:@"email"]];
        CGSize myStringSize = [email boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        /*
         UILabel *lblEmail = [[UILabel alloc] initWithFrame: CGRectMake(20, yPosition, screenWidth - 80, myStringSize.height)];
         lblEmail.text = email;
         lblEmail.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
         [lblEmail setTextAlignment:NSTextAlignmentLeft];
         lblEmail.numberOfLines = 0;
         lblEmail.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
         [self addSubview:lblEmail];
         */
        
        UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [emailButton setTitle:email forState:UIControlStateNormal];
        emailButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        [emailButton setTitleColor:[UIColor colorWithRed:(69/255.f) green:(199/255.f) blue:(242/255.f) alpha:1] forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(emailTapped) forControlEvents:UIControlEventTouchUpInside];
        [emailButton setFrame:CGRectMake(20, yPosition, screenWidth - 80, myStringSize.height)];
        emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        emailButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self addSubview:emailButton];
        
        yPosition += myStringSize.height;
    }
    if ([contactDetails valueForKey:@"phone_no"] != (id)[NSNull null] && [[contactDetails valueForKey:@"phone_no"] length] > 0)
    {
        NSString *email = [NSString stringWithFormat:@"%@",[contactDetails valueForKey:@"phone_no"]];
        CGSize myStringSize = [email boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        /*
         UILabel *lblEmail = [[UILabel alloc] initWithFrame: CGRectMake(20, yPosition, screenWidth - 80, myStringSize.height)];
         lblEmail.text = email;
         lblEmail.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
         [lblEmail setTextAlignment:NSTextAlignmentLeft];
         lblEmail.numberOfLines = 0;
         lblEmail.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
         [self addSubview:lblEmail];
         */
        UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [emailButton setTitle:email forState:UIControlStateNormal];
        emailButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        [emailButton setTitleColor:[UIColor colorWithRed:(69/255.f) green:(199/255.f) blue:(242/255.f) alpha:1] forState:UIControlStateNormal];
        [emailButton addTarget:self action:@selector(smsTapped) forControlEvents:UIControlEventTouchUpInside];
        [emailButton setFrame:CGRectMake(20, yPosition, screenWidth - 80, myStringSize.height)];
        emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        emailButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self addSubview:emailButton];
        
        
    }
    
    
    self.frame = CGRectMake (self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAX(yPosition+10, 40));
    
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self baseInit];
    }
    return self;
}

#pragma mark Actions
-(void)emailTapped
{
    parentView.HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:parentView.HUD];
    
    parentView.HUD.delegate = self;
    [parentView.HUD hide:NO];
    [parentView.HUD show:YES];
    
    //[self performSelectorOnMainThread:@selector(showMail) withObject:nil waitUntilDone:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMail];
    });
}
- (void)showMail
{
    [parentView showMailComposerWithEmailID:[self.contactDetails objectForKey:@"email"]];
}
-(void)smsTapped
{
    [parentView tappedOnPhoneNumber:[self.contactDetails objectForKey:@"phone_no"]];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
