//
//  AddPostViewController.h
//  KidsLink
//
//  Created by Maisa Solutions on 4/17/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MilestoneView.h"
@class StreamDisplayView;
@interface AddPostViewController : UIViewController<MilestoneDelegate>
{
    UIScrollView *scrollView;
}
@property (nonatomic, strong) NSString *profileId;
@property (nonatomic,assign)int index;
@property (nonatomic, assign) BOOL isSharing;
@property (nonatomic, assign) BOOL isFromFirstAddedChild;
@property (nonatomic ,strong) NSDictionary *detailsDictionary;
@property (nonatomic, strong) StreamDisplayView *steamDisplayView;

@property (nonatomic, retain) UIImage *attachedImage;
@property (nonatomic, retain) NSString *attachedMessage;

@property (nonatomic, strong) UIImage *momentImage;
@property (nonatomic , strong) NSDictionary *childDetails;
@property (nonatomic, assign) BOOL isFromAddedChild;
@property (nonatomic, assign) BOOL isTextOnly;

-(void)showInstagramMessage;
-(IBAction)postClicked:(id)sender;


@end
