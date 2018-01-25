//
//  StreamDisplayView.m
//  KidsLink
//
//  Created by Maisa Solutions on 5/2/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StreamDisplayView.h"
#import "UIImageView+AFNetworking.h"
#import "ProfilePhotoUtils.h"
#import "ProfileKidsTOCV2ViewController.h"
#import "NameUtils.h"
#import "ProfileDateUtils.h"
#import "UIImageViewAligned.h"
#import "AddPostViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
//#import "FacebookShareController.h"
#import "Base64.h"
//#import "MGInstagram.h"
#import "StringConstants.h"
//#import "UntagManager.h"
#import "CommentsUtils.h"
//#import "NotificationUtils.h"
#import "TaggingUtils.h"
//#import "ProfileParentInviteViewController.h"

#import "VideoPlayer.h"
@implementation StreamDisplayView
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    UIView *fullScreenView;
    UIImageView *fullScreenImageview;
    SingletonClass *singletonObj;
    UIRefreshControl *refreshControl;
    ALAssetsLibrary* libraryFolder;
    UIView *dnView;
    NSMutableArray *optionArray;
    NSMutableDictionary *comment_details;
    NSMutableArray *colorsArray;
    UIView *emptyContentMsgView;
}

@synthesize storiesArray;
@synthesize streamTableView;
@synthesize delegate;
@synthesize profileID;
@synthesize isCommented,commemtIndex;
@synthesize footerLabel=_footerLabel;
@synthesize activityIndicator=_activityIndicator;
@synthesize headActivityIndicator;
@synthesize isFromFriends;
@synthesize isMainView;
//@synthesize aboutPopup;
@synthesize timeStamp;
@synthesize etag;

//for edit milestone
@synthesize editIndex;
@synthesize isEdited;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;
//@synthesize isHeartSelected;
@synthesize isDeletingProcessed;

@synthesize isParentDashBoard;
///////////TO avoid crash when webview is not loading even after the view controller is popped.//////////////
@synthesize webViewsArray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self baseInit];
    }
    return self;
}
-(void)resetData
{
    postCount = 0;
    feedCount = 0;
}
-(void)baseInit
{
    timeStamp = @"";
    etag = @"";
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    [self setBackgroundColor:[UIColor clearColor]];
    comment_details = [[NSMutableDictionary alloc]init];
    webViewsArray = [[NSMutableArray alloc]init];
    
    colorsArray = @[@0xC46D21,@0xBE1C2F,@0xFF3869,@0x4195FF,@0xA52BFF,@0x1E6587,@0x32C4FC,@0xFF2717,@0xFF601D,@0x82AF52].mutableCopy;
    //isMainView = TRUE; //is placed in the main stream and not a family or friend TOC
    
    singletonObj = [SingletonClass sharedInstance];
    sharedModel   = [ModelManager sharedModel];
    
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    
    //self.postedConfirmationDelegate =
    
    fullScreenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, Deviceheight)];
    fullScreenImageview = [[UIImageView alloc] initWithFrame:fullScreenView.bounds];
    [fullScreenView addSubview:fullScreenImageview];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnClose setImage:[UIImage imageNamed:@"btnKidProfileClose.png"] forState:UIControlStateNormal];
    btnClose.frame = CGRectMake(fullScreenView.frame.size.width - 40, 10, 35, 35);
    [fullScreenView addSubview:btnClose];

    storiesArray = [[NSMutableArray alloc] init];
    streamTableView = [[UITableView alloc] initWithFrame:self.bounds];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.tableFooterView = nil;
    streamTableView.tableHeaderView = nil;
    streamTableView.estimatedRowHeight = 0;
    streamTableView.estimatedSectionHeaderHeight = 0;
    streamTableView.estimatedSectionFooterHeight = 0;
    


    streamTableView.backgroundColor = [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    [streamTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarHit) name:kStatusBarTappedNotification object:nil];
    
    //    tableController = [[UITableViewController alloc] init];
    //    [tableController setTableView:streamTableView];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"streamArray"] != nil && !isFromFriends && profileID.length == 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"streamArray"];
        storiesArray = [[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject] mutableCopy];
    }
    
    [self addSubview:streamTableView];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [tableController setRefreshControl:refreshControl];
    [streamTableView addSubview:refreshControl];
    
    // 29=05-2014 changes
    /*
     UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     activityIndicatorView.center = CGPointMake(40, 22);
     activityIndicatorView.hidesWhenStopped = YES;
     self.headActivityIndicator = activityIndicatorView;
     */
    
    //    [refreshHeaderView addSubview:activityIndicatorView];
    //    [refreshHeaderView addSubview:refreshLabel];
    //    [refreshHeaderView addSubview:refreshArrow];
    //    [streamTableView addSubview:refreshHeaderView];
    
    
    //set them up for parse if they haven't already done it (in case they haven't re-logged-in yet)
    //TODO:Parse has been in long enough that this can be removed
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *hasRegisterKlid = [defaults objectForKey:@"HAS_REGISTERED_KLID"];
    
    if (hasRegisterKlid == nil)
    {
        //unregister user for any other channels
       // [NotificationUtils resetParseChannels];
    }
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(editPostCompleted:)
     name:@"EditPostCompleted"
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(postCompleted:)
     name:@"PostCompleted"
     object:nil];
    
}
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}
- (void)removeFromSuperview
{
    self.globalAlert = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
    
}
-(void)editPostCompleted:(NSNotification *)notification {
    
    NSDictionary *post = [notification object];
    
    self.isEdited = YES;
    [self.storiesArray replaceObjectAtIndex:self.editIndex withObject:post];
    [self.streamTableView reloadData];
    
}
-(void)postCompleted:(NSNotification *)notification {

    [self resetData];
    self.timeStamp = @"";
    self.etag = @"";
    bProcessing = NO;
    
    [self callStoresApi:@"next"];
    
    
    
}
-(void)handleRefresh:(id)sender
{
    //    UIRefreshControl *refresh = sender;
    //     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    if (bProcessing) return;
    // Released above the header
    [self resetData];
    timeStamp = @"";
    etag= @"";
    [self callStoresApi:@"next"];
    
}
- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    //    label.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    //    label.textAlignment = NSTextAlignmentCenter;
    //    label.text = @"Loading";
    //    self.footerLabel = label;
    //    [footerView addSubview:label];
    
    // 29=05-2014 changes
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = footerView.center
    ;
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    
    self.streamTableView.tableFooterView = footerView;
}

#pragma mark- Stories Api Call
#pragma mark-

-(void)callStoresApi:(NSString *)step
{
    
    if(bProcessing)
        return;
    if(!bProcessing)
    {
        bProcessing = YES;
        if([step isEqualToString:@"new"])
            self.isRefreshing = YES;
        else
            self.isRefreshing = NO;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:timeStamp forKeyPath:@"last_modified"];
        [dict setValue:postCount forKeyPath:@"post_count"];
        [dict setValue:feedCount forKeyPath:@"feed_count"];
        [dict setValue:etag forKey:@"etag"];
        [dict setValue:step forKeyPath:@"step"];
        [dict setObject:[NSNumber numberWithBool:TRUE] forKey:@"paginate"];
        
        
        //DM
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        NSString* postCommand = @"";
        if(isFromFriends)
        {
            [dict setValue:self.profileID  forKey:@"friend_id"];
            postCommand = @"friend_posts_all";
        }
        else
        {
            [dict setValue:self.profileID  forKey:@"profile_id"];
            
            if(self.profileID != nil && self.profileID.length >0)
                postCommand = @"kid_posts";
            else
            {
                NSString *orgId = [sharedInstance.selecteOrganisation objectForKey:@"id"];
               // postCommand = @"org_posts";
               // [dict setValue:orgId  forKey:@"organization_id"];
                 postCommand = @"all";
                

            }
        }
        
        //build an info object and convert to json
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token": _userProfile.auth_token,
                                   @"command": postCommand,
                                   @"body": dict};
        
        NSDictionary *userInfo = @{@"command":postCommand};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
       
        __weak StreamDisplayView *weakSelf = self;
        
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            NSArray *streamArray = [Factory stroriesFromJSON:[json objectForKey:@"response"]];
            [weakSelf receivedStories:streamArray];
            
        } failure:^(NSDictionary *json) {
            
            [weakSelf fetchinStoriesFailedWithError:nil];
        }];

        
    }
}

#pragma mark- StoryRetreivalManagerDelegate Methods
#pragma mark-
- (void)receivedStories:(NSArray *)completeRegistration
{
    if(isDeletingProcessed)
    {
        return;
    }

    if([timeStamp length] == 0)
    {
        [self.storiesArray removeAllObjects];
    }
    
    if([completeRegistration count] > 0)
    {
        NSDictionary *dict = [completeRegistration objectAtIndex:0];
        
        [self.delegate streamCountReturned:[[dict objectForKey:@"post_count"] intValue]];
        
        if(self.isRefreshing)
        {
            if([dict objectForKey:@"posts"]!= nil && [[dict objectForKey:@"posts"] count] > 0)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                NSDate *oldTimeStamp = [dateFormatter dateFromString:timeStamp];
                NSDate *newTimeStamp = [dateFormatter dateFromString:[dict objectForKey:@"last_modified"]];
                if ( ([dict objectForKey:@"etag"] != nil && [[dict objectForKey:@"etag"] length] >0 && ![etag isEqualToString:[dict objectForKey:@"etag"]]) || [newTimeStamp compare:oldTimeStamp] == NSOrderedDescending)
                {
                    timeStamp = [dict objectForKey:@"last_modified"];
                    feedCount = [dict objectForKey:@"feed_count"];
                    postCount = [dict objectForKey:@"post_count"];
                    etag = [dict objectForKey:@"etag"];
                    storiesArray = [[dict objectForKey:@"posts"] mutableCopy];
                    
                }
            }
        }
        else
        {
            timeStamp = [dict objectForKey:@"last_modified"];
            feedCount = [dict objectForKey:@"feed_count"];
            postCount = [dict objectForKey:@"post_count"];
            etag = [dict objectForKey:@"etag"];
            if([storiesArray count] > 0)
            {
                
                [storiesArray addObjectsFromArray:[[dict objectForKey:@"posts"] mutableCopy]];
                
            }
            else
            {
                storiesArray = [[dict objectForKey:@"posts"] mutableCopy];
            }
            
            [self.activityIndicator stopAnimating];
            if([[dict objectForKey:@"posts"] count] == 0)
            {
                self.streamTableView.tableFooterView = nil;
                isMoreAvailabel = NO;
            }
            else
            {
                [self setupTableViewFooter];
                isMoreAvailabel  = YES;
            }
            
        }
        
        bProcessing = NO;
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:storiesArray];
        storiesArray = [orderedSet.array mutableCopy];
        
        //test if prompt is there yet
        NSDictionary *dict1 = [[NSDictionary alloc]init];
        
        if ([storiesArray count]>1)
        {
            dict1 = [storiesArray objectAtIndex:1];
        }
        
        [streamTableView reloadData];
        
        if(isCommented)
        {
            
        }
        [refreshControl endRefreshing];
        
        if([[dict objectForKey:@"verified"] boolValue])
        {
            [self.delegate showVerifiedPhone];
        }
    }
    if(!isFromFriends && profileID.length == 0)
    {
        [refreshControl endRefreshing];
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:storiesArray];
        [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"streamArray"];
    }
    
    if(storiesArray.count == 0 && (!isFromFriends))
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        
        [emptyContentMsgView removeFromSuperview];
    }
    

}

- (void)fetchinStoriesFailedWithError:(NSError *)error
{
    [self.headActivityIndicator stopAnimating];
    bProcessing = NO;
    if([self.headActivityIndicator isAnimating])
    {
        streamTableView.tableHeaderView = nil;
        CGRect rect = refreshHeaderView.frame;
        rect.origin.y -= 44;
        [refreshHeaderView setFrame:rect];
        [streamTableView addSubview:refreshHeaderView];
        refreshLabel.text = @"Pull down to refresh";
        refreshArrow.hidden = NO;
        [self.headActivityIndicator stopAnimating];
    }
    if(isCommented)
    {
        
    }
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
    if (error!=nil)
    {
        
    }
    
    if(storiesArray.count == 0 && (!isFromFriends))
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        
        [emptyContentMsgView removeFromSuperview];
    }

}

/*-(void)setStoriesArray:(NSMutableArray *)storiesArray1
{
  
    if(storiesArray.count == 0 && (!isFromFriends))
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        [emptyContentMsgView removeFromSuperview];
    }
}
*/
-(void)showEmptyContentMessageView {
    
    /*
    
    if(emptyContentMsgView == nil)
    {
        emptyContentMsgView = [[UIView alloc] initWithFrame:self.bounds];
        emptyContentMsgView.backgroundColor = [UIColor whiteColor];
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        NSString *message = @"while we wait for the school to share your\nkid moments we encourage you to digitally\norganize your entire family documents now\n- like driving licenses, immunity records,\ninsurance cards, etc.\n\nit is quick, easy & secure. \naccess ‘em on the go anytime!";
        
        UIButton *plustButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [plustButton addTarget:self action:@selector(plusTapped) forControlEvents:UIControlEventTouchUpInside];
        [plustButton setTag:1];
        [plustButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [emptyContentMsgView addSubview:plustButton];

        
        if(isParentDashBoard)
        {
            message = @"capture your family in action. tag a few or all. share with your circle.";
            [plustButton setImage:[UIImage imageNamed:@"icon-camera-add"] forState:UIControlStateNormal];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
        
        NSRange range = [message rangeOfString:@"quick, easy & secure"];
        
        [attributedString addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:14]
                                 range:range];
        
        range = [message rangeOfString:@"on the go"];
        
        [attributedString addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                          NSUnderlineColorAttributeName: [UIColor lightGrayColor]} range:range];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.attributedText = attributedString;
        [emptyContentMsgView addSubview:messageLabel];
        
        
        
        
        
        CGSize  expectedLabelSize = [message boundingRectWithSize:CGSizeMake(300, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x999999), NSFontAttributeName: [UIFont italicSystemFontOfSize:14]} context:nil].size;
        
        float height = expectedLabelSize.height+10 + 30 + 30;
        
        float yCoOrdinate =   (emptyContentMsgView.frame.size.height - height)/2.0 ;
        
        messageLabel.frame = CGRectMake(10, yCoOrdinate, 300, expectedLabelSize.height +5);
        [plustButton setFrame:CGRectMake((Devicewidth-30)/2.0, messageLabel.frame.origin.y+30+messageLabel.frame.size.height, 30, 30)];
        
    }
    
    [self addSubview:emptyContentMsgView];
    emptyContentMsgView.hidden = NO;
    
     */
}
-(void)checkToHideEmptyMessage {
    
    if(storiesArray.count == 0 && (!isFromFriends))
    {
        [self showEmptyContentMessageView];
    }
    else
    {
        [emptyContentMsgView removeFromSuperview];
    }
}
-(void)plusTapped {
    
    if(isParentDashBoard)
        [self.delegate cameraTappedForParent];
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_DOCUMENT" object:nil];
    }
    
}

