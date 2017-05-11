//
//  ProfilePhotoUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 4/22/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "ProfilePhotoUtils.h"

@implementation ProfilePhotoUtils
{
    
}

@synthesize assetLibrary;

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)makeRoundKidPhoto:(UIImage *)personImage
{
    //UIImage *image = [UIImage imageNamed:[info objectForKey:KEY_IMAGE_NAME]];
    UIImage *image = personImage;
    UIImage *finalImage = nil;
    DebugLog(@"Image Size: %f h %f w", image.size.height, image.size.width);
    int imageSize = image.size.height;
    
    UIGraphicsBeginImageContext(image.size);
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
        trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, imageSize));
        CGContextConcatCTM(ctx, trnsfrm);
        CGContextBeginPath(ctx);
        CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, imageSize, imageSize));
        CGContextClip(ctx);
        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize, imageSize), image.CGImage);
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    return finalImage;
}

-(UIImage *)makeRoundWithBoarder:(UIImage *)fooImage withRadious:(float)value
{
    UIGraphicsBeginImageContextWithOptions(fooImage.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Create the clipping path and add it
    CGRect imageRect = CGRectMake(0, 0, fooImage.size.width, fooImage.size.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imageRect];

    [path addClip];
    [fooImage drawInRect:imageRect];
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    [path setLineWidth:value];
    [path stroke];
    
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  roundedImage;
}

-(UIImage *)makeRoundedCornersWithBorder:(UIImage *)fooImage withRadious:(float)value
{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:fooImage];
    
    UIGraphicsBeginImageContextWithOptions(fooImage.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Create the clipping path and add it
    CGRect imageRect = CGRectMake(0, 0, fooImage.size.width, fooImage.size.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:value];
    [path addClip];
    [fooImage drawInRect:imageRect];
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    [path setLineWidth:5];
    [path stroke];
    
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  roundedImage;
}

- (UIImage *)getImageFromCache:(NSString *)url
{
    
    url = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"-" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    //check the temp directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithString:url] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
    
}

- (void)saveImageToCache:(NSString *)url :(UIImage *)image
{
    if (image != nil)
    {
        
        url = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"-" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithString:url] ];
        NSData* data = UIImageJPEGRepresentation(image, 0.7);
        [data writeToFile:path atomically:YES];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
}
- (void)saveRoundedRectImageToCache:(NSString *)url :(UIImage *)image
{
    if (image != nil)
    {
        
        url = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"-" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithString:url] ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
}
- (void)clearCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *file in files) {
        [fileManager removeItemAtPath:[NSString pathWithComponents:@[documentsDirectory, file]] error:nil];
    }
}

- (UIView*)GrabInitials :(int)diameter :(NSString *)firstName :(NSString *)lastName
{
    UIView *circleView = [[UIView alloc] init];

    int fontSize = 12;

    if (diameter == 43)
    {
       fontSize = 22;
    }
    else if (diameter == 53)
    {
        fontSize = 26;
    }
    else if (diameter == 65)
    {
        fontSize = 30;
    }
    else if (diameter == 85)
    {
        fontSize = 40;
    }
    

    
    NSString *firstInitial = [[firstName substringToIndex:1] uppercaseString];
    
    UILabel *firstInitialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    //firstInitialLabel.backgroundColor =  [UIColor redColor];
    firstInitialLabel.textAlignment = NSTextAlignmentCenter;
    firstInitialLabel.text = firstInitial;
    firstInitialLabel.font =[UIFont fontWithName:@"Archer-Bold" size:fontSize];
    firstInitialLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
    [circleView addSubview:firstInitialLabel];
    
    return circleView;
}


- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale
{
    UIImage* compressedImage = original;
    
    if (original.size.width > 3000 || original.size.height > 3000)
    {
        // Calculate new size given scale factor.
        CGSize originalSize = original.size;
        CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
        DebugLog(@"Original Image H/W: %f, %f", originalSize.height, originalSize.width);
        
        // Scale the original image to match the new size.
        UIGraphicsBeginImageContext(newSize);
        [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        DebugLog(@"New Image H/W: %f, %f", newSize.height, newSize.width);
        compressedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return compressedImage;
}

- (void)saveImageToPhotoLib:(UIImage *)imageOrig
{
    
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];

    //saving images to the KidsLink photo lib
    __weak ALAssetsLibrary *lib = assetLibrary;
    [assetLibrary addAssetsGroupAlbumWithName:@"TingrSCHOOL" resultBlock:^(ALAssetsGroup *group) {
        
        ///checks if group previously created
        if(group == nil){
            
            //enumerate albums
            [lib enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:^(ALAssetsGroup *g, BOOL *stop)
             {
                 //if the album is equal to our album
                 if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"TingrSCHOOL"]) {
                     
                     //save image
                     [lib writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(imageOrig,1.0) metadata:nil
                                           completionBlock:^(NSURL *assetURL, NSError *error) {
                                               
                                               //then get the image asseturl
                                               [lib assetForURL:assetURL
                                                    resultBlock:^(ALAsset *asset) {
                                                        //put it into our album
                                                        [g addAsset:asset];
                                                    } failureBlock:^(NSError *error) {
                                                        
                                                    }];
                                           }];
                     
                 }
             }failureBlock:^(NSError *error){
                 
             }];
            
        }else{
            // save image directly to library
            [lib writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(imageOrig, 1.0) metadata:nil
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      
                                      [lib assetForURL:assetURL
                                           resultBlock:^(ALAsset *asset) {
                                               
                                               [group addAsset:asset];
                                               
                                           } failureBlock:^(NSError *error) {
                                               
                                           }];
                                  }];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

#pragma mark- Excluding a File from Backups on iOS 5.1 and Later
#pragma mark-
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
    
}



@end
