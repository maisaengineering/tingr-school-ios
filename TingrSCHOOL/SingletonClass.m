//
//  SingletonClass.m
//  mIOSKidsLink
//
//  Created by Maisa Solutions on 3/7/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "SingletonClass.h"
#import "StringConstants.h"
#import "ModelManager.h"
#import "AFHTTPRequestOperation.h"
@implementation SingletonClass

//TODO: Each of these need properties to be documented for how they are used.
//I will check in notes as I go to document why I am making changes

 /*
 TODO: This one is used only in the ProfileAddKidV2ViewController.m class. We could use a local variable
 in that class to hold this string and get rid of this one. It doesn't look like it needs to be persited
 */
@synthesize addKidPhotoId;

/*
 TODO: This one is used only in this class and doesn't currently get used. Will be removing this one
 */
//@synthesize arrayKidNickNames;

/*
 TODO: This one is used only in this class and doesn't currently get used. Will be removing this one
 */
//@synthesize arrayKid_id;


// For Profile
//These are used in many places - will need to do research on purposes
@synthesize profileKids;
@synthesize profileParents;
@synthesize profileOnboarding;

// For Documents
@synthesize sortedParentKidDetails;
@synthesize sortedKidDetails;
@synthesize arrayShowProfiles;

//This is used in the document pages to hold the current profile id for the docs filtering
@synthesize whoseProfileId;
//same as the above but holds the category id
@synthesize whoseCategoryId;
@synthesize whoseDocumentCaptureIds;

//TODO: This used in the DocumentsListViewController.m class to clear and set but the data is
//never used. We should be able to remove this param
//@synthesize arrayDocumentsList;

//TODO: used in one class, will move this one to that class - DocumentNewDetailsViewController.m
@synthesize isImageUploadSuccess;

@synthesize pickedImagesCount;

//TODO: used in one class - will move it there - DocumentPagesViewController.m
@synthesize totalImages;

//TODO: currently not used in any classes - will remove this one
//@synthesize profileParentPhotograph;

//This appears to be used in the document section to hold the name of the filter button
@synthesize stringName;

//used for document filtering - TODO: figure out the relation between this one and the whoseProfileId above
@synthesize selectedProfileid;

//used in docs custom category area
@synthesize customCategory;


@synthesize isPostDeleted;
//TODO: is set in login controller but never used - removing this one
//@synthesize mainNavigatinCtrl;


@synthesize isPending;
@synthesize notificationCount;
@synthesize messageCount;
@synthesize deletedDocumentId;
@synthesize arrayKidsLinkUsers;
@synthesize editedDocumentId;
@synthesize allProfileParents;
@synthesize isSwitchPersonChanged;
@synthesize switchPersonDetails;
@synthesize isFromProfile;
@synthesize isAddFirstChild;
@synthesize operation;
@synthesize isStreamsDownloaded;
@synthesize streamCallCount;
@synthesize canShowDocument;
@synthesize isInKidsTOC;
@synthesize isFBShareEnabled;
@synthesize isInstagramShareEnabled;
@synthesize isFromGetInvite;
@synthesize isChildAdded;
@synthesize attachedImageForInstagram;
@synthesize attachedMessageForInstagram;
@synthesize lastPost;
@synthesize lastPostId;
@synthesize firstKidFirstPostKL_id;
@synthesize isFirstKidFirstPost;
@synthesize isHeartButtonTapped;
@synthesize isFaceBookChecked;
@synthesize exitCodes;
@synthesize willShowPopUp;
@synthesize isInstagramChecked;
@synthesize isFromStreams;
@synthesize selecteOrganisation;
@synthesize onboarding_tour;
@synthesize isShowingBeaconPrompt;
@synthesize selecteRoom;

+ (id)sharedInstance
{
    static SingletonClass *singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    return singletonObject;
}

- (id)init
{
    if (self = [super init])
    {
        [self clear]; //reinit or init all vars
    }
    return self;
}