#pragma mark Untag Methods
-(void)CallUntagApi
{
/*    unTag_manager = [[UntagManager alloc] init];
    unTag_manager.communicator = [[GenericCommunicator alloc] init];
    unTag_manager.communicator.delegate = unTag_manager;
    unTag_manager.delegate = self;
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString* postCommand = @"untag";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": postCommand,
                               @"body": dict};
    NSDictionary *total_Dict = @{@"postData": postData,
                                 @"kl_id":[[self.storiesArray objectAtIndex:deleteIndex] objectForKey:@"kl_id"]};
    
    [unTag_manager unTagFromPost:total_Dict];
 */
}
-(void)UntagSuccessFul:(NSDictionary *)postDetails
{
    
    NSMutableDictionary *dict = [[self.storiesArray objectAtIndex:deleteIndex] mutableCopy];
    [dict setObject:[postDetails objectForKey:@"tagged_to"] forKey:@"tagged_to"];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"untag"];
    [self.storiesArray replaceObjectAtIndex:deleteIndex withObject:dict];
    [self.streamTableView reloadData];
    
}
-(void)UntagFailedWithError:(NSError *)error
{
    
}
#pragma mark WebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*   CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
     
     CGRect rect = webView.frame;
     rect.size.height = webViewHeight;
     if(webViewHeight > 125)
     {
     rect.size.height = 92;
     [webView setFrame:rect];
     }*/
}
#pragma mark - Tableview Methods
#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This is the loading row
    if([storiesArray count] == indexPath.row)
    {
        return 44;
    }
    
    float height;
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        
       height =  [self calculateHeightForIPad:(NSIndexPath *)indexPath];
        
    } else {

       height =  [self calculateHeightForIphone:(NSIndexPath *)indexPath];
        
    }
    
    return height;
    
}
-(float)calculateHeightForIPad:(NSIndexPath *)indexPath {
    
    
    NSDictionary *dict = [storiesArray objectAtIndex:indexPath.row];
    float height =59;
    
    
    if (indexPath.row > 0 ) {
        height += 10;
    }
    
    NSMutableDictionary *story = [storiesArray objectAtIndex:indexPath.row];
    NSString *storyText = [story objectForKey:@"text"];
    
    //remove the kl_ids here for the items
    storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
    
    
#pragma mark - Milestone Height
#pragma mark -
    if([[dict objectForKey:@"post_type"] isEqualToString:@"Story"])
    {
        NSString *content;
        
        if ([[dict objectForKey:@"images"] count] > 0)
        {
            height += 400*[[dict objectForKey:@"images"] count]+[[dict objectForKey:@"images"] count]-1;
            
            if([[dict objectForKey:@"personality"] boolValue])
            {
                content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[story objectForKey:@"author_name"]]];
            }
            else
            {
                content = [NSString stringWithFormat:@"%@\n%@",[story objectForKey:@"new_title"],storyText];
            }
            
            int taggedPhotosHeight1 = (([[dict objectForKey:@"tagged_to"] count]%10)!=0?1:0)+(int)[[dict objectForKey:@"tagged_to"] count]/10;
            if([[dict objectForKey:@"tagged_to"] count] == 0)
                height += 58;
            else
                height+= 33*taggedPhotosHeight1+11+6;
            
            CGSize expectedLabelSize;
            
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            NSRange redTextRange = [content rangeOfString:[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]}
                                    range:redTextRange];
            
            NSRange persRange = [content rangeOfString:[NSString stringWithFormat:@"%@ is a KidsLink Voice",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16]}
                                    range:persRange];
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.textAlignment = NSTextAlignmentCenter;
            textView.attributedText = attributedText;
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-40, 9999)];
            height+=expectedLabelSize.height;
            
            
        }
        else
        {
            height+= 55.5;
            
            if([[dict objectForKey:@"personality"] boolValue])
            {
                content = [NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[story objectForKey:@"author_name"]];
            }
            else
            {
                content = [NSString stringWithFormat:@"%@",storyText];
            }
            
            int taggedPhotosHeight1 = (([[dict objectForKey:@"tagged_to"] count]%10)!=0?1:0)+(int)[[dict objectForKey:@"tagged_to"] count]/10;
            if([[dict objectForKey:@"tagged_to"] count] == 0)
                height += 38;
            else
                height+= 33*taggedPhotosHeight1+6;
            
            CGSize expectedLabelSize;
            
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.attributedText = attributedText;
            textView.textAlignment = NSTextAlignmentCenter;
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-40, 9999)];
            
            if(expectedLabelSize.height+10 > 250)
            {
                height+=expectedLabelSize.height+10;
            }
            else
            {
                height+=240;
            }
            
            
            
            
        }
        
        
    }
    
    
    NSMutableDictionary *current_story_comment_details = [comment_details objectForKey:[story objectForKey:@"kl_id"]];
    
    
    NSArray *commentsArray = [story objectForKey:@"comments"];
    current_story_comment_details = [CommentsUtils getCommentDetails:story comment_details:current_story_comment_details];
    [comment_details setValue:current_story_comment_details forKey:[story objectForKey:@"kl_id"]];
    
    NSString *showMoreButton =  [current_story_comment_details objectForKey:@"showMoreButton"];
    //Set the height higer to allow for the add showMoreButton (height + 10)
    if ([showMoreButton isEqualToString:@"true"])
        height += 40;
    else if([storyText length] > 0 || [[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"] length] > 0)
        height += 20;
    
    int comments_shown = [[current_story_comment_details objectForKey:@"total_toshow"] intValue];
    long int start = 0;
    start = commentsArray.count-1;
    
    for(int i=0;i<comments_shown;i++) //increase the size for each comment
    {
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[commentsArray objectAtIndex:start--] objectForKey:@"content"]   attributes:attributes];
        
        NIAttributedLabel *textView = [NIAttributedLabel new];
        textView.numberOfLines = 0;
        textView.attributedText = attributedString;
        CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-200, 9999)];
        
        if(expectedLabelSize.height+14 > 47) //if there is a lot of text
        {
            height+=expectedLabelSize.height+10+14;
        }
        else //set a default size
        {
            height+=47+10;
        }
    }
    
    return height;
    
}
-(float)calculateHeightForIphone:(NSIndexPath *)indexPath {
    
    
    NSDictionary *dict = [storiesArray objectAtIndex:indexPath.row];
    float height =59;
    

    
    if (indexPath.row > 0 ) {
        height += 10;
    }
    
    NSMutableDictionary *story = [storiesArray objectAtIndex:indexPath.row];
    NSString *storyText = [story objectForKey:@"text"];
    
    //remove the kl_ids here for the items
    storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
    
    
#pragma mark - Milestone Height
#pragma mark -
    if([[dict objectForKey:@"post_type"] isEqualToString:@"Story"])
    {
        NSString *content;
        
        if ([[dict objectForKey:@"images"] count] > 0)
        {
            height += 300*[[dict objectForKey:@"images"] count]+[[dict objectForKey:@"images"] count]-1;
            
            if([[dict objectForKey:@"personality"] boolValue])
            {
                content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[story objectForKey:@"author_name"]]];
            }
            else
            {
                content = [NSString stringWithFormat:@"%@\n%@",[story objectForKey:@"new_title"],storyText];
            }
            
            int taggedPhotosHeight1 = (([[dict objectForKey:@"tagged_to"] count]%4)!=0?1:0)+(int)[[dict objectForKey:@"tagged_to"] count]/4;
            if([[dict objectForKey:@"tagged_to"] count] == 0)
                height += 58;
            else
                height+= 33*taggedPhotosHeight1+11+6;
            
            CGSize expectedLabelSize;
            
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            NSRange redTextRange = [content rangeOfString:[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]}
                                    range:redTextRange];
            
            NSRange persRange = [content rangeOfString:[NSString stringWithFormat:@"%@ is a KidsLink Voice",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13]}
                                    range:persRange];
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.attributedText = attributedText;
            textView.textAlignment = NSTextAlignmentCenter;
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(280, 9999)];
            height+=expectedLabelSize.height;
            
            
        }
        else
        {
            height+= 55.5;
            
            if([[dict objectForKey:@"personality"] boolValue])
            {
                content = [NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[story objectForKey:@"author_name"]];
            }
            else
            {
                content = [NSString stringWithFormat:@"%@",storyText];
            }
            
            int taggedPhotosHeight1 = (([[dict objectForKey:@"tagged_to"] count]%4)!=0?1:0)+(int)[[dict objectForKey:@"tagged_to"] count]/4;
            if([[dict objectForKey:@"tagged_to"] count] == 0)
                height += 38;
            else
                height+= 33*taggedPhotosHeight1+6;
            
            CGSize expectedLabelSize;
            
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.attributedText = attributedText;
            textView.textAlignment = NSTextAlignmentCenter;
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(280, 9999)];
            
            if(expectedLabelSize.height+10 > 150)
            {
                height+=expectedLabelSize.height+10;
            }
            else
            {
                height+=140;
            }
            
            
            
            
        }
        
        
    }
    
    
    NSMutableDictionary *current_story_comment_details = [comment_details objectForKey:[story objectForKey:@"kl_id"]];
    
    
    NSArray *commentsArray = [story objectForKey:@"comments"];
    current_story_comment_details = [CommentsUtils getCommentDetails:story comment_details:current_story_comment_details];
    [comment_details setValue:current_story_comment_details forKey:[story objectForKey:@"kl_id"]];
    
    NSString *showMoreButton =  [current_story_comment_details objectForKey:@"showMoreButton"];
    //Set the height higer to allow for the add showMoreButton (height + 10)
    if ([showMoreButton isEqualToString:@"true"])
        height += 40;
    else if([storyText length] > 0 || [[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"] length] > 0)
        height += 20;
    
    int comments_shown = [[current_story_comment_details objectForKey:@"total_toshow"] intValue];
    long int start = 0;
    start = commentsArray.count-1;
    
    for(int i=0;i<comments_shown;i++) //increase the size for each comment
    {
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[commentsArray objectAtIndex:start--] objectForKey:@"content"]   attributes:attributes];
        
        NIAttributedLabel *textView = [NIAttributedLabel new];
        textView.numberOfLines = 0;
        textView.attributedText = attributedString;
        CGSize expectedLabelSize = [textView sizeThatFits:CGSizeMake(203, 9999)];
        
        if(expectedLabelSize.height+14 > 47) //if there is a lot of text
        {
            height+=expectedLabelSize.height+10+14;
        }
        else //set a default size
        {
            height+=47+10;
        }
    }
    
    return height;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*  if(isMoreAvailabel)
     return  [storiesArray count] + 1;
     else
     return [storiesArray count];
     */
    [webViewsArray removeAllObjects];
    return [storiesArray count] ;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict;
    //if there are no stories - send back an empty cell
    if ([storiesArray count]==0)
    {
        //return cell;
    }
    else //grab the data which is a dictionary for all row types
    {
        dict= [storiesArray objectAtIndex:indexPath.row];
        NSString *storyType = [dict objectForKey:@"post_type"];
        
        if ([storyType isEqualToString:@"Feed"] )
        {
            NSString *readArticleURL = [dict objectForKey:@"article_url"];
            if (readArticleURL.length>0)
            {
                //Tracking
                
                [self.delegate readArticleClicked:readArticleURL];
            }
            
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( IDIOM == IPAD ) {
        
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        UITableViewCell *cell = [self.streamTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        //This adds extra padding if it is the top row
        float yPosition = indexPath.row < 1 ? 5 : 15;
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        
        
        //removes any subviews from the cell
        for(UIView *viw in [[cell contentView] subviews])
        {
            [viw removeFromSuperview];
        }
        
        
        NSMutableDictionary *story;
        NSString *storyText;
        //if there are no stories - send back an empty cell
        if ([storiesArray count]==0)
        {
            return cell;
        }
        else //grab the data which is a dictionary for all row types
        {
            story= [storiesArray objectAtIndex:indexPath.row];
            storyText = [story objectForKey:@"text"];
            //remove the kl_ids here for the items
            if(storyText != nil && storyText.length > 0)
                storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
        }
        
#pragma mark line that separate cells
        
        UIImageView *bcImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, yPosition)];
        [cell.contentView addSubview:bcImage];
        [bcImage setBackgroundColor:[UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1]];
        
        
        
        //**********
        //For all other types but the 'prompt type', the code starts here
        //**********
        
        //the height of bcImage and topStripImage has to be changed to change height of cell
        
        
        UIImageView *topStripImage;
        
        if (indexPath.row > 0) {
            topStripImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth,50)];
        } else {
            topStripImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth,50)];
        }
        
        
        float height = 0;
        //float heightWithNoImage = 0;
        
#pragma mark line ontop of cells
        UIImageView *topLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, .5)];
        [cell.contentView addSubview:topLineImage];
        topLineImage.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        
        
        
