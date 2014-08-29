//
//  APPViewController.m
//  Lapse
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPViewController.h"
#import "OverlayImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

// iPhone5 screen dimensions:
#define SCREEN_WIDTH  320
#define SCREEN_HEIGTH 568

// transform values for full screen support
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.3333 // iOS 7?

@interface APPViewController ()

@property (strong, atomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIImageView *buttonbackground;
@property (strong, nonatomic) UIImage* userDefaultsImage;

@end

@implementation APPViewController

@synthesize library;

// special init method if image retrieved from NSUserDefaults
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:@"APPViewController" bundle:nil];
    
    if (self){
        self.userDefaultsImage = image;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // if saved image was retrieved, set as self.imageView to be overlayed later
    if (self.userDefaultsImage)
    {
        self.imageView.image = self.userDefaultsImage;
        
        // also set retrieved image as background for later (useful if user takes picture but then cancels -- this will get picture back again.)
        UIGraphicsBeginImageContext(self.imageView.frame.size);
        [self.userDefaultsImage drawInRect:self.imageView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
        // set button background to lapse colors
        self.buttonbackground.image = [UIImage imageNamed:@"launch-screen-lapse-bottom.png"];
    }
    
    // if camera device not available (Aka on simulator)
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Device has no camera"
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
    // Add Lapse album to camera
    self.library = [[ALAssetsLibrary alloc] init];
    [self.library addAssetsGroupAlbumWithName:@"Lapse"
                                  resultBlock:^(ALAssetsGroup *group) {
                                      NSLog(@"added album:Lapse");
                                  }
                                 failureBlock:^(NSError *error) {
                                     NSLog(@"error adding album");
                                 }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    if (self.imageView) {
        UIImageView *overlayView = self.imageView;
        [overlayView setAlpha:0.5f];
        picker.cameraOverlayView = overlayView;
//        OverlayImageView* overlayView = [[OverlayImageView alloc] init];
        
        // mirror overlay if selfie
//        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
//        {
////            UIImage* unflipped = self.imageView.image;
//            UIImage* flippedImage = [UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationLeftMirrored];
//            self.imageView.image = flippedImage;
//            [overlayView addSubview:self.imageView];
//            overlayView.imageView = self.imageView;
////            self.imageView.image = unflipped;
////        }
////        else {
////            [overlayView addSubview:self.imageView];
//        }
//        [overlayView setAlpha:0.5f];
//        picker.cameraOverlayView = overlayView;
    }
    
    // DOESN'T WORK BECAUSE DOESN'T FLIP FOR PREVIEW
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIImagePickerControllerUserDidCaptureItem" object:nil queue:nil usingBlock:^(NSNotification *note) {
//        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
//        {
//            // flip overlay if front facing
////            OverlayImageView* overlay = (OverlayImageView* )picker.cameraOverlayView;
////            UIImage* flippedOverlay = [UIImage imageWithCGImage:overlay.image.CGImage scale:overlay.image.scale orientation:UIImageOrientationLeftMirrored];
////            overlay.image = flippedOverlay;
//            //picker.cameraOverlayView = nil;
//            
//        }
//    }];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    __block UIImage* photo = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = photo;
    
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIImagePickerControllerUserDidCaptureItem" object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // flip photo if front facing
            UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
            photo = flippedImage;
            self.imageView.image = photo;
            
            // flip overlay if front facing
//            OverlayImageView* overlay = (OverlayImageView* )picker.cameraOverlayView;
//            UIImage* flippedOverlay = [UIImage imageWithCGImage:overlay.image.CGImage scale:overlay.image.scale orientation:UIImageOrientationLeftMirrored];
//            overlay.image = flippedOverlay;
            picker.cameraOverlayView = nil;
        }
//    }];
    }
    // flip photo if selected because FOR MY USE CASE ONLY, i'll only be selecting selfies that need to be flipped when i take the picture
    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        // flip photo if front facing
        UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
        photo = flippedImage;
        self.imageView.image = photo;
    }

    
    // set picture as new background
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    [photo drawInRect:self.imageView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    // set button background to lapse colors
    self.buttonbackground.image = [UIImage imageNamed:@"launch-screen-lapse-bottom.png"];
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:photo];
//    [self.view addSubview:backgroundView];

    // save picture to Lapse album if taking photo (NOT selecting from library)
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // find Lapse album
        __block ALAssetsGroup* groupToAddTo;
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Lapse"]) {
                                            NSLog(@"found album Lapse");
                                            groupToAddTo = group;
                                        }
                                    }
                                  failureBlock:^(NSError* error) {
                                      NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                  }];
        // save image to Lapse album
        CGImageRef img = [photo CGImage];
        [self.library writeImageToSavedPhotosAlbum:img
                                          metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
                                   completionBlock:^(NSURL* assetURL, NSError* error) {
                                       if (error.code == 0) {
                                           NSLog(@"saved image completed:\nurl: %@", assetURL);
                                           
                                           // try to get the asset
                                           [self.library assetForURL:assetURL
                                                         resultBlock:^(ALAsset *asset) {
                                                             // assign the photo to the album
                                                             [groupToAddTo addAsset:asset];
                                                             NSLog(@"Added %@ to Lapse", [[asset defaultRepresentation] filename]);
                                                         }
                                                        failureBlock:^(NSError* error) {
                                                            NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                        }];
                                       }
                                       else {
                                           NSLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                       }
                                   }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// to archive most recently taken image

@end
