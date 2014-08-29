//
//  APPViewController.h
//  Lapse
//
//  Created by Rafael Garcia Leiva on 10/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSCoding>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (instancetype)initWithImage:(UIImage *)image;

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@end
