//
//  VideoRecordViewController.h
//  Tingr
//
//  Created by Maisa Pride on 4/4/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
@protocol VideoRecordDelegate <NSObject>
- (void)videoRecordCompletedWithOutputUrl:(NSURL *)url;
@end


@interface VideoRecordViewController : UIViewController
@property (nonatomic, weak) id<VideoRecordDelegate> delegate;

@end
