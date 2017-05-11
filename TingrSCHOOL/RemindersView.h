//
//  RemindersView.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindersView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *storiesDict;
@property (nonatomic, strong) UITableView *streamTableView;

-(void)refreshData:(NSDictionary *)detailsDict;

@end
