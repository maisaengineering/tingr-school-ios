//
//  SharingCheck.h
//  KidsLink
//
//  Created by Maisa Solutions on 5/28/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SharingCheckDelegate <NSObject>
- (void)responseForSharing:(NSDictionary *)body;
- (void)errorForSharing;
@end
@interface SharingCheck : NSObject
-(void)callShareApi;
-(void)deletePost:(NSString *)klid;
@property (nonatomic, weak) id<SharingCheckDelegate> delegate;

@end
