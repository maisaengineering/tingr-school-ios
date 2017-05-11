//
//  StreamDisplayView.h
//  KidsLink
//
//  Created by Maisa Solutions on 5/2/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"
//#import "AboutFriendSharing.h"
//#import "FriendsContactsViewController.h"
#import "SharingCheck.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define REFRESH_HEADER_HEIGHT 44
#define TAG_SIZE 54
#define SEPARATOR_HEIGHT 14.5

@protocol StreamDisplayViewDelegate <NSObject>
- (void)commentClick:(int)index;
- (void)readArticleClicked:(NSString *)index;
- (void)tableScrolled:(float)yLocation;
- (void)streamCountReturned:(int)total;
-(void)showVerifiedPhone;

- (void)addHeartClick:(int)index withCommand:(NSString *)commandName;
- (void)heartersClick:(int)index;

@optional
-(void)cameraTappedForParent;

@end


@interface StreamDisplayView : UIView<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,ASMediasFocusDelegate,UIActionSheetDelegate,NIAttributedLabelDelegate,SharingCheckDelegate,UIDocumentInteractionControllerDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL isMoreAvailabel;
    BOOL isPrevious;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
   // StoryRetreivalManager *_manager;
   // UntagManager *unTag_manager;
    
    NSNumber *feedCount;
    NSNumber *postCount;
    
    UIView *refreshHeaderView;
    UIImageView *refreshArrow;
    UILabel *refreshLabel;
    BOOL bProcessing;
    BOOL isDragging;
    
    NSMutableArray *heightArray;
    
    UITableViewController *tableController;
    int deleteIndex;
    NSDictionary *deleteDict;
    MFMailComposeViewController *mailComposer;

    BOOL isFullScreen;
}
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;

@property (nonatomic, strong) NSString *profileID;
@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, strong) UITableView *streamTableView;
@property (nonatomic, weak) id<StreamDisplayViewDelegate> delegate;
@property (nonatomic, assign) int commemtIndex;
@property (nonatomic, assign) BOOL isCommented;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isMainView;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *headActivityIndicator;
@property (nonatomic, assign) BOOL isFromFriends;
@property (nonatomic, assign) BOOL isParentDashBoard;
//@property (nonatomic, strong) AboutFriendSharing *aboutPopup;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *etag;
@property (nonatomic, assign) int editIndex;
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, assign) BOOL isDeletingProcessed;

@property (nonatomic, strong) NSMutableArray *webViewsArray;
// To avoid the memory leaks declare a global alert
@property (nonatomic, strong) UIAlertView *globalAlert;
//@property (nonatomic, assign) BOOL isHeartSelected;

-(void)callStoresApi:(NSString *)step;
-(void)resetData;
-(void)clearCommentDetails;
-(void)checkToHideEmptyMessage;
@end