#pragma mark - Milestone
#pragma mark -
        if([[story objectForKey:@"post_type"] isEqualToString:@"Story"])
        {
            //long int h1 = [[dict objectForKey:@"tagged_to"] count]*TAG_SIZE+(([[dict objectForKey:@"tagged_to"] count]>0)?7:0);
            
            
#pragma mark milestone author name
            // Display the author name.
            NSString *authorName = [story objectForKey:@"author_name"];
            NSString *displayName = [NameUtils firstNameAndLastInitialFromName:authorName];
            
            UIView *backView;
            
            UILabel *byLabel = [[UILabel alloc] initWithFrame:CGRectMake(225,-10,90,30)];
            [byLabel setBackgroundColor:[UIColor clearColor]];
            [byLabel setTextAlignment:NSTextAlignmentRight];
            [byLabel setText:[NSString stringWithFormat:@"by %@", displayName]];
            if([[story objectForKey:@"personality"] boolValue])
                [byLabel setText:[NSString stringWithFormat:@"%@", authorName]];
            
            [byLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:14]];
            [byLabel setTextColor:[UIColor whiteColor]];
            
            [byLabel setNumberOfLines:1];
            [byLabel sizeToFit];
            [byLabel setFrame:CGRectMake(streamTableView.frame.size.width - byLabel.frame.size.width - 13 + 1, 8, byLabel.frame.size.width, byLabel.frame.size.height)];
            byLabel.layer.cornerRadius = 5;
            byLabel.layer.masksToBounds = YES;
            
            backView = [[UIView alloc]initWithFrame:CGRectMake(streamTableView.frame.size.width - byLabel.frame.size.width - 18 + 1, 8, byLabel.frame.size.width+12, 21.5)];
            
            byLabel.frame = CGRectMake(-5, 1, backView.frame.size.width, backView.frame.size.height);
            [byLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:14]];
            
            byLabel.layer.shadowColor = [byLabel.textColor CGColor];
            byLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
            
            byLabel.layer.shadowRadius = 3.0;
            byLabel.layer.shadowOpacity = 0.5;
            
            byLabel.layer.masksToBounds = NO;
            [backView addSubview:byLabel];
            
            backView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
            backView.layer.cornerRadius = 7;
            backView.layer.masksToBounds = YES;
            [topStripImage addSubview:backView];
            
            
            UIView *tagView;
            tagView = [[UIView alloc] init];
            [cell.contentView addSubview:tagView];
            
            /*UIButton *dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
             [dropDownButton setFrame:CGRectMake(279, 225, 17,11)];
             [dropDownButton setImage:[UIImage imageNamed:@"white_arrow_down_icon.png"] forState:UIControlStateNormal];
             [dropDownButton setTag:indexPath.row];
             
             [dropDownButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
             */
            if([[story objectForKey:@"images"] count] > 0)
            {
                height  += yPosition;
                
                float yCosrdinateForAttachedImages = yPosition;
                NSMutableArray *tagArray = [NSMutableArray arrayWithArray:[story objectForKey:@"images"]];
                for(int i = 0; i < tagArray.count; i++)
                {
                    if([tagArray[i] rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
                        [cell.contentView addSubview:attachedImage];
                        
                        attachedImage.frame = CGRectMake(0, yCosrdinateForAttachedImages, Devicewidth,400);
                        attachedImage.contentMode = UIViewContentModeScaleAspectFill;
                        attachedImage.clipsToBounds = YES;
                        attachedImage.tag = i;
                        attachedImage.alignment = UIImageViewAlignmentMaskCenter;
                        __weak UIImageView *weakSelf = attachedImage;
                        
                        UIImage *thumb = [photoUtils getGIFImageFromCache:tagArray[i]];
                        
                        if(thumb ==nil)
                        {
                            dispatch_queue_t myQueue = dispatch_queue_create("imageque",NULL);
                            dispatch_async(myQueue, ^{
                                NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:tagArray[i]]];
                                UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFData:data];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    weakSelf.image = gif_image;
                                    
                                    [photoUtils saveImageToCacheWithData:tagArray[i] :data];
                                    
                                    
                                });
                            });
                        }
                        else
                        {
                            weakSelf.image = thumb;
                            
                            
                        }
                        
                        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [playButton setFrame:attachedImage.frame];
                        playButton.tag = i;
                        [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:playButton];
                    }
                    else
                    {
                    UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
                    [cell.contentView addSubview:attachedImage];
                    
                    attachedImage.frame = CGRectMake(0, yCosrdinateForAttachedImages, Devicewidth,400);
                    [attachedImage setImageWithURL:[NSURL URLWithString:tagArray[i]] placeholderImage:[UIImage imageNamed:@"Profile_Wallpaper.png"]];
                    attachedImage.contentMode = UIViewContentModeScaleAspectFill;
                    attachedImage.clipsToBounds = YES;
                    attachedImage.tag = i;
                    attachedImage.alignment = UIImageViewAlignmentMaskCenter;
                    [self.mediaFocusManager installOnView:attachedImage];
                    
                    }
                    if(i+1 != tagArray.count)
                    {
                        yCosrdinateForAttachedImages += 401;
                        height += 401;
                    }
                    else
                    {
                        yCosrdinateForAttachedImages += 400;
                        height += 400;
                    }
                    
                    
                    
                }
                
                
                int taggedPhotosHeight1 = (([[story objectForKey:@"tagged_to"] count]%10)!=0?1:0)+(int)[[story objectForKey:@"tagged_to"] count]/10;
                
                
                if([[story objectForKey:@"tagged_to"] count] == 0)
                    height += 58;
                else{
                    //spac b/w tags and image
                    
                    height += 6;
                    int tagHeight = 33*taggedPhotosHeight1;
                    tagView.frame = CGRectMake(18, height, 380, tagHeight);
                    height+= tagHeight+11;
                }
                
                
                
                // Add Moment Created date
                if ([[story objectForKey:@"created_at"] length]>0)
                {
                    
                    NSString *storyDate = [story objectForKey:@"created_at"];
                    NSMutableString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];
                    NSString *appendingString = @"";
                    UILabel *lblTime = [[UILabel alloc]init];
                    
                    
                    int yCoordinate = tagArray.count*400+tagArray.count-1+yPosition+6;
                    if ([[story objectForKey:@"heart_icon"] length] != 0)
                    {
                       
                        NSString *colorHeartIconURL = [NSString stringWithFormat:@"%@%@",[story objectForKey:@"asset_base_url"],[story objectForKey:@"heart_icon"]];
                        
                        UIImage *colorHeartImage = [photoUtils getImageFromCache:colorHeartIconURL];
                        
                        UIButton *colorHeartbtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [colorHeartbtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                        [colorHeartbtn addTarget:self action:@selector(colorHeartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                        [colorHeartbtn setFrame:CGRectMake(Devicewidth - 32 -20, yCoordinate+20, 32, 28)];
                        colorHeartbtn.tag = indexPath.row;
                        //colorHeartbtn.backgroundColor = [UIColor redColor];
                        [cell.contentView addSubview:colorHeartbtn];
                        
                    }
                    [lblTime setFrame:CGRectMake(Devicewidth - 150 -20 , yCoordinate+1, 150, 16)];
                    
                    [lblTime setText:formattedTime];
                    [lblTime setTextAlignment:NSTextAlignmentRight];
                    lblTime.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                    lblTime.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                    //lblMomentWithImage.backgroundColor = [UIColor redColor];
                    [cell.contentView addSubview:lblTime];
                    
                    
                }
                
                CGSize expectedLabelSize;
                NSString *content;
                if([[story objectForKey:@"personality"] boolValue])
                    content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
                else
                    content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],storyText];
                
                NSDictionary *attribs = @{
                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]
                                          };
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:content
                                                       attributes:attribs];
                NSRange redTextRange = [content rangeOfString:[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"]];
                [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}
                                        range:redTextRange];
                
                NSRange textRange = [content rangeOfString:[NSString stringWithFormat:@"%@ is a KidsLink Voice",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
                [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}
                                        range:textRange];
                
                CGFloat width;
                    width = Devicewidth-40;
                
                NIAttributedLabel *textView = [NIAttributedLabel new];
                textView.numberOfLines = 0;
                textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
                textView.delegate = self;
                textView.autoDetectLinks = YES;
                textView.attributedText = attributedText;
                
                [cell.contentView addSubview:textView];
                
                expectedLabelSize = [textView sizeThatFits:CGSizeMake(width, 9999)];
                textView.frame =  CGRectMake(19.25f, height, width, expectedLabelSize.height);
                
                height += expectedLabelSize.height;
            }
            else
            {
#pragma mark "else" condition milestone without image
                height = 40 + yPosition;
                
                int taggedPhotosHeight1 = (([[story objectForKey:@"tagged_to"] count]%10)!=0?1:0)+(int)[[story objectForKey:@"tagged_to"] count]/10;
                UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
                [cell.contentView addSubview:attachedImage];
                
                UIView* coverView = [[UIView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, 40)];
                coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
                [cell.contentView addSubview:coverView];
                
                
                int randomIndex = [indexPath row] % 10;
                attachedImage.backgroundColor = UIColorFromRGB([colorsArray[randomIndex] integerValue]);
                
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yPosition+5, Devicewidth-30, 30)];
                titleLabel.text = [[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"];
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                [cell.contentView addSubview:titleLabel];
                
                
                CGSize expectedLabelSize;
                
                NSString *content;
                if([[story objectForKey:@"personality"] boolValue])
                    content = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
                else
                    content = [NSString stringWithFormat:@"%@",storyText];
                
                NSDictionary *attribs = @{
                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17],NSForegroundColorAttributeName: [UIColor whiteColor]
                                          };
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:content
                                                       attributes:attribs];
                
                CGFloat width;
             
                    width = Devicewidth-40;
                
                NIAttributedLabel *textView = [NIAttributedLabel new];
                textView.numberOfLines = 0;
                textView.delegate = self;
                textView.autoDetectLinks = YES;
                textView.attributedText = attributedText;
                textView.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:textView];
                
                expectedLabelSize = [textView sizeThatFits:CGSizeMake(width, 9999)];
                
                if(expectedLabelSize.height+20 > 250)
                {
                    
                    textView.frame =  CGRectMake(19.25f, height+10, width, expectedLabelSize.height);
                    
                    if(yPosition == 15)
                    {
                        height+=expectedLabelSize.height+20;
                        attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height-10);
                    }
                    else
                    {
                        height+=expectedLabelSize.height+20;
                        attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height);
                        
                    }
                    
                    height+=5;
                    
                }
                else
                {
                    float y = (230-expectedLabelSize.height)/2.0;
                    textView.frame =  CGRectMake(19.25f, height+10+y, width, 230);
                    
                    if(yPosition == 15)
                    {
                        height+=230+20;
                        attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height-10);
                    }
                    else
                    {
                        height+=230+20;
                        attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height);
                        
                    }
                    
                    
                    height+=5;
                    
                }
                
                
                
                
                
                
                if([[story objectForKey:@"tagged_to"] count] == 0)
                    height += 38;
                else
                {
                    height += 6;
                    //spac b/w tags and image
                    
                    int tagHeight = 33*taggedPhotosHeight1;
                    tagView.frame = CGRectMake(18, attachedImage.frame.size.height+yPosition+6, 380, tagHeight);
                    height += tagHeight;
                }
                [attachedImage setImage:[UIImage imageNamed:@"Profile_Wallpaper.png"]];
                attachedImage.contentMode = UIViewContentModeScaleAspectFill;
                attachedImage.alignTop = TRUE;
                attachedImage.clipsToBounds = YES;
                
                NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
                [textStyle setLineSpacing:5];
                [textStyle setLineBreakMode:NSLineBreakByTruncatingTail];
                [textStyle setAlignment:NSTextAlignmentCenter];
                
                
                if ([[story objectForKey:@"created_at"] length]>0)
                {
                    
                    NSString *storyDate = [story objectForKey:@"created_at"];
                    NSMutableString     *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];
                    UILabel *lblMilestoneWithoutImage = [[UILabel alloc]init];
                    
                    int yCoordinate = attachedImage.frame.size.height+6+yPosition;
                    if ([[story objectForKey:@"heart_icon"] length] != 0)
                    {
                       
                        NSString *colorHeartIconURL = [NSString stringWithFormat:@"%@%@",[story objectForKey:@"asset_base_url"],[story objectForKey:@"heart_icon"]];
                        
                        UIImage *colorHeartImage = [photoUtils getImageFromCache:colorHeartIconURL];
                        
                        UIButton *colorHeartbtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [colorHeartbtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                        
                        [colorHeartbtn addTarget:self action:@selector(colorHeartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                        [colorHeartbtn setFrame:CGRectMake(Devicewidth - 32 -20, yCoordinate+20, 32, 28)];
                        colorHeartbtn.tag = indexPath.row;
                        //colorHeartbtn.backgroundColor = [UIColor redColor];
                        [cell.contentView addSubview:colorHeartbtn];
                    }
                    
                    [lblMilestoneWithoutImage setFrame:CGRectMake(Devicewidth - 150 -20 , yCoordinate+1, 150, 15)];

                    [lblMilestoneWithoutImage setText:formattedTime];
                    [lblMilestoneWithoutImage setTextAlignment:NSTextAlignmentRight];
                    lblMilestoneWithoutImage.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:12];
                    lblMilestoneWithoutImage.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                    //lblMilestoneWithoutImage.backgroundColor = [UIColor redColor];
                    [cell.contentView addSubview:lblMilestoneWithoutImage];
                    
                }
                
                
            }
            
            
            if([[story objectForKey:@"schoolIamge"] length])
            {
                UIImageView *schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-35, yPosition+5, 30, 30)];
                __weak UIImageView *weakSelf = schoolImage;
                
                [schoolImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[story objectForKey:@"schoolIamge"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     [weakSelf setImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0]];
                     
                 }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                 {
                     DebugLog(@"fail");
                 }];
                
                [cell.contentView addSubview:schoolImage];
                
            }
            else
            {
                [cell.contentView addSubview:topStripImage];
            }
