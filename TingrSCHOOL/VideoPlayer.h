//
//  VideoPlayer.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 5/24/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoPlayer : UIView

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) UISlider *videoSlider;
@property (nonatomic, strong)  UILabel *currentTimeLabel;

@end
