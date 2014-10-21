//
//  APPViewController.m
//  Lapse
//
//

#import "APPViewController.h"
//#import "APPOriginalModalViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

// iPhone5 screen dimensions:
#define SCREEN_WIDTH  320
#define SCREEN_HEIGHT 568

// transform values for full screen support
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.3333 // iOS 7?

// tag number for overlay image view
#define OVERLAY_TAG 1

@interface APPViewController ()

@property (strong, atomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIImageView *buttonbackground;
@property (strong, nonatomic) UIImage* userDefaultsImage;

@property (nonatomic, strong) UIImagePickerController *picker;

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
    
    // handle notifications for camera preview
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil ];
    
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
    
    self.picker = [[UIImagePickerController alloc] init];
    
    self.picker.delegate = self;
    //picker.allowsEditing = YES;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    // set overlay
    if (self.imageView) {

        // add overlayView
        // see reason for why i have to make frame shorter so it doesn't cover bottom buttons :P http://stackoverflow.com/questions/19018658/after-taking-picture-cannot-select-use-photo-or-retake
        UIView *overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 200)];
        overlayView.userInteractionEnabled = @YES;
        
        // make image transparent
        UIImageView *overlayImage = self.imageView;
        [overlayImage setAlpha:0.5f];
        
        // tag image later so it can be changed later without affecting the switch button
        overlayImage.tag = OVERLAY_TAG;
        
        [overlayView addSubview:overlayImage];
        
        // add UISwitch to toggle overlay on and off
        UISwitch *overlayToggle = [[UISwitch alloc] initWithFrame:CGRectMake(260, 35, 0, 0)];
        // make switch on by default, unless there is no overlay image
        if (self.imageView.image) {
            [overlayToggle setOn:YES animated:YES];
        }
        else {
            [overlayToggle setOn:NO animated:YES];
        }
        [overlayToggle addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        [overlayView addSubview:overlayToggle];
        
        self.picker.cameraOverlayView = overlayView;
    }
    
    [self presentViewController:self.picker animated:YES completion:nil];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    //picker.allowsEditing = YES;
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.picker animated:YES completion:NULL];
}

#pragma mark - Action sheet

// show action sheet to use original (i.e. pinned) photo or to pin current photo
- (IBAction)originalPhoto:(UIButton *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Use Pinned Photo", @"Pin", nil];
    [actionSheet showInView:self.view];
//    // attempts at creating cooler looking modal view, but decided i didn't care enough
//    APPOriginalModalViewController* original = [[APPOriginalModalViewController alloc] init];
//    original.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:original animated:YES completion:nil];
//
//    original.view.frame = CGRectInset(original.view.superview.frame, 100, 50);
////    
////    //original.view.superview.backgroundColor = [UIColor clearColor];
////    //original.view.bounds = CGRectMake(0, 0, 100, 100);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        // Use Pinned Photo - set Original as overlayView
        case 0: {
            NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"original"];
            if (imagePath) {
                UIImage* photo = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
                
                // set picture as new background
                UIGraphicsBeginImageContext(self.imageView.frame.size);
                [photo drawInRect:self.imageView.bounds];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.view.backgroundColor = [UIColor colorWithPatternImage:image];
                //self.buttonbackground.image = [UIImage imageNamed:@"launch-screen-lapse-bottom.png"];
                self.imageView.image = photo;
            }
        }
            break;
            
        // Pin - sets current image as original and saves in NSUserDefaults
        case 1: {
            UIImage* original = self.imageView.image;
            
            // Get image data. Here you can use UIImagePNGRepresentation if you need transparency
            NSData *imageData = UIImageJPEGRepresentation(original, 1);
            
            // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
            NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_%f.jpg", [NSDate timeIntervalSinceReferenceDate]]];
            
            // Write image data to user's folder
            [imageData writeToFile:imagePath atomically:YES];
            
            // Store path in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"original"];
            
            // Sync user defaults
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
            
        // Cancel;
        case 2:
            break;
    }
}