-(void)setUserDetails {
    
    BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];
    if(key)
    {
        if([[ModelManager sharedModel] accessToken] == nil)
        {
            
            ModelManager *shared = [ModelManager sharedModel];
            AccessToken *token = [[AccessToken alloc] init];
            SingletonClass *singletonObj = [SingletonClass sharedInstance];
            
            
            NSMutableDictionary *parsedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
            
            NSMutableDictionary *profilesListResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"];
            UserProfile *userProfile = [[UserProfile alloc] init];
            userProfile.auth_token   = [[profilesListResponse valueForKey:@"body"] valueForKey:@"auth_token"];
            //   userProfile.onboarding   = [[[profilesListResponse valueForKey:@"body"] valueForKey:@"onboarding"] boolValue];
            userProfile.rooms = [[profilesListResponse valueForKey:@"body"] valueForKey:@"rooms"];
            userProfile.teacher_klid = [[profilesListResponse valueForKey:@"body"] valueForKey:@"teacher_klid"];
            userProfile.fname = [[profilesListResponse valueForKey:@"body"] valueForKey:@"fname"];
            userProfile.lname = [[profilesListResponse valueForKey:@"body"] valueForKey:@"lname"];
            userProfile.email = [[profilesListResponse valueForKey:@"body"] valueForKey:@"email"];
            userProfile.photograph = [[profilesListResponse valueForKey:@"body"] valueForKey:@"photograph"];
            userProfile.org_logo = [[profilesListResponse valueForKey:@"body"] valueForKey:@"org_logo"];
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"selecteRoom"])
                singletonObj.selecteRoom = [[NSUserDefaults standardUserDefaults] objectForKey:@"selecteRoom"];
            
            //TODO: This is overriding the original user profile and items like the verfified phone number
            //are not being put in
            //we should have the user profile once and in one place
            
            shared.userProfile = userProfile;
            
            for (NSString *key in parsedObject)
            {
                if ([token respondsToSelector:NSSelectorFromString(key)]) {
                    
                    [token setValue:[parsedObject valueForKey:key] forKey:key];
                }
            }
            
            shared.accessToken = token;
            
        }
    }
}
-(void)clear
{
    allProfileParents = [[NSMutableArray alloc] init];
    addKidPhotoId               = [[NSString alloc]init];
    //arrayKidNickNames           = [[NSMutableArray alloc]init];
    //arrayKid_id                 = [[NSMutableArray alloc]init];
    // For Profile
    profileKids                 = [[NSMutableArray alloc]init];
    profileParents              = [[NSMutableArray alloc]init];
    profileOnboarding           = [[NSMutableDictionary alloc]init];
    selecteOrganisation         = [[NSMutableDictionary alloc]init];
    selecteRoom                 = [[NSMutableDictionary alloc]init];
    // For Documents
    sortedParentKidDetails      = [[NSMutableArray alloc]init];
    sortedKidDetails = [[NSMutableArray alloc] init];
    arrayShowProfiles           = [[NSMutableArray alloc]init];
    whoseProfileId              = [[NSString alloc]init];
    whoseCategoryId             = [[NSString alloc]init];
    whoseDocumentCaptureIds     = [NSMutableArray array];
    // For DocumentsList
    //arrayDocumentsList          = [[NSMutableArray alloc]init];
    isImageUploadSuccess        = NO;
    //profileParentPhotograph    = [[NSString alloc]init];
    pickedImagesCount           = 0;
    totalImages                 = 0;
    stringName                  = [[NSString alloc]init];
    deletedDocumentId = [[NSMutableArray alloc] init];
    editedDocumentId = [[NSMutableArray alloc] init];
    arrayKidsLinkUsers = [[NSMutableArray alloc] init];
    isSwitchPersonChanged       = NO;
    isInKidsTOC                 = NO;
    switchPersonDetails = [[NSMutableDictionary alloc]init];
    
    isStreamsDownloaded = NO;
    streamCallCount = 0;
    isFBShareEnabled = 0;
    isInstagramShareEnabled = NO;
    isFromGetInvite = NO;
    lastPost = [[NSDictionary alloc]init];
    firstKidFirstPostKL_id = [[NSString alloc]init];
    onboarding_tour = [[NSString alloc]init];
    isFirstKidFirstPost = NO;
    isHeartButtonTapped = NO;
    isFaceBookChecked = NO;
    willShowPopUp = NO;
    isFromStreams = NO;
    
    isShowingBeaconPrompt = NO;
    
}

