//
//  API.m
//  Tingr
//
//  Created by Maisa Pride on 1/15/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "API.h"

@implementation API

- (void)fetchJSON:(NSDictionary *)params completionWithSuccess:(SuccessBlock) successBlock failure:(FailureBlock) failureBlock {
    
    NSDictionary *postData = [params objectForKey:@"postData"];
    NSString *urlAsString = [params objectForKey:@"urlAsString"];
    NSDictionary *userInfo = [params objectForKey:@"userInfo"];
    
    NSError* error;
    
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0  error:&error];
    
    //convert data to string
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    DebugLog(@"----Request-URL: %@",urlAsString);
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
  
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if([responseObject objectForKey:@"status"] && [[responseObject objectForKey:@"status"] intValue] == 401)
         {
             
         }
         else
         {
             NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"userInfo",responseObject,@"response", nil];
             successBlock(dict);
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         id responseObject = operation.responseObject;
         if([responseObject objectForKey:@"status"] && [[responseObject objectForKey:@"status"] intValue] == 401)
         {

             [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:nil];
             failureBlock(responseObject);


         }
         else
         {
             failureBlock(responseObject);
         }

     }];
    [operation start];
    
}

@end