#pragma mark - Tagged photos for Milestone
#pragma mark -
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[story objectForKey:@"tagged_to"]];
            int x = 0;
            int y=0;
            for(int i = 0,count =1; i < array.count; i++)
                //for(id dict in array)
            {
                
                id dict = [array objectAtIndex:i];
                NSString *url;
                UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
                [tagView addSubview:imagVw];
                
                [imagVw setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                //add initials
                
                NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
                if([dict valueForKey:@"nickname"] != (id)[NSNull null] && [[dict valueForKey:@"nickname"] length] > 0)
                {
                    [parentFnameInitial appendString:[[[dict valueForKey:@"nickname"] substringToIndex:1] uppercaseString]];
                }
                else
                {
                    if([dict valueForKey:@"fname"] != (id)[NSNull null] && [[dict valueForKey:@"fname"] length] >0)
                        [parentFnameInitial appendString:[[[dict valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
                    if([dict valueForKey:@"lname"] != (id)[NSNull null] && [[dict valueForKey:@"lname"] length]>0)
                        [parentFnameInitial appendString:[[[dict valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
                }
                
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                                       attributes:nil];
                NSRange range;
                if(parentFnameInitial.length > 0)
                {
                    range.location = 0;
                    range.length = 1;
                    [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:17]}
                                            range:range];
                }
                if(parentFnameInitial.length > 1)
                {
                    range.location = 1;
                    range.length = 1;
                    [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Light" size:17]}
                                            range:range];
                }
                
                
                //add initials
                
                UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                initial.attributedText = attributedText;
                [initial setBackgroundColor:[UIColor clearColor]];
                initial.textAlignment = NSTextAlignmentCenter;
                [imagVw addSubview:initial];
                
                //end add initials
                
                if([dict isKindOfClass:[NSDictionary class]])
                    url  = [dict objectForKey:@"photograph"];
                else if([dict isKindOfClass:[NSString class]])
                    url = dict;
                if(url != (id)[NSNull null] && url.length > 0)
                {
                    UIImage *thumb = [photoUtils getImageFromCache:url];
                    __weak UIImageView *weakSelf = imagVw;
                    if (thumb == nil)
                    {
                        // Fetch image, cache it, and add it to the tag.
                        [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                         {
                             [photoUtils saveImageToCache:url :image];
                             [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                             UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                             userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0];
                             [weakSelf addSubview:userImage];
                             [initial removeFromSuperview];
                         }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                         {
                             DebugLog(@"fail");
                         }];
                    }
                    else
                    {
                        // Add cached image to the tag.
                        [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                        UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                        userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:thumb scaledToSize:CGSizeMake(30, 30)] withRadious:0];
                        [weakSelf addSubview:userImage];
                        [initial removeFromSuperview];
                    }
                    
                }
                
                x+= 32;
                if((i+1)%10 == 0)
                {
                    x=0;
                    y+=33;
                    count++;
                }
            }
            
        }
        
        
        
        
        
        NSMutableDictionary *currentStory = [storiesArray objectAtIndex:indexPath.row];
        NSMutableDictionary *current_story_comment_details = [comment_details objectForKey:[currentStory objectForKey:@"kl_id"]];
        NSArray *commentsArray = [currentStory objectForKey:@"comments"];
        /*
         NSArray *commentsArray = [currentStory objectForKey:@"comments"];
         
         current_story_comment_details = [CommentsUtils getCommentDetails:currentStory comment_details:current_story_comment_details];
         [comment_details setValue:current_story_comment_details forKey:[currentStory objectForKey:@"kl_id"]];
         */
        
        NSString *showMoreButton = [current_story_comment_details objectForKey:@"showMoreButton"];
        int comments_shown = [[current_story_comment_details objectForKey:@"total_toshow"] intValue];
        
        
        //[singletonObj.comment_details setValue:[@(comments_shown) stringValue] forKey:[currentStory objectForKey:@"kl_id"]];
        
        CGSize expectedLabelSize;
        
        //if show more button
        if ([showMoreButton isEqualToString:@"true"])
        {
            UIButton *btnShowMore = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnShowMore addTarget:self action:@selector(showMoreCommentsTapped:) forControlEvents:UIControlEventTouchUpInside];
            [btnShowMore setImage:[UIImage imageNamed:@"view_older_comments.png"] forState:UIControlStateNormal];
            [btnShowMore setImage:[UIImage imageNamed:@"view_older_comments_highlighted.png"] forState:UIControlStateSelected];
            btnShowMore.frame = CGRectMake(0, height, Devicewidth, 40);
            btnShowMore.tag = indexPath.row;
            [cell.contentView addSubview:btnShowMore];
            
            height += 40;
            
            UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, height, Devicewidth-40, 0.5)];
            line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            [line setTextAlignment:NSTextAlignmentLeft];
            line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
            [cell.contentView addSubview:line];
            
            height += 5;
            
            //end buffer
            
            
        }
        else
        {
            
            //DM - adding a buffer between the comments and the text
            if(storyText.length > 0 || ([storyText length] > 0 || [[story objectForKey:@"new_title"] length] > 0))
                height += 20;
            
            UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, height, Devicewidth-40, 0.5)];
            line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            [line setTextAlignment:NSTextAlignmentLeft];
            line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
            [cell.contentView addSubview:line];
            
            //end buffer
            height+=5;
            
        }
        
        int start = 0;
        if ([showMoreButton isEqualToString:@"true"])
        {
            start = (int)(commentsArray.count - comments_shown); //number total - number shown
        }
        
        float y = height;
        
        int i = 0;
        for (i = start; i < commentsArray.count; i++)
        {
            NSDictionary *dict = [commentsArray objectAtIndex:i];
            
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, 47, 47)];
            [imagVw setImage:[UIImage imageNamed:@"tag_thumbnail.png"]];
            //add initials
            NSString *nickname = [dict valueForKey:@"commented_by"];
            
            NSArray *nameArray = [nickname componentsSeparatedByString:@" "];
            
            NSString *firstName = [[nameArray.firstObject substringToIndex:1]uppercaseString];;
            NSString *lastName = [[nameArray.lastObject substringToIndex:1] uppercaseString];;
            
            
            NSMutableString *commenterInitial = [[NSMutableString alloc] init];
            [commenterInitial appendString:firstName];
            [commenterInitial appendString:lastName];
            
            NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
            
            NSRange range;
            if(firstName.length > 0)
            {
                range.location = 0;
                range.length = 1;
                [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:20]}
                                                  range:range];
            }
            if(lastName.length > 0)
            {
                range.location = 1;
                range.length = 1;
                [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Light" size:20]}
                                                  range:range];
            }
            
            
            UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
            initial.attributedText = attributedTextForComment;
            [initial setBackgroundColor:[UIColor clearColor]];
            initial.textAlignment = NSTextAlignmentCenter;
            [imagVw addSubview:initial];
            //end add initials
            
            __weak UIImageView *weakSelf = imagVw;
            DebugLog(@"*************%@",dict);
            NSString *url = [dict objectForKey:@"commenter_photo"];
            if(url != (id)[NSNull null] && url.length > 0)
            {
                // Fetch image, cache it, and add it to the tag.
                [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     [photoUtils saveImageToCache:url :image];
                     
                     [weakSelf setImage:[UIImage imageNamed:@"tag_background.png"]];
                     UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
                     userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(51, 51)] withRadious:0];
                     [weakSelf addSubview:userImage];
                     [initial removeFromSuperview];
                 }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                 {
                     DebugLog(@"fail");
                 }];
            }
            
            [cell.contentView addSubview:imagVw];
            
            NSString *nameText = [dict objectForKey:@"commented_by"];
            UILabel *nameLabel;
            if (nameText != (id)[NSNull null] && nameText.length > 0)
            {
                NSString *childName = [dict objectForKey:@"child_name"];
                NSString *childRelationship = [dict objectForKey:@"child_relationship"];
                NSString *relationText = @"";
                
                NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16]};

                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:nameText   attributes:attributes];

                if(childName != (id)[NSNull null] && childRelationship != (id)[NSNull null] && childName.length >0 && childRelationship.length >0)    {
                    
                    relationText = [NSString stringWithFormat:@" %@'s %@",childName,childRelationship];
                    NSAttributedString *relationAttribute = [[NSAttributedString alloc] initWithString:relationText attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15]}];
                    
                    [attributedString appendAttributedString:relationAttribute];
                    
                }

                
                nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(77,y+2,130,12)];
                [nameLabel setBackgroundColor:[UIColor clearColor]];
                [nameLabel setAttributedText:attributedString];
                [nameLabel setNumberOfLines:0];
                [cell.contentView addSubview:nameLabel];

            }
            
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Devicewidth-110-20,y+2,110,14)];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
            
            NSString *milestoneDate = [dict objectForKey:@"created_at"];
            NSString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:milestoneDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];
            
            [dateLabel setText:formattedTime];
            [dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
            [dateLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
            [dateLabel setNumberOfLines:0];
            [dateLabel setTextAlignment:NSTextAlignmentRight];
            [cell.contentView addSubview:dateLabel];
            
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]};
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"content"]   attributes:attributes];
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.delegate = self;
            textView.autoDetectLinks = YES;
            textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            textView.attributedText = attributedString;
            [cell.contentView addSubview:textView];
            
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth-200, 9999)];
            textView.frame =  CGRectMake(77, y+14, Devicewidth-200, expectedLabelSize.height);
            
#pragma mark hidden comment
            if ([[dict objectForKey:@"unknown_commenter"] boolValue] == YES)
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15]};
                attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"content"]   attributes:attributes];
                textView.attributedText = attributedString;
                [textView setAlpha:0.4f];
                [dateLabel setAlpha:0.4f];
                [nameLabel setAlpha:0.4f];
                [weakSelf setAlpha:0.4f];
            }
            
            if(textView.frame.size.height+14 > 47)
                y+=expectedLabelSize.height+5+14;
            else
                y+=47+5;
            
            
            UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, y, Devicewidth-40, 0.5)];
            line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            [line setTextAlignment:NSTextAlignmentLeft];
            line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
            [cell.contentView addSubview:line];
            
            y+=5;
            
            
        }
        
#pragma mark - Add Heart button and comments and post options
#pragma mark -
        
        UIButton *addHeartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addHeartBtn addTarget:self action:@selector(heartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        // isHeartSelected = [[dict objectForKey:@"hearted"] boolValue];
        
        if([[story objectForKey:@"hearted"] boolValue] == NO)
        {
            [addHeartBtn setImage:[UIImage imageNamed:@"HeardIconGray.png"] forState:UIControlStateNormal];
        }
        else
        {
            [addHeartBtn setImage:[UIImage imageNamed:@"HeardIconDark.png"] forState:UIControlStateNormal];
        }
        [addHeartBtn setFrame:CGRectMake(18.5, y+11, 24, 22)];
        addHeartBtn.tag = indexPath.row;
        [cell.contentView addSubview:addHeartBtn];
        if([[story objectForKey:@"local_change"] boolValue])
            addHeartBtn.userInteractionEnabled = NO;
        else
            addHeartBtn.userInteractionEnabled = YES;
        
        
        UIImageView *msgImage = [[UIImageView alloc] initWithFrame:CGRectMake(63, y+11.5, 29,21)];
        [msgImage setImage:[UIImage imageNamed:@"message_icon.png"]];
        [cell.contentView addSubview:msgImage];
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(98,y,100,44)];
        [commentLabel setBackgroundColor:[UIColor clearColor]];
        [commentLabel setText:@"Comment"];
        [commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
        [commentLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [commentLabel setNumberOfLines:0];
        [cell.contentView addSubview:commentLabel];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setFrame:CGRectMake(67, y, 100, 44)];
        commentBtn.tag = indexPath.row;
        //[commentBtn setBackgroundColor:[UIColor redColor]];
        [commentBtn addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:commentBtn];
        
        // MARK:Drop down
        UIImageView *dropDownImage = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-20-32, y+17.5, 32,9)];
        dropDownImage.image = [UIImage imageNamed:@"white_arrow_down_icon.png"];
        
        UIButton *dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dropDownButton setFrame:CGRectMake(Devicewidth-80-20, y, 85,44)];
        //[dropDownButton setImage:[UIImage imageNamed:@"white_arrow_down_icon.png"] forState:UIControlStateNormal];
        [dropDownButton setTag:indexPath.row];
        
        [dropDownButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if([[story valueForKey:@"can_delete"] boolValue] || [[story valueForKey:@"untag"] boolValue] || [[story valueForKey:@"can_download"] boolValue])
        {
            [cell.contentView addSubview:dropDownImage];
            [cell.contentView addSubview:dropDownButton];
            
        }
        
#pragma mark - bottom line after add comment section
#pragma mark -
        
        //bottom line is 1 point above bottom of comment button
        UIImageView *bottomLineImageAfter = [[UIImageView alloc] initWithFrame:CGRectMake(0, y + 49, Devicewidth, .5)];
        
        
        [cell.contentView addSubview:bottomLineImageAfter];
        bottomLineImageAfter.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        return cell;
        
    } else {

       return  [self buildCellForIphone:(NSIndexPath *)indexPath];
    }
    
}
-(UITableViewCell *)buildCellForIphone:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [self.streamTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    //This adds extra padding if it is the top row
    float yPosition = indexPath.row < 1 ? 5 : 15;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    

    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    
    NSMutableDictionary *story;
    NSString *storyText;
    //if there are no stories - send back an empty cell
    if ([storiesArray count]==0)
    {
        return cell;
    }
    else //grab the data which is a dictionary for all row types
    {
        story= [storiesArray objectAtIndex:indexPath.row];
        storyText = [story objectForKey:@"text"];
        //remove the kl_ids here for the items
        if(storyText != nil && storyText.length > 0)
            storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
    }
    
#pragma mark line that separate cells
    
    UIImageView *bcImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, yPosition)];
    [cell.contentView addSubview:bcImage];
    [bcImage setBackgroundColor:[UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1]];
    
    
    
    //**********
    //For all other types but the 'prompt type', the code starts here
    //**********
    
    //the height of bcImage and topStripImage has to be changed to change height of cell
    
    
    UIImageView *topStripImage;
    
    if (indexPath.row > 0) {
        topStripImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth,50)];
    } else {
        topStripImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth,50)];
    }
    
    
    float height = 0;
    //float heightWithNoImage = 0;
    
#pragma mark line ontop of cells
    UIImageView *topLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, .5)];
    [cell.contentView addSubview:topLineImage];
    topLineImage.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    
    
    
