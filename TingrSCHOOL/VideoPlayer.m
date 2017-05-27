//
//  VideoPlayer.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 5/24/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
@implementation VideoPlayer
{
    UIActivityIndicatorView *activityIndicatorView;
    UILabel *videoLengthLabel;
    UIButton *replayButton;
    
}
@synthesize currentTimeLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self baseInit];
    }
    
    return self;
}
-(void)baseInit
{
    
    self.backgroundColor = [UIColor blackColor];
    self.avPlayer = [AVPlayer playerWithURL:_url];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    [self.layer addSublayer: layer];
    layer.frame = self.frame;
    

    [self.avPlayer play];
    [self.avPlayer addObserver:self forKeyPath:@"currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];

    
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];

    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(doneTapped) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(10, 10, 50, 50);
    [self addSubview:doneButton];

    replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [replayButton addTarget:self action:@selector(replayTapped) forControlEvents:UIControlEventTouchUpInside];
    [replayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    replayButton.frame = CGRectMake(10, 10, 50, 50);
    replayButton.center = self.center;
    replayButton.hidden = YES;
    [self addSubview:replayButton];


    
    videoLengthLabel = [[UILabel alloc] init];
    videoLengthLabel.text = @"00:00";
    videoLengthLabel.frame = CGRectMake(Devicewidth-50, Deviceheight -30, 50, 30);
    videoLengthLabel.textColor = [UIColor whiteColor];
    videoLengthLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:videoLengthLabel];

    
    currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.text = @"00:00";
    currentTimeLabel.textAlignment = NSTextAlignmentRight;
    currentTimeLabel.textColor = [UIColor whiteColor];
    currentTimeLabel.frame = CGRectMake(0, Deviceheight -30, 50, 30);
    currentTimeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:currentTimeLabel];

    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] ;
    activityIndicatorView.center = self.center;
    activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    self.videoSlider = [[UISlider alloc] initWithFrame:CGRectMake(58, Deviceheight -30, Devicewidth-116, 30)];
    self.videoSlider.minimumTrackTintColor = [UIColor redColor];
    self.videoSlider.maximumTrackTintColor = [UIColor whiteColor];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    [self.videoSlider addTarget:self action:@selector(handleSliderChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.videoSlider];
    
    CMTime interval = CMTimeMake(1,2);
    
    __weak VideoPlayer *weakSelf = self;

    [self.avPlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        
        float seconds = CMTimeGetSeconds(time);
        NSString *secondsString = [NSString stringWithFormat:@"%02d",(int)seconds % 60];
        NSString *minutesString = [NSString stringWithFormat:@"%02d",(int)seconds / 60];
        
        weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];

        
        CMTime duration = weakSelf.avPlayer.currentItem.duration;
        if(CMTimeGetSeconds(duration) != CMTimeGetSeconds(kCMTimeZero))
        {
            float durationSeconds = CMTimeGetSeconds(duration);
            weakSelf.videoSlider.value = seconds / durationSeconds;
        }
        
    }];
    
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentItem.loadedTimeRanges"]){
        
        CMTime duration = self.avPlayer.currentItem.duration;
        float seconds = CMTimeGetSeconds(duration);
        NSString *secondsString = [NSString stringWithFormat:@"%02d",(int)seconds % 60];
        NSString *minutesString = [NSString stringWithFormat:@"%02d",(int)seconds / 60];
        videoLengthLabel.text = [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];
        
        [activityIndicatorView stopAnimating];
        
    }

     if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.avPlayer.currentItem.playbackBufferEmpty) {
            //Your code here
            
            [activityIndicatorView startAnimating];
        }
    }
    
     if ( [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.avPlayer.currentItem.playbackLikelyToKeepUp)
        {
            [self.avPlayer play];
            [activityIndicatorView stopAnimating];
        }
    }
     if ( [keyPath isEqualToString:@"playbackBufferFull"])
    {
        if (self.avPlayer.currentItem.playbackLikelyToKeepUp)
        {
            [self.avPlayer play];
            [activityIndicatorView stopAnimating];
        }
    }
    
    

}


-(void)doneTapped {
    
    [activityIndicatorView stopAnimating];
    [activityIndicatorView removeFromSuperview];
    [self.avPlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.avPlayer removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges"];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];


    self.avPlayer = nil;
    [self removeFromSuperview];
}
-(void)replayTapped {
    
    replayButton.hidden = YES;
    
    currentTimeLabel.text = @"00:00";
    CMTime seekTime = CMTimeMake(0, 1);
    self.videoSlider.value = 0;
    [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
        
      
    }];
    [self.avPlayer play];
}
-(void)handleSliderChange {
    
    CMTime duration = self.avPlayer.currentItem.duration;
    float totalSeconds = CMTimeGetSeconds(duration);
    float value = self.videoSlider.value * totalSeconds;
    
    CMTime seekTime = CMTimeMake((int)value, 1);
    
    [self.avPlayer seekToTime:seekTime completionHandler:^(BOOL finished) {
        
    }];
    [self.avPlayer play];
}
-(void)itemDidFinishPlaying:(NSNotification *) notification {

    replayButton.hidden = NO;

}

@end
