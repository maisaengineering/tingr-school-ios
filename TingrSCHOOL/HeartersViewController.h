//
//  HeartersViewController.h
//  KidsLink
//
//  Created by Maisa Solutions on 1/23/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelManager.h"
#import "ProfilePhotoUtils.h"


@interface HeartersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *heartersTableView;
    ProfilePhotoUtils *photoUtils;
}
@property (nonatomic, strong) NSMutableDictionary *selectedStoryDetails;
@property (nonatomic, strong) ModelManager *sharedModel;
@property (nonatomic, strong) NSMutableArray *heartersList;
@property (nonatomic, strong) UITableView *heartersTableView;
@end