#pragma mark - Milestone
#pragma mark -
    if([[story objectForKey:@"post_type"] isEqualToString:@"Story"])
    {
        //long int h1 = [[dict objectForKey:@"tagged_to"] count]*TAG_SIZE+(([[dict objectForKey:@"tagged_to"] count]>0)?7:0);
        
        
#pragma mark milestone author name
        // Display the author name.
        NSString *authorName = [story objectForKey:@"author_name"];
        NSString *displayName = [NameUtils firstNameAndLastInitialFromName:authorName];
        
        UIView *backView;
        
        UILabel *byLabel = [[UILabel alloc] initWithFrame:CGRectMake(Devicewidth-95,-10,90,30)];
        [byLabel setBackgroundColor:[UIColor clearColor]];
        [byLabel setTextAlignment:NSTextAlignmentRight];
        [byLabel setText:[NSString stringWithFormat:@"by %@", displayName]];
        if([[story objectForKey:@"personality"] boolValue])
            [byLabel setText:[NSString stringWithFormat:@"%@", authorName]];
        
        [byLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:14]];
        [byLabel setTextColor:[UIColor whiteColor]];
        
        [byLabel setNumberOfLines:1];
        [byLabel sizeToFit];
        [byLabel setFrame:CGRectMake(streamTableView.frame.size.width - byLabel.frame.size.width - 13 + 1, 8, byLabel.frame.size.width, byLabel.frame.size.height)];
        byLabel.layer.cornerRadius = 5;
        byLabel.layer.masksToBounds = YES;
        
        backView = [[UIView alloc]initWithFrame:CGRectMake(streamTableView.frame.size.width - byLabel.frame.size.width - 18 + 1, 8, byLabel.frame.size.width+12, 21.5)];
        
        byLabel.frame = CGRectMake(-5, 1, backView.frame.size.width, backView.frame.size.height);
        [byLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:14]];
        
        byLabel.layer.shadowColor = [byLabel.textColor CGColor];
        byLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        
        byLabel.layer.shadowRadius = 3.0;
        byLabel.layer.shadowOpacity = 0.5;
        
        byLabel.layer.masksToBounds = NO;
        [backView addSubview:byLabel];
        
        backView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
        backView.layer.cornerRadius = 7;
        backView.layer.masksToBounds = YES;
        [topStripImage addSubview:backView];
        
        
        UIView *tagView;
        tagView = [[UIView alloc] init];
        [cell.contentView addSubview:tagView];
        
        /*UIButton *dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
         [dropDownButton setFrame:CGRectMake(279, 225, 17,11)];
         [dropDownButton setImage:[UIImage imageNamed:@"white_arrow_down_icon.png"] forState:UIControlStateNormal];
         [dropDownButton setTag:indexPath.row];
         
         [dropDownButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
         */
        if([[story objectForKey:@"images"] count] > 0)
        {
            height  += yPosition;
            
            float yCosrdinateForAttachedImages = yPosition;
            NSMutableArray *tagArray = [NSMutableArray arrayWithArray:[story objectForKey:@"images"]];
            for(int i = 0; i < tagArray.count; i++)
            {
                if([tagArray[i] rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
                    [cell.contentView addSubview:attachedImage];
                    
                    attachedImage.frame = CGRectMake(0, yCosrdinateForAttachedImages, Devicewidth,300);
                    attachedImage.contentMode = UIViewContentModeScaleAspectFill;
                    attachedImage.clipsToBounds = YES;
                    attachedImage.tag = i;
                    attachedImage.alignment = UIImageViewAlignmentMaskCenter;
                    __weak UIImageView *weakSelf = attachedImage;
                    
                    UIImage *thumb = [photoUtils getGIFImageFromCache:tagArray[i]];
                    
                    if(thumb ==nil)
                    {
                        dispatch_queue_t myQueue = dispatch_queue_create("imageque",NULL);
                        dispatch_async(myQueue, ^{
                            NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:tagArray[i]]];
                            UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFData:data];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.image = gif_image;
                                [photoUtils saveImageToCacheWithData:tagArray[i] :data];
                                
                                
                            });
                        });
                    }
                    else
                    {
                        weakSelf.image = thumb;
                    }
                    
                    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [playButton setFrame:attachedImage.frame];
                    playButton.tag = i;
                    [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:playButton];
                }
                else {
                    
                    UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
                    [cell.contentView addSubview:attachedImage];
                    
                    attachedImage.frame = CGRectMake(0, yCosrdinateForAttachedImages, Devicewidth,300);
                    [attachedImage setImageWithURL:[NSURL URLWithString:tagArray[i]] placeholderImage:[UIImage imageNamed:@"Profile_Wallpaper.png"]];
                    attachedImage.contentMode = UIViewContentModeScaleAspectFill;
                    attachedImage.clipsToBounds = YES;
                    attachedImage.tag = i;
                    attachedImage.alignment = UIImageViewAlignmentMaskCenter;
                    [self.mediaFocusManager installOnView:attachedImage];
                    

                    
                }
                if(i+1 != tagArray.count)
                {
                    yCosrdinateForAttachedImages += 301;
                    height += 301;
                }
                else
                {
                    yCosrdinateForAttachedImages += 300;
                    height += 300;
                }
                
                
                
            }
            
            
            int taggedPhotosHeight1 = (([[story objectForKey:@"tagged_to"] count]%4)!=0?1:0)+(int)[[story objectForKey:@"tagged_to"] count]/4;
            
            
            if([[story objectForKey:@"tagged_to"] count] == 0)
                height += 58;
            else{
                //spac b/w tags and image
                
                height += 6;
                int tagHeight = 33*taggedPhotosHeight1;
                tagView.frame = CGRectMake(18, height, 129, tagHeight);
                height+= tagHeight+11;
            }
            
            
            
            // Add Moment Created date
            if ([[story objectForKey:@"created_at"] length]>0)
            {
                
                NSString *storyDate = [story objectForKey:@"created_at"];
                NSMutableString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];
                /*
                 if([[dict objectForKey:@"kid_birthdate"] length] != 0)
                 {
                 [formattedTime appendString:[NSString stringWithFormat:@" \u2022 %@",[profileDateUtils getAgeFromTwoDates:[dict objectForKey:@"kid_birthdate"]]]];
                 }
                 */
                NSString *appendingString = @"";
                /*     if([[story objectForKey:@"kid_birthdate"] length] > 0)
                 {
                 NSString *kidBirthDateOnly = [NSString stringWithFormat:@"%@",[story objectForKey:@"kid_birthdate"]];
                 NSString *milestoneCreatedDate = [NSString stringWithFormat:@"%@",[story objectForKey:@"created_at"]];
                 
                 NSString *milestoneCreatedDateOnly = [NSString stringWithFormat:@"%@",[profileDateUtils localTimeFromUTC:milestoneCreatedDate]];
                 
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                 [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                 
                 NSDate *kidBirthDate = [dateFormatter dateFromString:kidBirthDateOnly];
                 NSDate *milCreatedDate = [dateFormatter dateFromString:milestoneCreatedDateOnly];
                 
                 
                 if ([milCreatedDate compare:kidBirthDate] == NSOrderedDescending)
                 {
                 appendingString = [profileDateUtils getChildAgeFromMilestoneCreatedDate:milestoneCreatedDateOnly ChildBirthDate:kidBirthDateOnly];
                 }
                 else if ([milCreatedDate compare:kidBirthDate] == NSOrderedAscending)
                 {
                 
                 appendingString = [profileDateUtils getChildAgeFromMilestoneCreatedDate:milestoneCreatedDateOnly ChildBirthDate:kidBirthDateOnly];
                 }
                 else if([milCreatedDate compare:kidBirthDate] == NSOrderedSame)
                 {
                 appendingString = @"date of birth";
                 }
                 }
                 */
                UILabel *lblTime = [[UILabel alloc]init];
                UILabel *lblMilestoneWithBelow = [[UILabel alloc]init];
                
                
                int yCoordinate = tagArray.count*300+tagArray.count-1+yPosition+6;
                if ([[story objectForKey:@"heart_icon"] length] == 0)
                {
                    if (appendingString.length >0)
                    {
                        [lblTime setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+1, 153, 15)];
                        [lblMilestoneWithBelow setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+15, 153, 15)];
                    }
                    else
                    {
                        [lblTime setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate, 153, 30)];
                    }
                }
                else
                {
                    if (appendingString.length >0)
                    {
                        
                        [lblTime setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+1, 153, 15)];
                        [lblMilestoneWithBelow setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+15, 153, 15)];
                    }
                    else
                    {
                        [lblTime setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate, 153, 15)];
                    }
                    NSString *colorHeartIconURL = [NSString stringWithFormat:@"%@%@",[story objectForKey:@"asset_base_url"],[story objectForKey:@"heart_icon"]];
                    
                    UIImage *colorHeartImage = [photoUtils getImageFromCache:colorHeartIconURL];
                    
                    UIButton *colorHeartbtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [colorHeartbtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                    [colorHeartbtn addTarget:self action:@selector(colorHeartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                    [colorHeartbtn setFrame:CGRectMake(Devicewidth - 32 - 18, yCoordinate+20, 32, 28)];
                    colorHeartbtn.tag = indexPath.row;
                    //colorHeartbtn.backgroundColor = [UIColor redColor];
                    [cell.contentView addSubview:colorHeartbtn];
                    
                }
                
                [lblTime setText:formattedTime];
                [lblTime setTextAlignment:NSTextAlignmentRight];
                lblTime.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                lblTime.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                //lblMomentWithImage.backgroundColor = [UIColor redColor];
                [cell.contentView addSubview:lblTime];
                
                
                lblMilestoneWithBelow.text = appendingString;
                [lblMilestoneWithBelow setTextAlignment:NSTextAlignmentRight];
                lblMilestoneWithBelow.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                lblMilestoneWithBelow.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                [cell.contentView addSubview:lblMilestoneWithBelow];
                
            }
            
            CGSize expectedLabelSize;
            NSString *content;
            if([[story objectForKey:@"personality"] boolValue])
                content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
            else
                content = [NSString stringWithFormat:@"%@\n%@",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"],storyText];
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            NSRange redTextRange = [content rangeOfString:[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}
                                    range:redTextRange];
            
            NSRange textRange = [content rangeOfString:[NSString stringWithFormat:@"%@ is a KidsLink Voice",[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
            [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13],NSForegroundColorAttributeName: [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]}
                                    range:textRange];
            
            CGFloat width;
                width = Devicewidth - 40;
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            textView.delegate = self;
            textView.autoDetectLinks = YES;
            textView.attributedText = attributedText;
            
            [cell.contentView addSubview:textView];
            
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(width, 9999)];
            textView.frame =  CGRectMake(19.25f, height, width, expectedLabelSize.height);
            
            height += expectedLabelSize.height;
        }
        else
        {
#pragma mark "else" condition milestone without image
            height = 40 + yPosition;
            
            int taggedPhotosHeight1 = (([[story objectForKey:@"tagged_to"] count]%4)!=0?1:0)+(int)[[story objectForKey:@"tagged_to"] count]/4;
            UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
            [cell.contentView addSubview:attachedImage];
            
            UIView* coverView = [[UIView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, 40)];
            coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
            [cell.contentView addSubview:coverView];
            
            
            int randomIndex = [indexPath row] % 10;
            attachedImage.backgroundColor = UIColorFromRGB([colorsArray[randomIndex] integerValue]);
            
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yPosition+5, Devicewidth - 100, 30)];
            titleLabel.text = [[storiesArray objectAtIndex:indexPath.row] objectForKey:@"new_title"];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
            [cell.contentView addSubview:titleLabel];
            
            
            CGSize expectedLabelSize;
            
            NSString *content;
            if([[story objectForKey:@"personality"] boolValue])
                content = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@\n\n%@ is a KidsLink Voice",storyText,[[storiesArray objectAtIndex:indexPath.row] objectForKey:@"author_name"]]];
            else
                content = [NSString stringWithFormat:@"%@",storyText];
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName: [UIColor whiteColor]
                                      };
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:content
                                                   attributes:attribs];
            
            CGFloat width;
            
                width = Devicewidth - 40;
            
            NIAttributedLabel *textView = [NIAttributedLabel new];
            textView.numberOfLines = 0;
            textView.delegate = self;
            textView.autoDetectLinks = YES;
            textView.attributedText = attributedText;
            textView.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:textView];
            
            expectedLabelSize = [textView sizeThatFits:CGSizeMake(width, 9999)];
            
            if(expectedLabelSize.height+20 > 150)
            {
                
                textView.frame =  CGRectMake(19.25f, height+10, width, expectedLabelSize.height);
                
                if(yPosition == 15)
                {
                    height+=expectedLabelSize.height+20;
                    attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height-10);
                }
                else
                {
                    height+=expectedLabelSize.height+20;
                    attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height);
                    
                }
                
                height+=5;
                
            }
            else
            {
                float y = (130-expectedLabelSize.height)/2.0;
                textView.frame =  CGRectMake(19.25f, height+10+y, width, 130);
                
                if(yPosition == 15)
                {
                    height+=130+20;
                    attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height-10);
                }
                else
                {
                    height+=130+20;
                    attachedImage.frame = CGRectMake(0, yPosition, Devicewidth,height);
                    
                }
                
                
                height+=5;
                
            }
            
            
            
            
            
            
            if([[story objectForKey:@"tagged_to"] count] == 0)
                height += 38;
            else
            {
                height += 6;
                //spac b/w tags and image
                
                int tagHeight = 33*taggedPhotosHeight1;
                tagView.frame = CGRectMake(18, attachedImage.frame.size.height+yPosition+6, 129, tagHeight);
                height += tagHeight;
            }
            [attachedImage setImage:[UIImage imageNamed:@"Profile_Wallpaper.png"]];
            attachedImage.contentMode = UIViewContentModeScaleAspectFill;
            attachedImage.alignTop = TRUE;
            attachedImage.clipsToBounds = YES;
            
            NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
            [textStyle setLineSpacing:5];
            [textStyle setLineBreakMode:NSLineBreakByTruncatingTail];
            [textStyle setAlignment:NSTextAlignmentCenter];
            
            
            if ([[story objectForKey:@"created_at"] length]>0)
            {
                
                NSString *storyDate = [story objectForKey:@"created_at"];
                NSMutableString     *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];
                NSString *appendingString = @"";
                /*     if([[story objectForKey:@"kid_birthdate"] length] > 0)
                 {
                 NSString *kidBirthDateOnly = [NSString stringWithFormat:@"%@",[story objectForKey:@"kid_birthdate"]];
                 NSString *milestoneCreatedDate = [NSString stringWithFormat:@"%@",[story objectForKey:@"created_at"]];
                 
                 NSString *milestoneCreatedDateOnly = [NSString stringWithFormat:@"%@",[profileDateUtils localTimeFromUTC:milestoneCreatedDate]];
                 
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                 [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                 
                 NSDate *kidBirthDate = [dateFormatter dateFromString:kidBirthDateOnly];
                 NSDate *milCreatedDate = [dateFormatter dateFromString:milestoneCreatedDateOnly];
                 
                 
                 if ([milCreatedDate compare:kidBirthDate] == NSOrderedDescending)
                 {
                 appendingString = [profileDateUtils getChildAgeFromMilestoneCreatedDate:milestoneCreatedDateOnly ChildBirthDate:kidBirthDateOnly];
                 }
                 else if ([milCreatedDate compare:kidBirthDate] == NSOrderedAscending)
                 {
                 
                 appendingString = [profileDateUtils getChildAgeFromMilestoneCreatedDate:milestoneCreatedDateOnly ChildBirthDate:kidBirthDateOnly];
                 }
                 else if([milCreatedDate compare:kidBirthDate] == NSOrderedSame)
                 {
                 appendingString = @"date of birth";
                 }
                 }
                 */
