//
//  APPViewController.m
//  Lapse
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface APPViewController ()

@property (strong, atomic) ALAssetsLibrary *library;

@end

@implementation APPViewController

@synthesize library;

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    
    if (self.imageView) {
        [self.imageView setAlpha:0.5f];
        picker.cameraOverlayView = self.imageView;
    }
    
    [self presentViewController:picker animated:YES completion:NULL];
    
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
    
    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *photo = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = photo;
    
    // to save to camera roll
    //UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);

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
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
