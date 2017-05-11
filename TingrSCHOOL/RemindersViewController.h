//
//  RemindersViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "ViewController.h"

@interface RemindersViewController : ViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *remindersTableView;
@property (nonatomic, strong) NSMutableArray *remindersListArray;
@property (nonatomic, strong) NSString *kid_klid;

@end