#pragma mark - Milestone without image
#pragma mark -
                UILabel *lblMilestoneWithoutImage = [[UILabel alloc]init];
                UILabel *lblMilestoneWithoutImageBelow = [[UILabel alloc]init];
                
                int yCoordinate = attachedImage.frame.size.height+6+yPosition;
                if ([[story objectForKey:@"heart_icon"] length] == 0)
                {
                    if (appendingString.length >0)
                    {
                        [lblMilestoneWithoutImage setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+1, 153, 15)];
                        [lblMilestoneWithoutImageBelow setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+15, 153, 15)];
                    }
                    else
                    {
                        [lblMilestoneWithoutImage setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate, 153, 30)];
                    }
                }
                else
                {
                    if (appendingString.length >0)
                    {
                        [lblMilestoneWithoutImage setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+1, 153, 15)];
                        [lblMilestoneWithoutImageBelow setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate+15, 153, 15)];
                    }
                    else
                    {
                        [lblMilestoneWithoutImage setFrame:CGRectMake(Devicewidth - 153 - 17, yCoordinate, 153, 15)];
                    }
                    NSString *colorHeartIconURL = [NSString stringWithFormat:@"%@%@",[story objectForKey:@"asset_base_url"],[story objectForKey:@"heart_icon"]];
                    
                    UIImage *colorHeartImage = [photoUtils getImageFromCache:colorHeartIconURL];
                    
                    UIButton *colorHeartbtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [colorHeartbtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
                    
                    [colorHeartbtn addTarget:self action:@selector(colorHeartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                    [colorHeartbtn setFrame:CGRectMake(Devicewidth - 32 - 18, yCoordinate+20, 32, 28)];
                    colorHeartbtn.tag = indexPath.row;
                    //colorHeartbtn.backgroundColor = [UIColor redColor];
                    [cell.contentView addSubview:colorHeartbtn];
                }
                
                [lblMilestoneWithoutImage setText:formattedTime];
                [lblMilestoneWithoutImage setTextAlignment:NSTextAlignmentRight];
                lblMilestoneWithoutImage.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                lblMilestoneWithoutImage.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                //lblMilestoneWithoutImage.backgroundColor = [UIColor redColor];
                [cell.contentView addSubview:lblMilestoneWithoutImage];
                
                lblMilestoneWithoutImageBelow.text = appendingString;
                [lblMilestoneWithoutImageBelow setTextAlignment:NSTextAlignmentRight];
                lblMilestoneWithoutImageBelow.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
                lblMilestoneWithoutImageBelow.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
                [cell.contentView addSubview:lblMilestoneWithoutImageBelow];
                
            }
            
            
        }
        
        
        if([[story objectForKey:@"schoolIamge"] length])
        {
            UIImageView *schoolImage = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-35, yPosition+5, 30, 30)];
            __weak UIImageView *weakSelf = schoolImage;
            
            [schoolImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[story objectForKey:@"schoolIamge"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [weakSelf setImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0]];
                 
             }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
            
            [cell.contentView addSubview:schoolImage];
            
        }
        else
        {
            [cell.contentView addSubview:topStripImage];
        }
#pragma mark - Tagged photos for Milestone
#pragma mark -
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[story objectForKey:@"tagged_to"]];
        int x = 0;
        int y=0;
        for(int i = 0,count =1; i < array.count; i++)
            //for(id dict in array)
        {
            
            id dict = [array objectAtIndex:i];
            NSString *url;
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
            [tagView addSubview:imagVw];
            
            [imagVw setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
            //add initials
            
            NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
            if([dict valueForKey:@"nickname"] != (id)[NSNull null] && [[dict valueForKey:@"nickname"] length] > 0)
            {
                [parentFnameInitial appendString:[[[dict valueForKey:@"nickname"] substringToIndex:1] uppercaseString]];
            }
            else
            {
                if([dict valueForKey:@"fname"] != (id)[NSNull null] && [[dict valueForKey:@"fname"] length] >0)
                    [parentFnameInitial appendString:[[[dict valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
                if([dict valueForKey:@"lname"] != (id)[NSNull null] && [[dict valueForKey:@"lname"] length]>0)
                    [parentFnameInitial appendString:[[[dict valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
            }
            
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                                   attributes:nil];
            NSRange range;
            if(parentFnameInitial.length > 0)
            {
                range.location = 0;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:17]}
                                        range:range];
            }
            if(parentFnameInitial.length > 1)
            {
                range.location = 1;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Light" size:17]}
                                        range:range];
            }
            
            
            //add initials
            
            UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            initial.attributedText = attributedText;
            [initial setBackgroundColor:[UIColor clearColor]];
            initial.textAlignment = NSTextAlignmentCenter;
            [imagVw addSubview:initial];
            
            //end add initials
            
            if([dict isKindOfClass:[NSDictionary class]])
                url  = [dict objectForKey:@"photograph"];
            else if([dict isKindOfClass:[NSString class]])
                url = dict;
            if(url != (id)[NSNull null] && url.length > 0)
            {
                UIImage *thumb = [photoUtils getImageFromCache:url];
                __weak UIImageView *weakSelf = imagVw;
                if (thumb == nil)
                {
                    // Fetch image, cache it, and add it to the tag.
                    [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                     {
                         [photoUtils saveImageToCache:url :image];
                         [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                         UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                         userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0];
                         [weakSelf addSubview:userImage];
                         [initial removeFromSuperview];
                     }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                     {
                         DebugLog(@"fail");
                     }];
                }
                else
                {
                    // Add cached image to the tag.
                    [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:thumb scaledToSize:CGSizeMake(30, 30)] withRadious:0];
                    [weakSelf addSubview:userImage];
                    [initial removeFromSuperview];
                }
                
            }
            
            x+= 32;
            if((i+1)%4 == 0)
            {
                x=0;
                y+=33;
                count++;
            }
        }
        
    }
    
    
    
    
    
    NSMutableDictionary *currentStory = [storiesArray objectAtIndex:indexPath.row];
    NSMutableDictionary *current_story_comment_details = [comment_details objectForKey:[currentStory objectForKey:@"kl_id"]];
    NSArray *commentsArray = [currentStory objectForKey:@"comments"];
    /*
     NSArray *commentsArray = [currentStory objectForKey:@"comments"];
     
     current_story_comment_details = [CommentsUtils getCommentDetails:currentStory comment_details:current_story_comment_details];
     [comment_details setValue:current_story_comment_details forKey:[currentStory objectForKey:@"kl_id"]];
     */
    
    NSString *showMoreButton = [current_story_comment_details objectForKey:@"showMoreButton"];
    int comments_shown = [[current_story_comment_details objectForKey:@"total_toshow"] intValue];
    
    
    //[singletonObj.comment_details setValue:[@(comments_shown) stringValue] forKey:[currentStory objectForKey:@"kl_id"]];
    
    CGSize expectedLabelSize;
    
    //if show more button
    if ([showMoreButton isEqualToString:@"true"])
    {
        UIButton *btnShowMore = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnShowMore addTarget:self action:@selector(showMoreCommentsTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btnShowMore setImage:[UIImage imageNamed:@"view_older_comments.png"] forState:UIControlStateNormal];
        [btnShowMore setImage:[UIImage imageNamed:@"view_older_comments_highlighted.png"] forState:UIControlStateSelected];
        btnShowMore.frame = CGRectMake(0, height, Devicewidth, 40);
        btnShowMore.tag = indexPath.row;
        [cell.contentView addSubview:btnShowMore];
        
        height += 40;
        
        UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, height, Devicewidth - 40, 0.5)];
        line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [line setTextAlignment:NSTextAlignmentLeft];
        line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        [cell.contentView addSubview:line];
        
        height += 5;
        
        //end buffer
        
        
    }
    else
    {
        
        //DM - adding a buffer between the comments and the text
        if(storyText.length > 0 || ([storyText length] > 0 || [[story objectForKey:@"new_title"] length] > 0))
            height += 20;
        
        UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, height, Devicewidth - 40, 0.5)];
        line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [line setTextAlignment:NSTextAlignmentLeft];
        line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        [cell.contentView addSubview:line];
        
        //end buffer
        height+=5;
        
    }
    
    int start = 0;
    if ([showMoreButton isEqualToString:@"true"])
    {
        start = (int)(commentsArray.count - comments_shown); //number total - number shown
    }
    
    float y = height;
    
    int i = 0;
    for (i = start; i < commentsArray.count; i++)
    {
        NSDictionary *dict = [commentsArray objectAtIndex:i];
        
        UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, 47, 47)];
        [imagVw setImage:[UIImage imageNamed:@"tag_thumbnail.png"]];
        //add initials
        NSString *nickname = [dict valueForKey:@"commented_by"];
        
        NSArray *nameArray = [nickname componentsSeparatedByString:@" "];
        
        NSString *firstName = [[nameArray.firstObject substringToIndex:1]uppercaseString];;
        NSString *lastName = [[nameArray.lastObject substringToIndex:1] uppercaseString];;
        
        
        NSMutableString *commenterInitial = [[NSMutableString alloc] init];
        [commenterInitial appendString:firstName];
        [commenterInitial appendString:lastName];
        
        NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
        
        NSRange range;
        if(firstName.length > 0)
        {
            range.location = 0;
            range.length = 1;
            [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Bold" size:20]}
                                              range:range];
        }
        if(lastName.length > 0)
        {
            range.location = 1;
            range.length = 1;
            [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Archer-Light" size:20]}
                                              range:range];
        }
        
        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
        initial.attributedText = attributedTextForComment;
        [initial setBackgroundColor:[UIColor clearColor]];
        initial.textAlignment = NSTextAlignmentCenter;
        [imagVw addSubview:initial];
        //end add initials
        
        __weak UIImageView *weakSelf = imagVw;
        DebugLog(@"*************%@",dict);
        NSString *url = [dict objectForKey:@"commenter_photo"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            // Fetch image, cache it, and add it to the tag.
            [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [photoUtils saveImageToCache:url :image];
                 
                 [weakSelf setImage:[UIImage imageNamed:@"tag_background.png"]];
                 UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 47, 47)];
                 userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(51, 51)] withRadious:0];
                 [weakSelf addSubview:userImage];
                 [initial removeFromSuperview];
             }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
             {
                 DebugLog(@"fail");
             }];
        }
        
        [cell.contentView addSubview:imagVw];
        
        NSString *nameText = [dict objectForKey:@"commented_by"];
        UILabel *nameLabel;
        if (nameText != (id)[NSNull null] && nameText.length > 0)
        {
            NSString *childName = [dict objectForKey:@"child_name"];
            NSString *childRelationship = [dict objectForKey:@"child_relationship"];
            NSString *relationText = @"";
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:11]};
            
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:nameText   attributes:attributes];
            
            if(childName != (id)[NSNull null] && childRelationship != (id)[NSNull null] && childName.length >0 && childRelationship.length >0)    {
                
                relationText = [NSString stringWithFormat:@" %@'s %@",childName,childRelationship];
                NSAttributedString *relationAttribute = [[NSAttributedString alloc] initWithString:relationText attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:10]}];

                [attributedString appendAttributedString:relationAttribute];
                
            }
            

            
            
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(77,y+2,130,12)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setAttributedText:attributedString];
            [nameLabel setNumberOfLines:0];
            [cell.contentView addSubview:nameLabel];
            
        }

        
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(Devicewidth - 130 - 20,y+2,130,12)];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        
        NSString *milestoneDate = [dict objectForKey:@"created_at"];
        NSString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:milestoneDate actualTimeZone:[story objectForKey:@"tzone"]] mutableCopy];;
        
        [dateLabel setText:formattedTime];
        [dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10]];
        [dateLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
        [dateLabel setNumberOfLines:0];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        [cell.contentView addSubview:dateLabel];
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]};
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"content"]   attributes:attributes];
        NIAttributedLabel *textView = [NIAttributedLabel new];
        textView.numberOfLines = 0;
        textView.delegate = self;
        textView.autoDetectLinks = YES;
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        textView.attributedText = attributedString;
        [cell.contentView addSubview:textView];
        
        expectedLabelSize = [textView sizeThatFits:CGSizeMake(Devicewidth - 77 - 20, 9999)];
        textView.frame =  CGRectMake(77, y+14, Devicewidth - 77 - 20, expectedLabelSize.height);
        
#pragma mark hidden comment
        if ([[dict objectForKey:@"unknown_commenter"] boolValue] == YES)
        {
            attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13]};
            attributedString = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"content"]   attributes:attributes];
            textView.attributedText = attributedString;
            [textView setAlpha:0.4f];
            [dateLabel setAlpha:0.4f];
            [nameLabel setAlpha:0.4f];
            [weakSelf setAlpha:0.4f];
        }
        
        if(textView.frame.size.height+14 > 47)
            y+=expectedLabelSize.height+5+14;
        else
            y+=47+5;
        
        
        UILabel *line = [[UILabel alloc] initWithFrame: CGRectMake(20, y, Devicewidth - 40, 0.5)];
        line.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [line setTextAlignment:NSTextAlignmentLeft];
        line.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
        [cell.contentView addSubview:line];
        
        y+=5;
        
        
    }
    
#pragma mark - Add Heart button and comments and post options
#pragma mark -
    
    UIButton *addHeartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addHeartBtn addTarget:self action:@selector(heartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    // isHeartSelected = [[dict objectForKey:@"hearted"] boolValue];
    
    if([[story objectForKey:@"hearted"] boolValue] == NO)
    {
        [addHeartBtn setImage:[UIImage imageNamed:@"HeardIconGray.png"] forState:UIControlStateNormal];
    }
    else
    {
        [addHeartBtn setImage:[UIImage imageNamed:@"HeardIconDark.png"] forState:UIControlStateNormal];
    }
    [addHeartBtn setFrame:CGRectMake(18.5, y+11, 24, 22)];
    addHeartBtn.tag = indexPath.row;
    [cell.contentView addSubview:addHeartBtn];
    if([[story objectForKey:@"local_change"] boolValue])
        addHeartBtn.userInteractionEnabled = NO;
    else
        addHeartBtn.userInteractionEnabled = YES;
    
    
    UIImageView *msgImage = [[UIImageView alloc] initWithFrame:CGRectMake(63, y+11.5, 29,21)];
    [msgImage setImage:[UIImage imageNamed:@"message_icon.png"]];
    [cell.contentView addSubview:msgImage];
    
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(98,y,60,44)];
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    [commentLabel setText:@"Comment"];
    [commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [commentLabel setTextColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1]];
    [commentLabel setNumberOfLines:0];
    [cell.contentView addSubview:commentLabel];
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setFrame:CGRectMake(67, y, 100, 44)];
    commentBtn.tag = indexPath.row;
    //[commentBtn setBackgroundColor:[UIColor redColor]];
    [commentBtn addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:commentBtn];
    
    // MARK:Drop down
    UIImageView *dropDownImage = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth - 32 - 19, y+17.5, 32,9)];
    dropDownImage.image = [UIImage imageNamed:@"white_arrow_down_icon.png"];
    
    UIButton *dropDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropDownButton setFrame:CGRectMake(Devicewidth - 85, y, 85,44)];
    //[dropDownButton setImage:[UIImage imageNamed:@"white_arrow_down_icon.png"] forState:UIControlStateNormal];
    [dropDownButton setTag:indexPath.row];
    
    [dropDownButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[story valueForKey:@"can_delete"] boolValue] || [[story valueForKey:@"untag"] boolValue] || [[story valueForKey:@"can_download"] boolValue])
    {
        [cell.contentView addSubview:dropDownImage];
        [cell.contentView addSubview:dropDownButton];
        
    }
    
