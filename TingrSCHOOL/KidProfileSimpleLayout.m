//
//  KidProfileSimpleLayout.m
//  KidsLink
//
//  Created by Dale McIntyre on 4/13/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "KidProfileSimpleLayout.h"

@implementation KidProfileSimpleLayout
{
    
}

@synthesize layout_label;
@synthesize layout_value;
@synthesize is_visible_to_friends;
@synthesize lblLayoutValue;

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
   lblLayoutValue = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 200, 30)];
    lblLayoutValue.text = layout_value;

    lblLayoutValue.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    [lblLayoutValue setTextAlignment:NSTextAlignmentLeft];
    lblLayoutValue.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [self addSubview:lblLayoutValue];
    
    //is_visible_to_friends = TRUE;
  /*  if (is_visible_to_friends == TRUE)
    {
        UIImageView *imgVisibleToFriends = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lblVisibleToFriends.png"]];
        imgVisibleToFriends.frame = CGRectMake(180,27,77.5,13.5);
        [self addSubview:imgVisibleToFriends];
    }
    */
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
