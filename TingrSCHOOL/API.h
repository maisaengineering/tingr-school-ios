//
//  API.h
//  Tingr
//
//  Created by Maisa Pride on 1/15/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSDictionary* json);
typedef void (^FailureBlock)(NSDictionary* json);

@interface API : NSObject

- (void)fetchJSON:(NSDictionary *)params completionWithSuccess:(SuccessBlock) successBlock failure:(FailureBlock) failureBlock;

@end
