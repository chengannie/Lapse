//
//  APPViewController.h
//  Lapse
//
//

#import <UIKit/UIKit.h>

@interface APPViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (instancetype)initWithImage:(UIImage *)image;

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@end
