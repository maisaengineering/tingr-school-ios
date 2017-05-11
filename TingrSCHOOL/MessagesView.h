//
//  MessagesView.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/10/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessagesViewDelegate <NSObject>
- (void)messageTapped:(NSDictionary *)detailsDict;
@end
@interface MessagesView : UIView<UITableViewDataSource,UITableViewDelegate,NIAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) UITableView *streamTableView;
@property (nonatomic, weak) id<MessagesViewDelegate> delegate;

-(void)refreshData:(NSArray *)detailsArray;

@end
