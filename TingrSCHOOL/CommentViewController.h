//
//  CommentViewController.h
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 16/04/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StreamDisplayView;
@interface CommentViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate>
{
    BOOL isvisible;
    UILabel *visible;
    UIImageView *friendsImageView;
    NSString *reqName;
}
@property (strong, nonatomic) NSMutableDictionary *selectedStoryDetails;
@property (nonatomic, strong) StreamDisplayView *streamView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (strong, nonatomic) UIButton *btnPost;

// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;

-(IBAction)commentButtonTapped:(id)sender;

@end
