//
//  SingletonClass.h
//  mIOSKidsLink
//
//  Created by Maisa Solutions on 3/7/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <UIKit/UIKit.h>
@class AFHTTPRequestOperation;

@interface SingletonClass : NSObject
{
    
}

@property (strong, nonatomic) NSString *addKidPhotoId;
//@property (strong, nonatomic) NSMutableArray *arrayKidNickNames;
//@property (strong, nonatomic) NSMutableArray *arrayKid_id;
// For Profile 
@property (strong, nonatomic) NSMutableArray *profileKids;
@property (strong, nonatomic) NSMutableArray *profileParents;
@property (strong, nonatomic) NSMutableArray *allProfileParents;
@property (strong, nonatomic) NSMutableDictionary *profileOnboarding;
        // For Documents
@property (strong, nonatomic) NSMutableArray *sortedParentKidDetails;
@property (strong, nonatomic) NSMutableArray *sortedKidDetails;
@property (strong, nonatomic) NSMutableArray   *arrayShowProfiles;
@property (strong, nonatomic) NSString          *whoseProfileId;
@property (strong, nonatomic) NSString          *whoseCategoryId;
@property (strong, nonatomic) NSMutableArray    *whoseDocumentCaptureIds;
@property (nonatomic, strong) NSString *selectedProfileid;
@property (nonatomic, strong) NSString *onboarding_tour;
@property (nonatomic, strong) NSMutableDictionary *selecteOrganisation;
@property (nonatomic, strong) NSMutableDictionary *selecteRoom;

//@property (strong, nonatomic) NSMutableArray *arrayDocumentsList;
//@property (nonatomic, retain) UINavigationController *mainNavigatinCtrl;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) NSString *notificationCount;
@property (nonatomic, strong) NSString *messageCount;
@property BOOL isPending;
@property BOOL isImageUploadSuccess;
@property BOOL isFromProfile;
@property BOOL isAddFirstChild;
@property BOOL isInKidsTOC;
@property BOOL isPostFromFirstAddedChild;
@property (nonatomic) int pickedImagesCount;
@property (nonatomic) int totalImages;
//@property (strong, nonatomic) NSString *profileParentPhotograph;
@property (strong, nonatomic) NSString *stringName;
@property (nonatomic, strong) NSString *customCategory;


@property (nonatomic, strong) NSMutableArray *deletedDocumentId;
@property (nonatomic, strong) NSMutableArray *editedDocumentId;
@property (strong, nonatomic) NSMutableArray *arrayKidsLinkUsers;

@property (nonatomic) BOOL isSwitchPersonChanged;
@property (strong, nonatomic) NSMutableDictionary *switchPersonDetails;
@property (nonatomic) BOOL isStreamsDownloaded;
@property (nonatomic) int streamCallCount;
@property (nonatomic) BOOL canShowDocument;
@property (nonatomic) BOOL isFBShareEnabled;
@property (nonatomic) BOOL isInstagramShareEnabled;
@property (nonatomic) BOOL isFromGetInvite;
@property (nonatomic) BOOL isChildAdded;
@property (nonatomic, strong) NSDictionary *lastPost; //last stream item posted
@property (nonatomic, strong) NSDictionary *lastPostId;


@property (nonatomic, retain) UIImage *attachedImageForInstagram;
@property (nonatomic, retain) NSString *attachedMessageForInstagram;
@property (nonatomic, strong) NSString *firstKidFirstPostKL_id;
@property (nonatomic) BOOL isFirstKidFirstPost;
@property (nonatomic) BOOL isFaceBookChecked;
@property (nonatomic) BOOL isInstagramChecked;

// To force refresh when post is deleted
@property (nonatomic) BOOL isPostDeleted;

//used in the phone utils to determine the exit codes for a country code
@property (nonatomic, retain) NSDictionary *exitCodes;

//This bool is used to temporarily disable the auto refresh when user tapped on the heart symbol.
@property (nonatomic) BOOL isHeartButtonTapped;

//This bool is used to show the first post pop up after share parent or share freinds is cancelled.
@property (nonatomic) BOOL willShowPopUp;

@property(nonatomic) BOOL isFromStreams;

@property (nonatomic) BOOL isShowingBeaconPrompt;
@property (nonatomic) BOOL plusButtonTapped;

+ (id)sharedInstance;
- (void)clear;
- (NSString *)stringFromStatus:(NetworkStatus) status;
-(NSString *)contentTypeForImageData:(NSData *)data;

-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content;
- (NSMutableDictionary *)getResponseStringAddToURL:(NSString *)appendString bodyRequest:(NSMutableDictionary *)finalRequest;

- (NSMutableArray *)getDocumentjsonResponseForCategoryId:(NSString *)categoryId profileId:(NSString *)profileId depth:(NSString *)depth;
-(void)shareToInstagram;

-(void)getProfileDetails;
-(void)setUserDetails;
@end