#pragma mark - flip/overlay toggle buttons

// when Flip button clicked, the overlay photo (i.e. the photo displayed) will flip horizontally
// useful to flip photos selected from photo library that were originally taken with rear-facing camera
- (IBAction)flipPhoto:(UIButton *)sender {
    if (self.imageView.image) {
        UIImage *photo = self.imageView.image;
        
        // if photo oriented leftmirrored, flip both background and imageview
        if (photo.imageOrientation == UIImageOrientationLeftMirrored)
        {
            // flipp imageView
            UIImage *flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationRight];
            photo = flippedImage;
            self.imageView.image = photo;
            
            // flip background
            UIGraphicsBeginImageContext(self.imageView.frame.size);
            [flippedImage drawInRect:self.imageView.bounds];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.view.backgroundColor = [UIColor colorWithPatternImage:image];

        }
        // if photo oriented right, flip both background and imageview
        else if (photo.imageOrientation == UIImageOrientationRight)
        {
            UIImage *flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
            photo = flippedImage;
            self.imageView.image = photo;
            
            // flip background
            UIGraphicsBeginImageContext(self.imageView.frame.size);
            [flippedImage drawInRect:self.imageView.bounds];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.view.backgroundColor = [UIColor colorWithPatternImage:image];
        }
        else
        {
            NSLog(@"This shouldn't be happening..");
        }
    }
    // if no overlay image, show alert
    else {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"No Overlay Available"
                                                         message:@"Take a photo first!"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil];
        [alert show];
    }
}

// changeSwitch function for overlay toggle switch
- (void)changeSwitch:(id)sender {
        
        // if there is an overlay image
        if (self.imageView.image) {
            // if switch on
            if([sender isOn]){
                // don't hide image
                [((UIImageView *)[self.picker.cameraOverlayView viewWithTag:OVERLAY_TAG]) setHidden:NO];
            } else {
                // hide image
                [((UIImageView *)[self.picker.cameraOverlayView viewWithTag:OVERLAY_TAG]) setHidden:YES];
            }
        }
        // show alert that there is no overlay image
        else
        {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"No Overlay Available"
                                                             message:@"Take a photo first!"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            [alert show];
            
            // turn switch off
            [sender setOn:NO animated:YES];
        }
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    __block UIImage* photo = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = photo;
    
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // flip photo if front facing
            UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
            photo = flippedImage;
            self.imageView.image = photo;
        }
    }
    // flip photo if selected because FOR MY USE CASE ONLY, i'll only be selecting selfies that need to be flipped when i take the picture
    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        // flip photo (ideally only if front facing, but not possible to detect if photo was originally taken front facing...so this flips all photos. I added a Flip button (see flipPhoto method) so the user can manually flip rear-facing photos back again.
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

-(void)handleNotification:(NSNotification *)message {
    // (called before didFinishPickingMediaWithInfo), after photo taken (preview screen)
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // get overlay image and flip and reset
            UIImage* photo = self.imageView.image;
            UIImage* flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationRight]; // i have no idea why I had to use Right here but LeftMirrored elsewhere...maybe something to do with how the image is stored, which is different than it's displayed orientation?
            self.imageView.image = flippedImage;
            
            // update current overlay view's image to be the new flipped image
            ((UIImageView *)[self.picker.cameraOverlayView viewWithTag:OVERLAY_TAG]).image = flippedImage;
        }
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // If retake button hit, reflip overlay again (basically undoing code right above)
            UIImage* photo = self.imageView.image;
            UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
            self.imageView.image = flippedImage;
            
            // update current overlay view's image to be the new flipped image
            ((UIImageView *)[self.picker.cameraOverlayView viewWithTag:OVERLAY_TAG]).image = flippedImage;
        }
    }
}

// for NSUserDefaults stuff
- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
