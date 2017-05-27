//
//  PostDataUpload.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 5/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostDataUpload : NSObject<NSURLSessionDelegate>

@property(nonatomic, strong) NSMutableDictionary *postDetails;
@property(nonatomic, strong) NSMutableArray *keysArray;
@property(nonatomic, strong) NSMutableArray *selectedKeys;
@property(nonatomic, assign) NSInteger uploadCount;
@property(nonatomic, assign) BOOL isPostClicked;
@property (nonatomic, strong) NSDictionary *detailsDict;



+ (id)sharedInstance;
-(void)uploadFromUrl:(NSURL *)fileUrl withSignedURL:(NSURL *)signedURL withKey:(NSString *)key contentType:(NSString *)contentType;
-(void)clearData;
-(void)callPostAPI;
@end
