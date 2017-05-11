//
//  FormsDocsViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "ViewController.h"

@interface FormsDocsViewController : ViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *formsTableView;
@property (nonatomic, strong) NSString *kid_klid;
@property (nonatomic, strong) NSMutableDictionary *formsList;


@end
