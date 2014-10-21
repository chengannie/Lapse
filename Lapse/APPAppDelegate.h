//
//  APPAppDelegate.h
//  Lapse
//
//  Features to add in the future:
//  DONE 1. flipping button (to unflip rear camera photos selected from photo library)
//  2. reminder notifications
//  DONE 3. overlay toggle button during preview view (so you can turn overlay on and off before choosing to keep or retake photo)
//  4. general face outline preview instead of just overlay, so you don't keep shifting your face position gradually when you take the photo
//      ~i can do this specifically for my face for my own personal use, or I can add a drawing/shape adding function that allows people to draw outline of their own face and saves it so it's customized
//

#import <UIKit/UIKit.h>

@class APPViewController;

@interface APPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
