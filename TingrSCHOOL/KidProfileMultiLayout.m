//
//  KidProfileMultiLayout.m
//  KidsLink
//
//  Created by Dale McIntyre on 4/14/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "KidProfileMultiLayout.h"

@implementation KidProfileMultiLayout
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
    lblLayoutName.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14];
    [lblLayoutName setTextAlignment:NSTextAlignmentLeft];
    lblLayoutName.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [self addSubview:lblLayoutName];
    
    
    //value
    //layout_value = @"this is some text1 this is some text2 this is some text3 this is some text4 this is some text5";
    
  lblLayoutValue = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 200, 30)];
    lblLayoutValue.text = layout_value;
    lblLayoutValue.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    [lblLayoutValue setTextAlignment:NSTextAlignmentLeft];
    lblLayoutValue.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    lblLayoutValue.lineBreakMode = NSLineBreakByWordWrapping;
    lblLayoutValue.numberOfLines = 0;
    CGSize maximumSize = CGSizeMake(240, 9999);
    UIFont *myFont = lblLayoutValue.font;
    NSDictionary *attribs = @{
                              NSFontAttributeName: myFont
                              };

    ;
    CGSize myStringSize = [layout_value boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
    lblLayoutValue.frame = CGRectMake (lblLayoutValue.frame.origin.x, 30, myStringSize.width, myStringSize.height);
    
    [self addSubview:lblLayoutValue];
    
    self.frame = CGRectMake (self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 10 + lblLayoutValue.frame.size.height);
    
    //is_visible_to_friends = TRUE;
    if (is_visible_to_friends == TRUE)
    {
        UIImageView *imgVisibleToFriends = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lblVisibleToFriends.png"]];
        imgVisibleToFriends.frame = CGRectMake(180,27,77.5,13.5);
        [self addSubview:imgVisibleToFriends];
    }
    
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
