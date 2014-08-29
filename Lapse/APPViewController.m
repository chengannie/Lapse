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
#define SCREEN_HEIGTH 568

// transform values for full screen support
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.3333 // iOS 7?

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
        UIImageView *overlayView = self.imageView;
        [overlayView setAlpha:0.5f];
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

// show modal view for original photo options
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

-(void)handleNotification:(NSNotification *)message {
    // (called before didFinishPickingMediaWithInfo)
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // get overlay image and flip and reset
            UIImage* photo = self.imageView.image;
            UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationRight]; // i have no idea why I had to use Right here but LeftMirrored elsewhere...maybe something to do with how the image is stored, which is different than it's displayed orientation?
            self.imageView.image = flippedImage;
            self.picker.cameraOverlayView = self.imageView;
        }
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            // If retake button hit, reflip overflay again get (basically undoing code right above)
            UIImage* photo = self.imageView.image;
            UIImage * flippedImage = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
            self.imageView.image = flippedImage;
            self.picker.cameraOverlayView = self.imageView;
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
