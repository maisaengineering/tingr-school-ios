//
//  DocumentSingletonClass.h
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 26/03/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DocumentListDelegate <NSObject>

- (void)documentSucces:(NSDictionary *)objectNotation;
- (void)documentFailure:(NSError *)error;

@end

@interface DocumentSingletonClass : NSObject
{
    
}
@property (strong, nonatomic) NSString *stringProfileId;
@property (strong, nonatomic) NSString *stringCategoryId;
@property (weak, nonatomic) id <DocumentListDelegate> delegate;

+(id)documentSingletonInstance;

- (void)fetchDocumentsWithProfileId:(NSString *)profileId categoryId:(NSString *)categoryId depth:(NSString *)depth;

@end

