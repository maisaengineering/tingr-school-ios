//
//  CustomDailogueUtilis.h
//  Tingr
//
//  Created by Maisa Pride on 1/18/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomDailogueUtilis : NSObject <MBProgressHUDDelegate>

+ (id)sharedInstance;
@property (nonatomic,strong) MBProgressHUD *indicator;

- (void)showIndicator:(BOOL)show;

@end
