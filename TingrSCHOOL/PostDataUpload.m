//
//  PostDataUpload.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 5/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "PostDataUpload.h"
#import "ProfilePhotoUtils.h"
@implementation PostDataUpload
@synthesize uploadCount;
@synthesize postDetails;
@synthesize keysArray;
@synthesize detailsDict;
@synthesize selectedKeys;
@synthesize isPostClicked;
@synthesize fileUrlArrays;
+ (id)sharedInstance
{
    static PostDataUpload *sharedpostDataUpload = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedpostDataUpload = [[self alloc] init];
    });
    return sharedpostDataUpload;
}
-(void)getPresignedURLWithFileUrl:(NSURL *)fileURL withKey:(NSString *)key contentType:(NSString *)contentType{
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    
    uploadCount++;
    
    NSMutableDictionary *newImageDetails  = [NSMutableDictionary dictionary];
    
    [newImageDetails setValue:key     forKey:@"asset_key"];
    [newImageDetails setValue:contentType     forKey:@"content_type"];
    
    NSString *command = @"upload_endpoint";
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": userProfile.auth_token,
                               @"command": command,
                               @"body": newImageDetails};
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    __weak PostDataUpload *weakSelf = self;
    
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(weakSelf)
        {
            
            NSURL *signedURL = [NSURL URLWithString:[[[json objectForKey:@"response"] objectForKey:@"body"] objectForKey:@"endpoint_url"]];
            [weakSelf uploadFromUrl:fileURL withSignedURL:signedURL withKey:key contentType:contentType];
        }
        
    } failure:^(NSDictionary *json) {
        if(weakSelf)
        {
            uploadCount--;
            if(uploadCount == 0 && isPostClicked)
            {
                [weakSelf callPostAPI];
            }

        }
        
        
    }];
}

-(void)uploadFromUrl:(NSURL *)fileUrl withSignedURL:(NSURL *)signedURL withKey:(NSString *)key contentType:(NSString *)contentType{
    
    
    [keysArray addObject:key];
    [fileUrlArrays addObject:fileUrl];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    // Create the Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:signedURL];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setHTTPMethod:@"PUT"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"curl/7.51.0" forHTTPHeaderField:@"User-Agent"];
    
    __weak PostDataUpload *weakSelf = self;
        
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromFile:fileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        



        if(weakSelf)
        {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        long int satuscode = (long)[httpResponse statusCode];
        if(satuscode == 200)
        {
            [selectedKeys addObject:key];
        }
        uploadCount--;
        if(uploadCount == 0 && isPostClicked)
        {
            [weakSelf callPostAPI];
        }
        }
    }];
   
    //uploadTask is an instance of NSURLSessionDownloadTask.
    //session is an instance of NSURLSession.
    [uploadTask resume];

}



-(void)callPostAPI {
    
    if(uploadCount > 0)
    {
        isPostClicked = YES;
        return;
    }
    
    [self savePostContentToAlbum];
    
    NSMutableDictionary *postdata = [[postDetails objectForKey:@"postData"] mutableCopy];
    NSMutableDictionary *body = [[postdata objectForKey:@"body"] mutableCopy];
    
    
        [body setObject:selectedKeys forKey:@"img_keys"];
    
    [postdata setObject:body forKey:@"body"];
    [postDetails setObject:postdata forKey:@"postData"];
    __weak PostDataUpload *weakSelf = self;
    
    API *api = [[API alloc] init];
    [api fetchJSON:postDetails completionWithSuccess:^(NSDictionary *json) {
        
        
        [weakSelf didReceiveCreateMilestones:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
    } failure:^(NSDictionary *json) {
        
        [weakSelf fetchingCreateMilestonesFailedWithError:nil];
        
    }];
    
    
    
}

- (void)didReceiveCreateMilestones:(NSDictionary *)milestone
{
    NSDictionary *post = [milestone objectForKey:@"post"];
    
    if([detailsDict count] > 0)
        [[NSNotificationCenter defaultCenter]postNotificationName:@"EditPostCompleted" object:post];
    else
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PostCompleted" object:post];

}
- (void)fetchingCreateMilestonesFailedWithError:(NSError *)error
{
    
}


-(void)savePostContentToAlbum {
    
    ProfilePhotoUtils *photoUtil = [ProfilePhotoUtils alloc];
    for(NSURL *fileUrl in fileUrlArrays){

        NSString *stringUrl = [fileUrl absoluteString];
        if([stringUrl containsString:@".jpeg"])
            [photoUtil saveImageToPhotoLib:fileUrl];
        else
            [photoUtil saveVideoToPhotoLib:fileUrl];
    }
}
-(void)clearData {
    
    uploadCount = 0;
    selectedKeys = [[NSMutableArray alloc] init];
    keysArray = [[NSMutableArray alloc] init];
    detailsDict = [[NSMutableDictionary alloc] init];
    isPostClicked = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(NSURL *fileUrl in fileUrlArrays){
        
        [fileManager removeItemAtPath:[fileUrl absoluteString] error:NULL];

    }
    fileUrlArrays = [[NSMutableArray alloc] init];
}

@end
