//
//  KidProfileSimpleLayout.h
//  KidsLink
//
//  Created by Dale McIntyre on 4/13/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KidProfileSimpleLayout : UIView
{
    
}

@property (nonatomic) NSString *layout_label;
@property (nonatomic) NSString *layout_value;
@property (nonatomic) BOOL is_visible_to_friends;
@property (nonatomic) UILabel *lblLayoutValue;

@end
