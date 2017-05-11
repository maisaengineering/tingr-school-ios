//
//  ParentLayout.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/20/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KidProfileView;
@interface ParentLayout : UIView<MBProgressHUDDelegate>

@property (nonatomic) NSDictionary *contactDetails;
@property (nonatomic) NSString *layout_label;
@property (nonatomic) NSString *layout_value;
@property (nonatomic) UILabel *lblLayoutValue;

@property (nonatomic, retain) KidProfileView *parentView;


@end
