//
//  UserProfileViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ProfilePhotoUtils.h"
#import "Base64.h"
#import "AlertUtils.h"
@interface UserProfileViewController ()
{
    ModelManager *sharedModel;
    ProfilePhotoUtils *photoUtils;
    SingletonClass *singletonObj;
    UIImage *changedImage;
}
@end

@implementation UserProfileViewController
@synthesize nameLabel;
@synthesize emailLabel;
@synthesize profileImage;
@synthesize roomsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedModel = [ModelManager sharedModel];
    singletonObj = [SingletonClass sharedInstance];
    photoUtils = [ProfilePhotoUtils alloc];
    self.title = @"Profile";
    // Do any additional setup after loading the view.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_arrow.png"]];
    [imageView setTintColor:[UIColor redColor]];
    
    int space=6;
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView.frame.size.width+space, imageView.frame.size.height)];
    
    view.bounds=CGRectMake(view.bounds.origin.x+12, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(bakButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    CGRect frame = profileImage.frame;
    frame.origin.x = (Devicewidth-frame.size.width)/2.0;
    profileImage.frame = frame;

     frame = _camImage.frame;
    frame.origin.x = profileImage.frame.origin.x+55;
    _camImage.frame = frame;

    
    
     frame = _backView.frame;
    frame.size.width = Devicewidth;
    _backView.frame = frame;

    frame = nameLabel.frame;
    frame.size.width = Devicewidth;
    nameLabel.frame = frame;

    frame = emailLabel.frame;
    frame.size.width = Devicewidth;
    emailLabel.frame = frame;

    frame = _editButton.frame;
    frame.origin.x = Devicewidth-40;
    _editButton.frame = frame;
    
    _cameraButton.frame = profileImage.frame;

    
    float yPosition = emailLabel.frame.size.height + 10 + emailLabel.frame.origin.y;
    roomsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, Deviceheight -yPosition) style:UITableViewStylePlain];
    roomsTableView.delegate = self;
    roomsTableView.dataSource = self;
    roomsTableView.backgroundColor = [UIColor clearColor];
    roomsTableView.tableFooterView = [[UIView alloc] init];
    roomsTableView.bounces = NO;
    
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];
    
    // Allocate Sessions Array
    NSMutableArray * sessions1 = [NSMutableArray new];
    [self setSessions:sessions1];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    if ( IDIOM == IPAD ) {

        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        emailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }
    
    [self.view addSubview:roomsTableView];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self setDetails];
}
-(void)setDetails {
    
    
    for(UIView *view in [profileImage subviews])
        [view removeFromSuperview];
    NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
    if( [sharedModel.userProfile.fname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.fname substringToIndex:1] uppercaseString]];
    if( [sharedModel.userProfile.lname length] >0)
        [parentFnameInitial appendString:[[sharedModel.userProfile.lname substringToIndex:1] uppercaseString]];
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                           attributes:nil];
    NSRange range;
    
    if(parentFnameInitial.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x6fa8dc),NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:24]}
                                range:range];
    }
    if(parentFnameInitial.length > 1)
    {
        range.location = 1;
        range.length = 1;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x6fa8dc),NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:24]}
                                range:range];
    }
    
    
    //add initials
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    initial.attributedText = attributedText;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [profileImage addSubview:initial];
    
    __weak UIImageView *weakSelf = profileImage;
    [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sharedModel.userProfile.photograph]] placeholderImage:[UIImage imageNamed:@"EmptyProfile.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)] withRadious:0];
         [initial removeFromSuperview];
         
     }failure:nil];
    if(sharedModel.userProfile.fname.length >0 || sharedModel.userProfile.lname.length > 0)
        [nameLabel setText:[NSString stringWithFormat:@"%@ %@",sharedModel.userProfile.fname,sharedModel.userProfile.lname]];
    
    
    emailLabel.text = sharedModel.userProfile.email;
    
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)sharedModel.userProfile.rooms.count;
    return count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     return 40;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *roomDict = sharedModel.userProfile.rooms[indexPath.row];
    cell.textLabel.text = [roomDict objectForKey:@"session_name"];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];

    if ( IDIOM == IPAD ) {
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    }

    
    cell.textLabel.textColor = [UIColor colorWithRed:113/255.0f green:113/255.0f blue:113/255.0f alpha:1.0f];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *haderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, roomsTableView.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, roomsTableView.frame.size.width, 40)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    NSString *string =@"Rooms";
    if ( IDIOM == IPAD ) {
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    }
    [label setText:string];
    label.textColor = UIColorFromRGB(0x6fa8dc);
    [haderView addSubview:label];
    haderView.backgroundColor = [UIColor whiteColor];
    return haderView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cameraTapped:(id)sender {
    
    if ([self hasValidAPIKey]) {
        
        UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                              @"Take photo", @"Choose existing", nil];
        addImageActionSheet.tag = 1000;
        
        if ( IDIOM == IPAD ) {
            
            [addImageActionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        }
        else {
            
            [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

        }
    }

    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1000:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        //[parent presentViewController:imagePicker animated:YES completion:NULL];
                        [self lauchPicker];
                    }
                    else
                    {
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't have a camera."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        
                        [alert show];
                    }
                    
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        //[parent presentViewController:imagePicker animated:YES completion:NULL];
                        [self lauchPicker];
                    }
                    else
                    {
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't support photo libraries."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        
                        [alert show];
                    }
                    break;
                }
                case 2:
                {
                    
                }
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    
}

