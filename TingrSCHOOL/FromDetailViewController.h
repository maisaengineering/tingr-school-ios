//
//  FromDetailViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/14/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FromDetailViewController : UIViewController<UIActionSheetDelegate>

@property (nonatomic, strong) NSString *kid_klid;
@property (nonatomic, strong) NSDictionary *detailDict;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
