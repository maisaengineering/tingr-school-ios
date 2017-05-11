//
//  NotesListViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/13/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "ViewController.h"

@interface NotesListViewController : ViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *notesTableView;
@property (nonatomic, strong) NSString *kid_klid;
@property (nonatomic, strong) NSMutableArray *notesListArray;

@end
