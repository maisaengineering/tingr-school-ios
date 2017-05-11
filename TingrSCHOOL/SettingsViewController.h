//
//  SettingsViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appdelegate;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
