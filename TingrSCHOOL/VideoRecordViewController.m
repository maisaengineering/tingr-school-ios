//
//  VideoRecordViewController.m
//  Tingr
//
//  Created by Maisa Pride on 4/4/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "VideoRecordViewController.h"
#import "ViewUtils.h"
@interface VideoRecordViewController ()
{
    CAShapeLayer *timeLeftShapeLayer;
    CAShapeLayer *bgShapeLayer;
    float timeLeft;
    NSDate *endTime;
    CABasicAnimation *strokeIt;
    NSTimer *timer;
    NSURL *outputFileUrlMov;

}

@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation VideoRecordViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetMedium
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    self.camera.tapToFocus = NO;
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                
            }
        }
    }];
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash.png"] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(0, screenRect.size.height - 60, 100, 30);
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.cancelButton];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.frame = CGRectMake(screenRect.size.width - 90, screenRect.size.height - 60, 100, 30);
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton.hidden = YES;
    [self.view addSubview:self.saveButton];
    
    
    bgShapeLayer = [[CAShapeLayer alloc] init];
    bgShapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake((self.view.frame.size.width)/2, (self.view.frame.size.height-50)) radius:40 startAngle:[self degreesToRadians:-90] endAngle:[self degreesToRadians:270] clockwise:YES].CGPath;
    bgShapeLayer.strokeColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.5] CGColor];
    bgShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    bgShapeLayer.lineWidth = 3;
    [self.view.layer addSublayer:bgShapeLayer];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"TingrSHOOL" message:@"Please give Camera  and Micrpphone permissions in Settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [successAlert show];

            
        });

        
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=VIDEO"]];
        
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=VIDEO"]];
    }
    

    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    [self dismissViewControllerAnimated:YES completion:nil];

    
    
}
/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
-(void)cancelButtonTapped {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)saveButtonTapped {
    
    _saveButton.userInteractionEnabled = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4", [paths objectAtIndex:0],TimeStamp];
    
    [self convertVideoToLowQuailtyWithInputURL:outputFileUrlMov outputURL:[NSURL fileURLWithPath:videoPath]];
   

}
- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)snapButtonPressed:(UIButton *)button
{
    
    if(!self.camera.isRecording) {
        
        
        self.flashButton.hidden = YES;
        self.switchButton.hidden = YES;
        self.saveButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        
        
        timeLeftShapeLayer = [[CAShapeLayer alloc] init];
        timeLeftShapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake((self.view.frame.size.width)/2, (self.view.frame.size.height-50)) radius:40  startAngle:[self degreesToRadians:-90] endAngle:[self degreesToRadians:270] clockwise:YES].CGPath;
        timeLeftShapeLayer.strokeColor = [[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor];
        timeLeftShapeLayer.fillColor = [[UIColor clearColor] CGColor];
        timeLeftShapeLayer.lineWidth = 3;
        [self.view.layer addSublayer:timeLeftShapeLayer];
        
        
        strokeIt = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        [strokeIt setFromValue:[NSNumber numberWithFloat:0.0]];
        strokeIt.toValue = [NSNumber numberWithFloat:1.0];
        strokeIt.duration = 60.0;
        [timeLeftShapeLayer addAnimation:strokeIt forKey:nil];
        
        if([timer isValid])
        {
            [timer isValid];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTimer) userInfo:nil repeats:NO];
        
        // start recording
        NSURL *outputURL = [[[self applicationDocumentsDirectory]
                             URLByAppendingPathComponent:@"video"] URLByAppendingPathExtension:@"mov"];
        [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
            
            [timeLeftShapeLayer removeFromSuperlayer];
           
            if(error == nil)
            {
                outputFileUrlMov = outputFileUrl;
                self.saveButton.hidden = NO;
                self.saveButton.userInteractionEnabled = YES;
                
            }
            
        }];
        
    } else {
        
        
        self.flashButton.hidden = NO;
        self.switchButton.hidden = NO;
        
        self.cancelButton.hidden = NO;
        
        self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        
        [self.camera stopRecording];
        [timeLeftShapeLayer removeFromSuperlayer];
    }
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 15.0f;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
    
}
-(void)updateTimer {
    
    [timer invalidate];
    
    self.flashButton.hidden = NO;
    self.switchButton.hidden = NO;
    
    self.cancelButton.hidden = NO;
    
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    [self.camera stopRecording];
    [timeLeftShapeLayer removeFromSuperlayer];
    
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(CGFloat)degreesToRadians:(CGFloat)degree {
    
    return degree * M_PI / 180.0;
    
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
{
    
    [Spinner showIndicator:YES];
    
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
    exporter.outputURL=outputURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         switch (exporter.status)
         {
             case AVAssetExportSessionStatusCompleted:
             {
                 
                 [[NSFileManager defaultManager] removeItemAtURL:inputURL error:nil];
                 NSLog(@"Video Merge SuccessFullt");
                 
                 [self.delegate videoRecordCompletedWithOutputUrl:outputURL];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [Spinner showIndicator:NO];
                     [self dismissViewControllerAnimated:YES completion:nil];
                 });
                 

             }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@", exporter.error.description);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@", exporter.error);
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"Exporting!");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"Waiting");
                 break;
             default:
                 break;
         }
     }];
    
    
    
    //setup video writer
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