#pragma mark - bottom line after add comment section
#pragma mark -
    
    //bottom line is 1 point above bottom of comment button
    UIImageView *bottomLineImageAfter = [[UIImageView alloc] initWithFrame:CGRectMake(0, y + 49, Devicewidth, .5)];
    
    
    [cell.contentView addSubview:bottomLineImageAfter];
    bottomLineImageAfter.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    return cell;
    
}
#pragma mark - Color Heart button Action
#pragma mark -

-(void)colorHeartBtnAction:(UIButton *)sender
{
    [self.delegate heartersClick:(int)[sender tag]];
}

#pragma mark - Add Heart button Action
#pragma mark -

-(void)heartBtnAction:(UIButton *)sender
{
    //This Bool(isHeartButtonTapped) is used to temporarily disable/enable the auto refresh when user tapped on the heart symbol.
    [singletonObj setIsHeartButtonTapped:YES];
    
    BOOL isHeartStatus = [[[storiesArray objectAtIndex:[sender tag]] objectForKey:@"hearted"] boolValue];
    NSString *command = @"";
    NSMutableDictionary *dict = [[self.storiesArray objectAtIndex:[sender tag]] mutableCopy];
    if  (isHeartStatus == YES)
    {
        command = @"remove_heart";
        //isHeartSelected = NO;
        [dict setObject:[NSNumber numberWithBool:NO]  forKey:@"hearted"];

    }
    else
    {
        command = @"add_heart";
        //isHeartSelected = YES;
        [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"hearted"];

    }
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"local_change"];
    
    [self.storiesArray replaceObjectAtIndex:[sender tag] withObject:dict];
    
    [streamTableView beginUpdates];
    [streamTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[sender tag] inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    [streamTableView endUpdates];
    
    [self.delegate addHeartClick:(int)[sender tag] withCommand:command];
    
}

-(void)showMoreCommentsTapped:(id) sender
{
    //find the kl id and add to it
    UIButton *button = sender;
    button.selected = YES;
    [self performSelector:@selector(showMoreCcomments:) withObject:sender afterDelay:0.1];
}
-(void)showMoreCcomments:(id)sender
{
    UIButton *button = (UIButton*) sender;
    int kl_int = (int)button.tag;
    NSMutableDictionary *currentStory = [storiesArray objectAtIndex:kl_int];
    NSMutableDictionary *comments_details = [comment_details objectForKey:[currentStory objectForKey:@"kl_id"]];
    
    [comments_details setValue:@"true" forKey:@"show_more_clicked"];
    [comment_details setValue:comments_details forKey:[currentStory objectForKey:@"kl_id"]];
    [streamTableView reloadData];

}
-(void) launchFirstPost
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AddStory" object:nil];
}

-(void) launchFamilyProfile
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GoToFamily" object:nil];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (bProcessing) return;
    isDragging = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate tableScrolled:scrollView.contentOffset.y];
    
    if (bProcessing) return;
    if(isDragging && !bProcessing)
    {
        [UIView beginAnimations:nil context:NULL];
        float heightRefresh;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            if (scrollView.contentOffset.y < -2*REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
                refreshLabel.text = @"Release to refresh";
            } else { // User is scrolling somewhere within the header
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                refreshLabel.text = @"Pull down to refresh";
            }
            
            [UIView commitAnimations];
            
            heightRefresh = 2*REFRESH_HEADER_HEIGHT;
            
        }
        else{
            
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
                refreshLabel.text = @"Release to refresh";
            } else { // User is scrolling somewhere within the header
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                refreshLabel.text = @"Pull down to refresh";
            }
            
            [UIView commitAnimations];
            heightRefresh = REFRESH_HEADER_HEIGHT*0.7;
        }
        
        
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 15;
    if(y > h + reload_distance)
    {
        if(isMoreAvailabel)
        {
            [self.activityIndicator startAnimating];
            [self callStoresApi:@"next"];
        } 
    }

 /*
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - 400)
    {
        // ask next page only if we haven't reached last page
        if(isMoreAvailabel)
        {
            [self.activityIndicator startAnimating];
            
            [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
            
            // fetch next page of results
        }
    }
  */
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    /*
     
     if (bProcessing) return;
     isDragging = NO;
     if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT)
     {
     // Released above the header
     
     streamTableView.tableHeaderView = refreshHeaderView;
     refreshLabel.text = @"Updating";
     refreshArrow.hidden = YES;
     [self.headActivityIndicator startAnimating];
     if([storiesArray count] >0 )
     [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"prev"];
     else
     [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
     }
     */
}

