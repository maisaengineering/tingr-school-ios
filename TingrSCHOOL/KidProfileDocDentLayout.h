//
//  KidProfileDocDentLayout.h
//  KidsLink
//
//  Created by Maisa Solutions on 12/3/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class KidProfileView;
@interface KidProfileDocDentLayout : UIView<MBProgressHUDDelegate>

@property (nonatomic) NSDictionary *contactDetails;
@property (nonatomic) NSString *layout_label;
@property (nonatomic) NSString *layout_value;
@property (nonatomic) UILabel *lblLayoutValue;

@property (nonatomic, retain) KidProfileView *parentView;
@end