- (IBAction)editTapped:(id)sender {
    
    [self performSegueWithIdentifier:@"EditProfileSegue" sender:nil];
}

#pragma mark -
#pragma mark Photo
-(void)lauchPicker
{
   
    if ( IDIOM == IPAD ) {

        [self dismissViewControllerAnimated:NO completion:nil];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:self.cameraButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popover = popover;

    }
    else
        [self presentViewController:imagePicker animated:YES completion:NULL];
    
}


- (BOOL) hasValidAPIKey
{
    if ([kAFAviaryAPIKey isEqualToString:@"<YOUR-API-KEY>"] || [kAFAviarySecret isEqualToString:@"<YOUR-SECRET>"])
    {
        UIAlertView *forgotKeyAlert =  [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                  message:@"You forgot to add your API key and secret!"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        
        
        [forgotKeyAlert show];
        
        return NO;
    }
    return YES;
}

#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AVYPhotoEditorController * photoEditor = [[AVYPhotoEditorController alloc] initWithImage:highResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:NO completion:^{ [Spinner showIndicator:YES];
        [Spinner showIndicator:NO];
    }];
}

- (void) setupHighResContextForPhotoEditor:(AVYPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    id<AVYPhotoEditorRender> render = [photoEditor enqueueHighResolutionRenderWithImage:highResImage
                                                                             completion:^(UIImage *result, NSError *error) {
                                                                                 if (result) {
                                                                                     UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
                                                                                 } else {
                                                                                     NSLog(@"High-res render failed with error : %@", error);
                                                                                 }
                                                                             }];
    
    
    // Provide a block to receive updates about the status of the render. This block will be called potentially multiple times, always
    // from the main thread.
    
    [render setProgressHandler:^(CGFloat progress) {
        NSLog(@"Render now %lf percent complete", round(progress * 100.0f));
    }];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    image = [photoUtils compressForUpload:image :0.67];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData1 = UIImageJPEGRepresentation(image, 0.7);
    changedImage = image;
    NSString *imageExtension = @"JPEG";
    NSString *imageDataEncodedeString = [imageData1 base64EncodedString];
    [Spinner showIndicator:YES];
    [self sendImageInfoToServerWithName:[NSString stringWithFormat:@"temp.%@",imageExtension] contentType:[NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]] content:imageDataEncodedeString];
    
    
}
-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
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
        AccessToken  *token          = sharedModel.accessToken;
        UserProfile  *_userProfile   = sharedModel.userProfile;
        
        NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
        [bodyRequest setValue:_userProfile.teacher_klid          forKey:@"profile_id"];
        [bodyRequest setValue:name                                   forKey:@"name"];
        [bodyRequest setValue:contentType                                forKey:@"content_type"];
        [bodyRequest setValue:content                                forKey:@"content"];
        
        NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
        [finalRequest setValue:token.access_token       forKey:@"access_token"];
        [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
        [finalRequest setValue:@"change_photograph"     forKey:@"command"];
        [finalRequest setValue:bodyRequest              forKey:@"body"];
        
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalRequest options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/document-vault",BASE_URL]]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
             DebugLog(@"response-code: %ld", (long)httpResponse.statusCode);
             
             [Spinner showIndicator:NO];
             
             if (connectionError)
             {
                 DebugLog(@"ERROR CONNECTING DATA FROM SERVER: %@", connectionError.localizedDescription);
                 
                 //401 REPLACE WITH ERROR CODE
               //  [AlertUtils errorAlert];
                 
             }
             else
             {
                 NSError *error;
                 
                 NSMutableDictionary *dictionaryResponseAll = [NSJSONSerialization JSONObjectWithData: data
                                                               //1
                                                                                              options:kNilOptions
                                                                                                error:&error];
                 DebugLog(@"dictionaryResponseAll=%@",dictionaryResponseAll);
                 if(dictionaryResponseAll==nil)
                 {
                     UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
                     

                     [wrongFormatImage show];
                     return;
                     
                 }
                 NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
                 NSString *stringStatus1 = [validResponseStatus stringValue];
                 
                 if ([stringStatus1 isEqualToString:@"200"])
                 {
                     for(UIView *view in [profileImage subviews])
                         [view removeFromSuperview];
                     profileImage.image = [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(80, 80)]];
                     _userProfile.photograph = [[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"];
                     
                     NSMutableDictionary *profilesListResponse = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"] mutableCopy];
                     
                     NSMutableDictionary *body =  [[profilesListResponse objectForKey:@"body"] mutableCopy];
                     [body setObject:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
                     [profilesListResponse setObject:body forKey:@"body"];
                     [[NSUserDefaults standardUserDefaults] setObject:profilesListResponse forKey:@"userProfile"];

                 }
             }
         }];
        
        
    }
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AVYPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    // kAFStickers
    // NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    
    NSArray * toolOrder = @[kAVYOrientation , kAVYCrop, kAVYEffects, kAVYFrames, kAVYEnhance, kAVYColorAdjust, kAVYLightingAdjust, kAVYFocus];
    [AVYPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AVYPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAVYCropPresetHeight : @(4.0f), kAVYCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAVYCropPresetHeight : @(5.0f), kAVYCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAVYCropPresetName: @"Square", kAVYCropPresetHeight : @(1.0f), kAVYCropPresetWidth : @(1.0f)};
    [AVYPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AVYPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];

    [Spinner showIndicator:YES];
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                [self launchEditorWithAsset:asset];
            }
            else
            {
                [self launchPhotoEditorWithImage:info[UIImagePickerControllerOriginalImage] highResolutionImage:info[UIImagePickerControllerOriginalImage]];
            }
        } failureBlock:^(NSError *error) {
            
            [Spinner showIndicator:NO];
            
            UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            
            [disableAlert show];
        }];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:NO completion:completion];
    }else{
      

        UIImage *image = info[UIImagePickerControllerOriginalImage];
        image = [photoUtils compressForUpload:image :0.67];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSData *imageData1 = UIImageJPEGRepresentation(image, 0.7);
        changedImage = image;
        NSString *imageExtension = @"JPEG";
        NSString *imageDataEncodedeString = [imageData1 base64EncodedString];
        [Spinner showIndicator:YES];
        [self sendImageInfoToServerWithName:[NSString stringWithFormat:@"temp.%@",imageExtension] contentType:[NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]] content:imageDataEncodedeString];

        [self.popover dismissPopoverAnimated:YES ];

        
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }else{
        [self.popover dismissPopoverAnimated:YES ];
    }

}

#pragma mark - ALAssets Helper Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }else{
        return YES;
    }
}

- (BOOL) shouldAutorotate
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
 
}


@end
