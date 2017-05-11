//
//  DocumentSingletonClass.m
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 26/03/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "DocumentSingletonClass.h"
#import "ModelManager.h"
#import "StringConstants.h"
#import "SingletonClass.h"

@implementation DocumentSingletonClass

@synthesize stringProfileId;
@synthesize stringCategoryId;
@synthesize delegate;

+ (id)documentSingletonInstance
{
    static DocumentSingletonClass *documentSingletonInstance = nil;
    static dispatch_once_t onceDocument;
    dispatch_once(&onceDocument, ^{
        documentSingletonInstance = [[self alloc]init];
    });
    return documentSingletonInstance;
}

- (id)init
{
    if (self = [super init])
    {
        stringProfileId     = NULL;
        stringCategoryId    = NULL;
    }
    return self;
}

- (void)fetchDocumentsWithProfileId:(NSString *)profileId categoryId:(NSString *)categoryId depth:(NSString *)depth
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
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
        [finalRequest setValue:_userProfile.auth_token   forKey:@"auth_token"];
        [finalRequest setValue:@"uploaded_documents"     forKey:@"command"];
        [finalRequest setValue:bodyRequest               forKey:@"body"];
        
        DebugLog(@"finalRequest:%@",finalRequest);
        NSString *urlString = [NSString stringWithFormat:@"%@v2/categories",BASE_URL];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        
        NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:nil];
        [request setHTTPBody:newAccountJSONData];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
             NSString *stringStatus1 = [validResponseStatus stringValue];
             
             NSDictionary *requiredDict;
             
             if ([stringStatus1 isEqualToString:@"200"])
             {
                 requiredDict = [responseObject valueForKey:@"body"];
                 [self.delegate documentSucces:requiredDict];
             }
             else
                 
             {
                 
             }
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [self.delegate documentFailure:error];
             
             //                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while retrieving DocumentSingletonClass"
             //                                                                     message:[NSString stringWithFormat:@"operation.response.statusCode:%lu,Error:%@",(long)operation.response.statusCode,[error localizedDescription]]
             //                                                                    delegate:nil
             //                                                           cancelButtonTitle:@"Ok"
             //                                                           otherButtonTitles:nil];
             //                 [alertView show];
             
         }];
        
        // 5
        [operation start];
    }
    
    /*
     NSHTTPURLResponse *response = nil;
     NSError *error1;
     NSData *conn = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
     NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:conn
     options:kNilOptions
     error:&error1];
     NSNumber *validResponseStatus = [jsonResponse valueForKey:@"status"];
     NSString *stringStatus1 = [validResponseStatus stringValue];
     
     NSDictionary *requiredArray;
     
     if ([stringStatus1 isEqualToString:@"200"])
     {
     requiredArray = [jsonResponse valueForKey:@"body"];
     }
     return requiredArray;
     */
    
}


- (void)dealloc
{
    
}
@end
