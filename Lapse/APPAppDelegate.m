//
//  APPAppDelegate.m
//  Lapse
//
//

#import "APPAppDelegate.h"

#import "APPViewController.h"

@implementation APPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // read image from NSUserDefaults
    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    if (imagePath) {
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
        
        if (image) {
            self.window.rootViewController = [[APPViewController alloc] initWithImage:image];
        }
        else {
            // if no image, use normal init
            self.window.rootViewController = [[APPViewController alloc] initWithNibName:@"APPViewController" bundle:nil];
        }
    }
    
    // set background as Lapse launch screen
    UIGraphicsBeginImageContext(self.window.frame.size);
    [[UIImage imageNamed:@"launch-screen-lapse.png"] drawInRect:self.window.bounds];
    UIImage* background = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.window.backgroundColor = [UIColor colorWithPatternImage:background];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //http://stackoverflow.com/questions/6648518/save-images-in-nsuserdefaults
    // Get image data. Here you can use UIImagePNGRepresentation if you need transparency
    UIImage* image = ((APPViewController* )self.window.rootViewController).imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_%f.jpg", [NSDate timeIntervalSinceReferenceDate]]];
    
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    
    // Store path in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:@"image"];
    
    // Sync user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// used when saving most recent image in NSUserDefaults
- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}


@end