- (NSString *)stringFromStatus:(NetworkStatus) status
{
    NSString *string;
    switch(status)
    {
        case NotReachable:
            string = @"Not Reachable";
            break;
        case ReachableViaWiFi:
            string = @"Reachable via WiFi";
            break;
        case ReachableViaWWAN:
            string = @"Reachable via WWAN";
            break;
        default:
            string = @"Unknown";
            break;
    }
    return string;
}

#pragma mark- image type
-(NSString *)contentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
    }
    return nil;
}
#pragma mark- calling to API

- (NSMutableDictionary *)getResponseStringAddToURL:(NSString *)appendString bodyRequest:(NSMutableDictionary *)finalRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kBaseURL,appendString]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:&error];
    [request setHTTPBody:newAccountJSONData];
    NSHTTPURLResponse *response = nil;
    NSError *error1;
    NSData *conn = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:conn
                                                                        options:kNilOptions
                                                                          error:&error1];
    return jsonResponse;
}

#pragma mark- ImageUploading to server


//TODO: Will move this to DAO and Manager class. Singletons can cause issues when doing db calls.
-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content
{
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    [bodyRequest setValue:name          forKey:@"name"];
    [bodyRequest setValue:contentType   forKey:@"content_type"];
    [bodyRequest setValue:content       forKey:@"content"];
    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    [finalRequest setValue:@"upload_multimedia"     forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalRequest options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/document-vault",BASE_URL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // 2
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak SingletonClass *weakSelf = self;

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableDictionary *dictionaryResponseAll = responseObject;
         if(dictionaryResponseAll==nil)
         {
             UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
             [wrongFormatImage show];
             return;
             
         }
         NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             NSMutableDictionary *documentDictionary = [[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"document"];
             
             weakSelf.pickedImagesCount = weakSelf.pickedImagesCount -1;
             
             addKidPhotoId = [documentDictionary valueForKey:@"kl_id"];
             [weakSelf.whoseDocumentCaptureIds addObject:weakSelf.addKidPhotoId];
             
             isImageUploadSuccess = YES;
             
             if (weakSelf.pickedImagesCount == 0)
             {
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageUploadedSuccessfully" object:nil];
             }
         }
         else if ([stringStatus1 isEqualToString:@"401"])
         {
             NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
             [popData setValue:@"401" forKey:@"error_type"];
             NSString *className = NSStringFromClass([weakSelf class]);
             [popData setValue:className forKey:@"classname_name"];
             [popData setValue:dictionaryResponseAll forKey:@"return_data"];
             
             [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
             
         }
         else
         {
             [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageUploadedUnSuccessfully" object:nil];

             UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid Image Type" delegate:weakSelf cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
             [wrongFormatImage show];
         }
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageUploadedUnSuccessfully" object:nil];
         
        
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while uplod an image"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             [alertView show];
        
         
     }];
    [operation start];
}

#pragma mark- DocumentRetrieval_With_Category_and_Depth
#pragma mark-

- (NSMutableArray *)getDocumentjsonResponseForCategoryId:(NSString *)categoryId profileId:(NSString *)profileId depth:(NSString *)depth
{
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken* token          = sharedModel.accessToken;
    UserProfile *_userProfile   = sharedModel.userProfile;
    
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    [bodyRequest setValue:profileId         forKey:@"profile_id"];
    [bodyRequest setValue:categoryId        forKey:@"category_id"];
    [bodyRequest setValue:depth             forKey:@"depth"];
    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    
    [finalRequest setValue:token.access_token        forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token forKey:@"auth_token"];
    [finalRequest setValue:@"uploaded_documents"     forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    NSMutableDictionary *jsonResponse = [self getResponseStringAddToURL:@"v2/categories" bodyRequest:finalRequest];
    DebugLog(@"jsonResponse:%@",jsonResponse);
    NSNumber *validResponseStatus = [jsonResponse valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    
    NSMutableArray *requiredArray = [[NSMutableArray alloc]init];
    
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSMutableArray *totalCategoriesResponseArray = [[jsonResponse valueForKey:@"body"] valueForKey:@"categories"];
        for (long int i = 0; i<totalCategoriesResponseArray.count;i++)
        {
            NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *dic = [totalCategoriesResponseArray objectAtIndex:i];
            NSNumber *documentCountNumber = [dic valueForKey:@"document_count"];
            NSString *documentCountString = [NSString stringWithFormat:@"%@",[documentCountNumber stringValue]];

            if (![documentCountString isEqualToString:@"0"])
            {
                [newDic setValue:[dic valueForKey:@"document_count"]    forKey:@"document_count"];
                [newDic setValue:[dic valueForKey:@"documents"]         forKey:@"documents"];
                [newDic setValue:[dic valueForKey:@"kl_id"]             forKey:@"kl_id"];
                [newDic setValue:[dic valueForKey:@"name"]              forKey:@"name"];
                [newDic setValue:[dic valueForKey:@"leaf_node"]         forKey:@"leaf_node"];
                
                [requiredArray addObject:newDic];
            }
        }
    }
    else if ([stringStatus1 isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:jsonResponse forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
        
    }
    return requiredArray;
}

#pragma mark -
#pragma mark Share to Instagram
-(void)shareToInstagram
{
    [self setIsInstagramShareEnabled:FALSE];
    NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
    [popData setValue:self.attachedMessageForInstagram forKey:@"attachedMessage"];
    [popData setValue:self.attachedImageForInstagram forKey:@"attachedImage"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"POST_TO_INSTAGRAM" object:nil userInfo:popData];
}

-(void)getProfileDetails {
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setValue:token.access_token               forKey:@"access_token"];
    [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
    [postData setValue:@"teacher_info"            forKey:@"command"];
    [postData setValue:bodyRequest                      forKey:@"body"];
    
    NSDictionary *userInfo = @{@"command":@"teacher_info"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@profiles/%@",BASE_URL,_userProfile.teacher_klid];
    
    __weak __typeof(self)weakSelf = self;
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf updateTeacherInfo:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
    } failure:^(NSDictionary *json) {
        
        
    }];

}
-(void)updateTeacherInfo:(NSDictionary *)dict{
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.userProfile.fname = [dict valueForKey:@"fname"];
    sharedModel.userProfile.lname = [dict valueForKey:@"lname"];
    sharedModel.userProfile.photograph = [dict valueForKey:@"photograph"];
    sharedModel.userProfile.email = [dict valueForKey:@"email"];
    
    NSMutableDictionary *profilesListResponse = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"] mutableCopy];
    
    NSMutableDictionary *body =  [[profilesListResponse objectForKey:@"body"] mutableCopy];
    [body setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
    [body setObject:[dict objectForKey:@"lname"] forKey:@"lname"];
    [body setObject:[dict objectForKey:@"email"] forKey:@"email"];
    [body setObject:[dict objectForKey:@"photograph"] forKey:@"photograph"];
    [profilesListResponse setObject:body forKey:@"body"];
    [[NSUserDefaults standardUserDefaults] setObject:profilesListResponse forKey:@"userProfile"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MENU" object:nil];


}
@end
