//
//  MessageDetailViewController.h
//  Tingr
//
//  Created by Maisa Pride on 1/21/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,NIAttributedLabelDelegate>


@property (nonatomic, strong)  UITableView *messageDetailTableView;
@property (nonatomic, strong) NSMutableDictionary *messagesData;
@property (nonatomic, strong) NSMutableDictionary *messageDictFromLastPage;
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UITextView *txt_comment;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end
