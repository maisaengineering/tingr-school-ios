//
//  EventsView.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) UITableView *streamTableView;

-(void)refreshData:(NSArray *)detailsArray;
@end