- (void)fetchNextPage
{
    [self.activityIndicator startAnimating];
    [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
}

-(void)loadMore:(id)sender
{
    [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
    
}
- (void)readArticleButtonTapped:(UIButton *)sender
{
    NSString *readArticleURL = [[storiesArray objectAtIndex:[sender tag]] objectForKey:@"article_url"];
    if (readArticleURL.length>0)
    {
        //Tracking
        
        [self.delegate readArticleClicked:readArticleURL];
    }
}

-(void)commentBtnAction:(id)sender
{
    //Tracking
    
    [self.delegate commentClick:(int)[sender tag]];
}
- (void)readArticleClicked:(id)sender
{
    [self.delegate commentClick:(int)[sender tag]];
}
-(void)closeButtonTapped:(id)sender
{
    [fullScreenView removeFromSuperview];
}
-(void)deleteClick:(id)sender
{
    deleteIndex = (int)[sender tag];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        NSDictionary *dict = [storiesArray objectAtIndex:deleteIndex];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] init];
        //  Fixed the Share to Facebook option for Moment or Milestone.
        NSString *post_type = [dict objectForKey:@"post_type"];
        if (([post_type isEqualToString:@"Story"] ||[post_type isEqualToString:@"Story"]) && ( [[dict objectForKey:@"weight"] intValue] == 0 && [[dict objectForKey:@"height"] intValue] == 0))
        {
            
            if ([[dict valueForKey:@"can_delete"] boolValue])
            {
                
                NSArray *array = [dict objectForKey:@"images"];
                
                NSString *expression=[NSString stringWithFormat:@"SELF contains '%@'",@".gif"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:expression];
                NSMutableArray *mArrayFiltered = [[array filteredArrayUsingPredicate:predicate] mutableCopy];

                
                if(mArrayFiltered.count != array.count)
                {
                
                UIAlertAction *shareByEmail=[UIAlertAction actionWithTitle:@"Share by email" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    //action on click
                    
                    NSDictionary *dict = [self.storiesArray objectAtIndex:deleteIndex];
                    NSString *storyText = [dict objectForKey:@"text"];
                    
                    //remove the kl_ids here for the items
                    storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
                    
                    
                    [self shareByMail:[[dict objectForKey:@"large_images"] lastObject] :[dict objectForKey:@"new_title"] :storyText];

                    
                    
                }];
                [alertController addAction:shareByEmail];
                }
                UIAlertAction *editPost =[UIAlertAction actionWithTitle:@"Edit post" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    //action on click
                    
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    AddPostViewController *post = [storyBoard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
                    post.steamDisplayView = self;
                    post.index = 1;
                    //post.profileId = profileID;
                    self.editIndex = deleteIndex;
                    post.detailsDictionary = [self.storiesArray objectAtIndex:deleteIndex];
                    if ([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
                    {
                        [(ProfileKidsTOCV2ViewController *)self.delegate setIsKidTocView:YES];
                        [[(ProfileKidsTOCV2ViewController *)self.delegate navigationController] pushViewController:post animated:YES];
                    }
                    

                    
                }];
                [alertController addAction:editPost];
                
            }
        }
        if([[dict valueForKey:@"can_delete"] boolValue] )
        {
            UIAlertAction *editPost =[UIAlertAction actionWithTitle:@"Delete post" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                //action on click
                
                UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Sure you want to delete this post?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
                
                [cautionAlert setTag:9988];
                
                self.globalAlert = cautionAlert;
                
                [cautionAlert show];
                
            }];
            [alertController addAction:editPost];

        }
        
       
        /*  if(![[dict valueForKey:@"can_delete"] boolValue] )
         {
         [addImageActionSheet addButtonWithTitle:@"Flag as inappropriate"];
         }
         */
        
        
        UIAlertAction *cancel_action=[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancel_action];
        
        
        // Remove arrow from action sheet.
        [alertController.popoverPresentationController setPermittedArrowDirections:0];
        //For set action sheet to middle of view.
        CGRect rect = self.frame;
        rect.origin.x = self.frame.size.width / 20;
        rect.origin.y = self.frame.size.height / 20;
        alertController.popoverPresentationController.sourceView = self;
        alertController.popoverPresentationController.sourceRect = rect;
        
        [(ProfileKidsTOCV2ViewController*)delegate presentViewController:alertController animated:YES completion:nil];
        
    }
    else {
        
        
        NSDictionary *dict = [storiesArray objectAtIndex:deleteIndex];
        
        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] init];
        //  Fixed the Share to Facebook option for Moment or Milestone.
        NSString *post_type = [dict objectForKey:@"post_type"];
        if (([post_type isEqualToString:@"Story"] ||[post_type isEqualToString:@"Story"]) && ( [[dict objectForKey:@"weight"] intValue] == 0 && [[dict objectForKey:@"height"] intValue] == 0))
        {
            if ([[dict valueForKey:@"can_delete"] boolValue]) //must have delete permissions
            {
                //            [addImageActionSheet addButtonWithTitle:@"Share to Facebook"];
                //            [addImageActionSheet addButtonWithTitle:@"Share to Instagram"];
                
                NSArray *array = [dict objectForKey:@"images"];
                
                NSString *expression=[NSString stringWithFormat:@"SELF contains '%@'",@".gif"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:expression];
                NSMutableArray *mArrayFiltered = [[array filteredArrayUsingPredicate:predicate] mutableCopy];
                
                
                if(mArrayFiltered.count != array.count || array.count == 0)
                    [addImageActionSheet addButtonWithTitle:@"Share by email"];
                [addImageActionSheet addButtonWithTitle:@"Edit post"];
            }
        }
        if([[dict valueForKey:@"can_delete"] boolValue] )
        {
            [addImageActionSheet addButtonWithTitle:@"Delete post"];
        }
     
        
        if([[dict objectForKey:@"untag"] boolValue])
        {
            [addImageActionSheet addButtonWithTitle:@"Remove tag"];
        }
        /*  if(![[dict valueForKey:@"can_delete"] boolValue] )
         {
         [addImageActionSheet addButtonWithTitle:@"Flag as inappropriate"];
         }
         */
        addImageActionSheet.cancelButtonIndex = [addImageActionSheet addButtonWithTitle:@"Cancel"];
        addImageActionSheet.tag = 1;
        [addImageActionSheet setDelegate:self];
        [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

        
        
    }

}
#pragma mark- FacebookPostedConfirmation Delegate Methods
#pragma mark-
- (void)showFacebookSuccessPopup
{
    
}
- (void)showFacebookSuccessPopup:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FACEBOOK_SUCCESS" object:nil];
    
    if([[notification.userInfo objectForKey:@"Success"] boolValue])
    {
        UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"Item Posted to Facebook" message:@"Invite more friends to share on KidsLink?" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Invite", nil];
        
        [successAlert setTag:998877];
        
        self.globalAlert = successAlert;
        
        [successAlert show];
    }
}
#pragma mark- UIActionSheet Delegate Methods
#pragma mark-
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Delete post"])
    {
        UIAlertView *cautionAlert = [[UIAlertView alloc]initWithTitle:@"Sure you want to delete this post?" message:@"" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        
        [cautionAlert setTag:9988];
        
        self.globalAlert = cautionAlert;
        
        [cautionAlert show];
        
    }
    else if([title isEqualToString:@"Remove tag"])
    {
        [self performSelectorInBackground:@selector(CallUntagApi) withObject:nil];
        
    }
    else if([title isEqualToString:@"Edit post"])
    {
       
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddPostViewController *post = [storyBoard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
        post.steamDisplayView = self;
        post.index = 1;
        //post.profileId = profileID;
        self.editIndex = deleteIndex;
        post.detailsDictionary = [self.storiesArray objectAtIndex:deleteIndex];
        if ([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
        {
            [(ProfileKidsTOCV2ViewController *)self.delegate setIsKidTocView:YES];
            [[(ProfileKidsTOCV2ViewController *)self.delegate navigationController] pushViewController:post animated:YES];
        }
        
    }
    else if([title isEqualToString:@"Flag as inappropriate"])
    {
        NSDictionary *dict = [self.storiesArray objectAtIndex:deleteIndex];
        NSString *itemDate = [dict objectForKey:@"created_at"];
        NSString *itemId = [dict objectForKey:@"kl_id"];
        
        NSString *emailId = [NSString stringWithFormat:@"%@ %@", itemDate, itemId];
        NSString *emailIdBase64 = [emailId base64EncodedString];
        
        NSString *bodyText = [NSString stringWithFormat:@"Dear Tingr,\r\n\r\nPlease review the content for a post item dated %@ for inappropriate content.\r\n\r\n[So we can identify the content, please do not change the text between the two lines below, which represents the unique identifier for the content.  However, feel free to provide additional information above these lines for our review.]\r\n\r\n---------------------\r\n%@\r\n---------------------",itemDate, emailIdBase64];
        
        NSMutableDictionary *emailData = [[NSMutableDictionary alloc] init];
        [emailData setValue:@"Inappropriate content" forKey:@"subject"];
        [emailData setValue:bodyText forKey:@"body"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"FLAG" object:nil userInfo:emailData];
        
    }
    else if([title isEqualToString:@"Share to Facebook"])
    {
        if(singletonObj.isFBShareEnabled == 1)
        {
       /*     // have access
            DebugLog(@"FB have access");
            
            // check whether native facebook app is installed or not
            //BOOL isFBInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
            //if (isFBInstalled)
            //{
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            fbc.postedConfirmationDelegate = self;
            NSDictionary *dict = [self.storiesArray objectAtIndex:deleteIndex];
            NSString *post_type = [dict objectForKey:@"post_type"];
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(showFacebookSuccessPopup:)
             name:@"FACEBOOK_SUCCESS"
             object:nil];
            
             [Flurry logEvent:@"Stream_Social_FB"];
            
            if ([post_type isEqualToString:@"Story"])
            {
                NSString *storyText = [dict objectForKey:@"text"];
                
                //remove the kl_ids here for the items
                storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
                
                NSString *description = [NSString stringWithFormat:@"%@",storyText];
                NSString *image = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fb_url"]];
                [fbc PostToFacebookViaAPI:image:@"":description:@"moment"];
            }
            else if ([post_type isEqualToString:@"Story"])
            {
                NSString *milestoneImage = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fb_url"]];
                // title
                //NSString *milestoneTitle = [NSString stringWithFormat:@"%@",[dict objectForKey:@"new_title"]];
                NSString *milestoneCreatedDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"created_at"]];
                NSString *milestoneNewDate = @"";
                if (milestoneCreatedDate != (id)[NSNull null] && milestoneCreatedDate.length > 0)
                {
                    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                    // To know the Device time format:
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    
                    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                    [formatter1 setLocale:enUSPOSIXLocale];
                    
                    [formatter1 setDateFormat:@"MM/dd/yyyy hh:mmaZZZ"];
                    
                    NSDate *date = [formatter1 dateFromString:milestoneCreatedDate];
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    milestoneNewDate = [formatter stringFromDate:date];
                    //milestoneTitle = [milestoneTitle stringByAppendingString:[NSString stringWithFormat:@" %@",milestoneNewDate]];
                }
                
                NSString *storyText = [dict objectForKey:@"text"];
                //remove the kl_ids here for the items
                NSString *description = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
 
                if (![description isEqualToString:@""])
                {
                    description = [NSString stringWithFormat:@"%@: %@",
                                   [dict objectForKey:@"new_title"],
                                   description];
                }
                else
                {
                    description = [dict objectForKey:@"new_title"];
                }
               
                
                [fbc PostToFacebookViaAPI:milestoneImage:@"":description:@"Story"];
            }
        
        */
        }
        else
        {
            // Access denied.
            DebugLog(@"FB Access denied.");
            UIAlertView *fbComingSoonAlert = [[UIAlertView alloc]initWithTitle:@"Facebook temporarily unavailable. Try again later."  message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            self.globalAlert = fbComingSoonAlert;
            
            [fbComingSoonAlert show];
        }
        
    }
    else if([title isEqualToString:@"Share by email"])
    {
        NSDictionary *dict = [self.storiesArray objectAtIndex:deleteIndex];
        NSString *storyText = [dict objectForKey:@"text"];
        
        //remove the kl_ids here for the items
        storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
        
        
        [self shareByMail:[[dict objectForKey:@"large_images"] lastObject] :[dict objectForKey:@"new_title"] :storyText];
        
    }
    else if([title isEqualToString:@"Share to Instagram"])
    {
       /*
        NSDictionary *dict = [self.storiesArray objectAtIndex:deleteIndex];
        
        if([dict objectForKey:@"image"] != (id)[NSNull null] && [[dict objectForKey:@"image"] length] >0)
        {
            if ([MGInstagram isAppInstalled])
            {
                [Flurry logEvent:@"Stream_Social_IG"];
                NSString *storyText = [dict objectForKey:@"text"];

                //remove the kl_ids here for the items
                storyText = [TaggingUtils formatAttributedStringFromServerDoubleTags:storyText];
                
                [self downLoadImageForInstagram:[dict objectForKey:@"large_image"]: storyText];
                
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE
                                                               message:INSTAGRAM_ALERT_BODY_INSTALL
                                                              delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                                      
                                                     otherButtonTitles:nil,nil];
                self.globalAlert = alert;
                
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE_SHARE_NOPHOTO_IN_STREAMS
                                                           message:INSTAGRAM_ALERT_BODY_SHARE_NOPHOTO_IN_STREAMS
                                                          delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                                  
                                                 otherButtonTitles:nil,nil];
            self.globalAlert = alert;
            
            [alert show];
        }
        */
    }
}

#pragma mark- UIAlertView Delegate Methods
#pragma mark-
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Delete Caution Alert
    if (alertView.tag == 9988)
    {
        if (buttonIndex == 0)
        {
            // Delete
            deleteDict = [self.storiesArray objectAtIndex:deleteIndex];
            [self.storiesArray removeObjectAtIndex:deleteIndex];
            if(!isFromFriends && profileID.length == 0)
            {
                NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:storiesArray];
                [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"streamArray"];
            }
            [self.streamTableView reloadData];
            isDeletingProcessed = YES;
            [self performSelectorInBackground:@selector(callDeleteApi) withObject:nil];
        }
        else if (buttonIndex == 1)
        {
            // Cancel
        }
    }
    
    // Facebook Success
    if (alertView.tag == 998877)
    {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
        if (buttonIndex == 0)
        {
            // Not Now
        }
        else if (buttonIndex == 1)
        {

            /*
            // Invite
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            
            aboutPopup = [[AboutFriendSharing alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
            aboutPopup.delegate = self;
            [[[[UIApplication sharedApplication] delegate] window] addSubview:aboutPopup];
             
             */
        }
    }
    //
}

//call Invite Friends flow
#pragma mark- AboutFriendSharing Delegate
#pragma mark-
- (void)friendSharing:(long int )userResponse
{
    
 /*   if(userResponse == 1)
    {
        if([[[SingletonClass sharedInstance] profileKids] count] == 0)
        {
            //put alert here
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                           message:@"You must add a child before inviting a parent."
                                                          delegate:nil cancelButtonTitle:@"Ok"
                                  
                                                 otherButtonTitles:nil,nil];
            self.globalAlert = alert;
            
            [alert show];
            return;
            
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProfileParentInviteViewController *contactView = [storyBoard instantiateViewControllerWithIdentifier:@"ProfileParentInviteViewController"];
        if([self.delegate isKindOfClass:[StreamHomeViewController class]])
        {
            [[(StreamHomeViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
        if ([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
        {
            [[(ProfileKidsTOCV2ViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
        if ([self.delegate isKindOfClass:[ProfileParentsTOCV2ViewController class]])
        {
            [[(ProfileParentsTOCV2ViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
    }
    if(userResponse == 2)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FriendsContactsViewController *contactView = [storyBoard instantiateViewControllerWithIdentifier:@"FriendsContactsViewController"];
        if([self.delegate isKindOfClass:[StreamHomeViewController class]])
        {
            contactView.isFromStreamFBInvite = YES;
            [[(StreamHomeViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
        if ([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
        {
            contactView.isFromStreamFBInvite = YES;
            [[(ProfileKidsTOCV2ViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
        if ([self.delegate isKindOfClass:[ProfileParentsTOCV2ViewController class]])
        {
            contactView.isFromStreamFBInvite = YES;
            [[(ProfileParentsTOCV2ViewController *)self.delegate navigationController] pushViewController:contactView animated:YES];
        }
    }
    [aboutPopup removeFromSuperview];

  */
}
//call Invite Friends flow end

-(void)callDeleteApi
{
  
    [[SingletonClass sharedInstance] setIsPostDeleted:YES];
    SharingCheck *sharingCheck = [[SharingCheck alloc] init];
    [sharingCheck setDelegate:self];
    [sharingCheck deletePost:[deleteDict objectForKey:@"kl_id"]];
    
}
- (void)responseForSharing:(NSDictionary *)body
{
    isDeletingProcessed = NO;
}
- (void)errorForSharing
{
    isDeletingProcessed = NO;
}
#pragma mark - ASMediaFocusDelegate
- (UIImageView *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageViewForView:(UIView *)view
{
    return (UIImageView *)view;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameForView:(UIView *)view
{
    return [[(UIViewController *)self.delegate view] bounds];
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return (UIViewController *)self.delegate;
}

- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    
    UITableViewCell *cell = (UITableViewCell *)[[view superview] superview];
    NSIndexPath *indexPath = [streamTableView indexPathForCell:cell];

    NSURL *url;
    NSDictionary *dict = [storiesArray objectAtIndex:indexPath.row];
    NSString *originalImage = [NSString stringWithFormat:@"%@",[dict objectForKey:@"large_images"][view.tag]];
    DebugLog(@"originalImage:%@",originalImage);
    if (originalImage != (id)[NSNull null] && originalImage.length > 0)
    {
        url = [NSURL URLWithString:originalImage];
    }
    return url;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view;
{
    return @"";
}

- (void)mediaFocusManagerWillAppear:(ASMediaFocusManager *)mediaFocusManager
{
    isFullScreen = YES;
    
     if([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
    {
        ProfileKidsTOCV2ViewController *vc = (ProfileKidsTOCV2ViewController *)self.delegate;
        vc.statusBarHidden = YES;
        if([(ProfileKidsTOCV2ViewController*)self.delegate respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {
            [(ProfileKidsTOCV2ViewController *)self.delegate  setNeedsStatusBarAppearanceUpdate];
        }
    }
    
}

- (void)mediaFocusManagerWillDisappear:(ASMediaFocusManager *)mediaFocusManager
{
    isFullScreen = NO;
}

- (void)mediaFocusManagerDidDisappear:(ASMediaFocusManager *)mediaFocusManager
{
     if([self.delegate isKindOfClass:[ProfileKidsTOCV2ViewController class]])
    {
        ProfileKidsTOCV2ViewController *vc = (ProfileKidsTOCV2ViewController *)self.delegate;
        vc.statusBarHidden = NO;
        if([(ProfileKidsTOCV2ViewController*)self.delegate respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {
            [(ProfileKidsTOCV2ViewController *)self.delegate  setNeedsStatusBarAppearanceUpdate];
        }
    }
    
}

- (void) statusBarHit
{
    if(isFullScreen == NO)
        [streamTableView setContentOffset:CGPointZero animated:YES];
}

-(void)downLoadImagewithUrl:(NSArray *)imagesArray
{
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    dnView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, Devicewidth, 20)];
    UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 8, Devicewidth - 20, 10)];
    progress.progress = 0.0;
    [dnView setBackgroundColor:[UIColor lightGrayColor]];
    [tempWindow addSubview:dnView];
   // [dnView addSubview:progress];
    
    for(NSString *url in imagesArray)
    {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:url];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        progress.progress = (float)totalBytesRead / totalBytesExpectedToRead;
    }];
    
    [operation setCompletionBlock:^{
        
        
        if([url containsString:@".mp4"])
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                libraryFolder = [[ALAssetsLibrary alloc] init];
            [libraryFolder addAssetsGroupAlbumWithName:@"TingrSCHOOL" resultBlock:^(ALAssetsGroup *group)
             {
             } failureBlock:^(NSError *error)
             {
             }];
            [libraryFolder writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath] completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 
                 [libraryFolder addAssetURL:assetURL toAlbum:@"TingrSCHOOL" withCompletionBlock:^(NSError *error) {
                     
                 }];

             }];

          });
        }
        else
        {
        UIImage *image;
        
        
        image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[dnView removeFromSuperview];
            NSArray *subViewArray = [tempWindow subviews];
            for (id obj in subViewArray)
            {
                [obj removeFromSuperview];
            }
            
            libraryFolder = [[ALAssetsLibrary alloc] init];
            [libraryFolder addAssetsGroupAlbumWithName:@"TingrSCHOOL" resultBlock:^(ALAssetsGroup *group)
             {
             } failureBlock:^(NSError *error)
             {
             }];
            
            [libraryFolder saveImage:image toAlbum:@"TingrSCHOOL" withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                }
            }];
        });
        }
        
    }];
    [operation start];
        
    }
}

-(void)downLoadImageForInstagram:(NSString *)url :(NSString *)message
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Instagram_Image"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setCompletionBlock:^{
        
        UIImage *image;
        
        image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [sharedInstance setIsInstagramShareEnabled:FALSE];
            NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
            [popData setValue:message forKey:@"attachedMessage"];
            [popData setValue:image forKey:@"attachedImage"];
            
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"POST_TO_INSTAGRAM" object:nil userInfo:popData];
            
        });
        
        
    }];
    [operation start];
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if (result.resultType == NSTextCheckingTypeLink) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
}

//This sets all of the stream items back to the default number of comments
//the comment details are used to keep number of comments to show per stream item
-(void)clearCommentDetails
{
    [comment_details removeAllObjects];
}
#pragma mark -
#pragma mark Email Methods
-(void)shareByMail:(NSString *)url :(NSString *)title :(NSString *)description
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Mail_Image"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setCompletionBlock:^{
        
        UIImage *image;
        
        image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:filePath]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self displayMailComposerSheet:image :title :description];
        });
        
        
    }];
    [operation start];
}
- (void)displayMailComposerSheet:(UIImage *)selectedImage :(NSString *)title :(NSString *)description
{
    if([MFMailComposeViewController canSendMail])
    {
        mailComposer= [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:@"TingrSCHOOL"];
        
        ///////Attaching image//////////
        if(selectedImage != nil)
        {
            NSData *imageData;
            imageData = UIImagePNGRepresentation(selectedImage);
            [mailComposer  addAttachmentData:imageData mimeType:@"image/png" fileName:@"photo"];
        }
        
        //////Attaching Description
        
        NSMutableString *attachText = [NSMutableString string];
        if(title.length > 0)
        {
            [attachText appendString:title];
            [mailComposer setSubject:[NSString stringWithFormat:@"Tingr moment: %@",title]];
            
        }
        else
        {
            [mailComposer setSubject:@"View my Tingr moment"];
        }
        if(description.length > 0)
        {
            [attachText appendString:@"\n"];
            [attachText appendString:description];
        }
        
        //
        //        NSString *styles = @"<style type='text/css'>body { font-family: 'HelveticaNeue-Light'; font-size: 20px; color: #7b7a7a; margin: 0; padding: 0; }</style>";
        //        NSString *htmlMsg = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>",styles,attachText];
        [mailComposer setMessageBody:attachText isHTML:NO];
        
        mailComposer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [(UIViewController *)self.delegate presentViewController:mailComposer animated:YES completion:^{
            
        }];
    }
    else
    {
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:@"Mail client not configured on this device. Add a mail account in your device Settings to send an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.globalAlert = alert;
        [alert show];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString *messageStr = nil;
    switch (result){
            
        case MFMailComposeResultSaved:; //Mail is saved
            messageStr = @"Email saved successfully";
            break;
            
        case MFMailComposeResultSent:; //Mail is sent
            messageStr = @"Email sent successfully";
            break;
            
            
        case MFMailComposeResultFailed:;    //Mail sending id failed.
            //messageStr = @"Email sending failed";
            break;
            
        case MFMailComposeResultCancelled: break; //If we click on the cancle.
            
        default: break;
            
    }
    [(UIViewController *)self.delegate dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled )
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"TingrSCHOOL" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.globalAlert = alert;
        [alert show];
    }
    
}

-(void)playButtonTapped:(UIButton *)button {
    
    UITableViewCell *cell = (UITableViewCell *)[[button superview] superview];
    NSIndexPath *indexPath = [streamTableView indexPathForCell:cell];
    
   
    NSDictionary *dict = [storiesArray objectAtIndex:indexPath.row];
    NSString *originalImage = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"large_images"] objectAtIndex:button.tag]];
    NSURL *url = [NSURL URLWithString:originalImage];
    
    VideoPlayer *videoPLayer = [VideoPlayer alloc];
    videoPLayer.url = url;
    videoPLayer = [videoPLayer initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:videoPLayer];

}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
