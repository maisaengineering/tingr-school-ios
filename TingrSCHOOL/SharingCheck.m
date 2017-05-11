//
//  SharingCheck.m
//  KidsLink
//
//  Created by Maisa Solutions on 5/28/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "SharingCheck.h"
#import "ModelManager.h"
#import "StringConstants.h"

@implementation SharingCheck
@synthesize delegate;
-(void)callShareApi
{
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken* token          = sharedModel.accessToken;
    UserProfile *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
   
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    [finalRequest setValue:@"is_my_first_post"          forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    DebugLog(@"finalRequest:%@",finalRequest);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/posts",BASE_URL]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         //NSDictionary *requiredDict;
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             if(self.delegate != nil)
             [self.delegate responseForSharing:[responseObject objectForKey:@"body"]];
             
         }
         else if ([stringStatus1 isEqualToString:@"401"])
         {
             NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
             [popData setValue:@"401" forKey:@"error_type"];
             NSString *className = NSStringFromClass([self class]);
             [popData setValue:className forKey:@"classname_name"];
             [popData setValue:responseObject forKey:@"return_data"];
             
             [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
             
         }
         else
         {
            // [self.delegate errorForSharing];
             
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
                  //    [self.delegate errorForSharing];
             //
        
     }];
    
    [operation start];

}

-(void)deletePost:(NSString *)klid
{
    ModelManager *sharedModel   = [ModelManager sharedModel];
    AccessToken* token          = sharedModel.accessToken;
    UserProfile *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    [finalRequest setValue:@"delete_post"          forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    DebugLog(@"finalRequest:%@",finalRequest);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@posts/%@",BASE_URL,klid]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         //NSDictionary *requiredDict;
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             [self.delegate responseForSharing:[responseObject objectForKey:@"body"]];
             
         }
         else if ([stringStatus1 isEqualToString:@"401"])
         {
             NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
             [popData setValue:@"401" forKey:@"error_type"];
             NSString *className = NSStringFromClass([self class]);
             [popData setValue:className forKey:@"classname_name"];
             [popData setValue:responseObject forKey:@"return_data"];
             
             [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
             
         }
         else
         {
             [self.delegate errorForSharing];
             
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
             [self.delegate errorForSharing];
             
        
     }];
    
    [operation start];
    
}

@end
