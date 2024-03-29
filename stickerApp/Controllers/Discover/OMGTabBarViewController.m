//
//  OMGTabBarViewController.m
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import "OMGTabBarViewController.h"
#import "CBImagePickerViewController.h"

#import "OMGLightBoxViewController.h"
#import "OMGSnapViewController.h"
#import "OMGMySnapsViewController.h"
#import "OMGMapViewController.h"
#import "OMGSnapVoteViewController.h"
#import "NewUserViewController.h"
#import "StickerCategoryViewController.h"
#import "SnapServiceManager.h"

#import <MessageUI/MessageUI.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <Chartboost/Chartboost.h>

#import "ShareViewController.h"
#import "PlayViewController.h"
#import "MixPanelManager.h"

#import "AppDelegate.h"
#import "Snap.h"
#import <Crashlytics/Crashlytics.h>

@interface OMGTabBarViewController ()<UITabBarControllerDelegate, OMGLightBoxViewControllerDelegate, OMGSnapViewControllerDelegate, OMGHeadSpaceViewControllerDelegate, StickerCategoryViewControllerDelegate, MFMessageComposeViewControllerDelegate>{
    BOOL camera;
}


@property (nonatomic, strong) OMGSnapViewController *ibo_omgsnapVC;
@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;
@property (nonatomic, strong) OMGMySnapsViewController *ibo_mysnapsVC;
@property (nonatomic, strong) OMGMapViewController *ibo_omgMapsVC;

@property (nonatomic, strong) OMGSnapVoteViewController *ibo_omgVoteVC;

@property (nonatomic, strong) UIPopoverController *popController;

@end


@implementation OMGTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:nil];
    _ibo_headSpace = (OMGHeadSpaceViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_OMGHeadSpaceViewController"];
    _ibo_headSpace.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
    _ibo_headSpace.delegate = self;
    _ibo_headSpace.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_MAP_TITLE", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_ibo_headSpace updateKarma];
    });
    
    [self.view addSubview:_ibo_headSpace.view];
    [self.tabBar setTintColor:[UIColor blackColor]];
    [self.tabBar  setBarTintColor:[UIColor whiteColor]];
    [[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"TABBAR_HOT", nil)];
    [[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"TABBAR_NEW", nil)];
    [[self.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"TABBAR_MAP", nil)];
    [[self.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"TABBAR_MORE", nil)];
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    switch (self.selectedIndex) {
        case 0://Snap Vote
            NSLog(@"Snap Vote tab item pressed");
//            [MixPanelManager triggerEvent:@"Explore" withData:@{ @"View": @"New" }];
//            _ibo_headSpace.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_NEW_TITLE", nil);
//            _ibo_omgVoteVC = (OMGSnapVoteViewController *)[self.viewControllers objectAtIndex:0];
//            [_ibo_omgVoteVC refreshData];
            break;
        case 1://HOTTEST
            NSLog(@"Hottest tab item pressed");
            [MixPanelManager triggerEvent:@"Explore" withData:@{ @"View": @"Hottest" }];
            _ibo_headSpace.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_HOT_TITLE", nil);
            _ibo_omgsnapVC = (OMGSnapViewController *)[self.viewControllers objectAtIndex:1];
            [_ibo_omgsnapVC refreshData];
            break;
        case 2://NEWEST
            NSLog(@"Newes tab item pressed");
            [MixPanelManager triggerEvent:@"Explore" withData:@{ @"View": @"Map" }];
            _ibo_headSpace.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_MAP_TITLE", nil);
            break;
        case 3://MORE
            NSLog(@"More tab item pressed");
            [MixPanelManager triggerEvent:@"Explore" withData:@{ @"View": @"Mystuff" }];
            _ibo_headSpace.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_MORE_TITLE", nil);
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [_ibo_headSpace updateKarma];
}

- (void) initCameraTaker {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayViewController *playVC = (PlayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_PlayViewController"];
    [self presentViewController:playVC animated:YES completion:nil];
    return;
}

- (void) omgEmojiTime {
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

#pragma GIF SEND
- (UIImage *) getPopmoji:(UIImage *)image withPad:(int)pad {
    image = [self imageFixBoundingBox:image];
    CGRect rect = CGRectMake(0, 0, 100, 100);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGRect lowerImage = CGRectMake((rect.size.width - image.size.width)/2,
                                   (rect.size.height - image.size.height)/2 + pad,
                                   image.size.width,
                                   image.size.height);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, lowerImage, image.CGImage);
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    
    return final;
}

- (void) sendMMSAnimated:(NSArray *)recipitants withImage:(NSURL *)image {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSData *imgData = [NSData dataWithContentsOfURL:image];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    if (recipitants) {
        [messageController setRecipients:recipitants];
    }
    [messageController addAttachmentData:imgData typeIdentifier:(NSString *)kUTTypeGIF filename:@"popmoji.gif"];
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (NSURL *) makeAnimatedGif:(NSArray *) gifImages {
    NSUInteger kFrameCount =(unsigned long) [gifImages count];
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(0.15f), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"popmoji.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            CGImageDestinationAddImage(destination, ((UIImage *)[gifImages objectAtIndex:i]).CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }

    CFRelease(destination);

    return fileURL;
}


#pragma GIF END
-(void) stickerCategory:(StickerCategoryViewController *)controller
       withCategoryName:(NSString *)name
                  andID:(NSString *)categoryID {}

//SELECT STICKER DELEGATES
-(void) stickerCategory:(StickerCategoryViewController *)controller didFinishPickingStickerImage:(UIImage *)image
             withPackID:(NSString *)packID {

    [MixPanelManager triggerEvent:@"Emoji" withData:@{ @"PackID": packID }];
    [controller dismissViewControllerAnimated:YES completion:^(void){
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support MMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        [self sendMMSAnimated:nil withImage:[self makeAnimatedGif:@[[self getPopmoji:image withPad:5],
                                                                    [self getPopmoji:image withPad:0]
                                                                    ]]];
      
        [MixPanelManager triggerEvent:@"Send Emoji" withData:@{ @"PackID": packID }];
        return;
    }];
}

- (UIImage *)imageFixBoundingBox:(UIImage *)image {
    float height;
    float width;

    if (image.size.height >= image.size.width) {
        height = 80;
        width = image.size.width / image.size.height * 80;
    } else {
        height = image.size.height / image.size.width * 80;
        width = 80;
    }
    
    CGRect rect;
    rect = CGRectMake(0, 0, 110, 120);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect lowerImage = CGRectMake((rect.size.width - width)/2, (rect.size.height - height)/2,
                                   width,
                                   height);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, lowerImage, image.CGImage);

    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    
    return final;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message sending cancelled.");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message sending failed.");
            break;
        case MessageComposeResultSent:
            NSLog(@"Message sent.");
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^(){
        [Chartboost showInterstitial:CBLocationDefault];
    }];
}

#pragma LightboxViewer
- (void)showFullScreenSnap:(Snap *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:[NSBundle mainBundle]];
    _ibo_lightboxView = (OMGLightBoxViewController*)[mainSB instantiateViewControllerWithIdentifier: @"seg_OMGLightBoxViewController"];
    _ibo_lightboxView.view.frame = self.view.frame;
    _ibo_lightboxView.delegate = self;
    _ibo_lightboxView.preloadImage = thumbnail;
    _ibo_lightboxView.ibo_fade_voter.hidden = voter;
    [_ibo_lightboxView setSnap:snap];

    [self.view addSubview:_ibo_lightboxView.view];
}

- (void) omgSnapDismissLightBox:(Snap *)snap {
    [self.ibo_headSpace updateKarma];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_ibo_lightboxView.view removeFromSuperview];
    _ibo_lightboxView.delegate = nil;
    _ibo_lightboxView = nil;

    //Update snap cell on parent view
    switch (self.selectedIndex) {
        case 0:
            _ibo_omgVoteVC = (OMGSnapVoteViewController *)[self.viewControllers objectAtIndex:0];
            [_ibo_omgVoteVC updateObjectInCollection:snap];
            break;
        case 1:
            _ibo_omgsnapVC = (OMGSnapViewController *)[self.viewControllers objectAtIndex:1];
            [_ibo_omgsnapVC updateObjectInCollection:snap];
            break;
        case 3:
            _ibo_mysnapsVC = (OMGMySnapsViewController *)[self.viewControllers objectAtIndex:3];
            [_ibo_mysnapsVC updateKarma];
            [_ibo_mysnapsVC updateObjectInCollection:snap];
            break;
        default:
            break;
    }
}

//LIGHTBOX DELEGATES
#pragma Share
- (void) lightBoxShareImage:(UIImage *)image {
    [self shareItem:image];
}

- (void) lightBoxItemFlagFromTab:(Snap *)flagItem {
    [self lightBoxItemFlag: flagItem];
}

#pragma FLAG
- (void) lightBoxItemFlag:(Snap *)flagItem {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PROMPT_FLAG_TITLE", nil)
                                                                         message:!flagItem.reported ? NSLocalizedString(@"PROMPT_FLAG_BODY", nil) : NSLocalizedString(@"PROMPT_ALREADY_FLAGED_BODY", nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action_spam = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_FLAG_ACTION", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self flagImage:flagItem];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:!flagItem.reported ? NSLocalizedString(@"PROMPT_FLAG_CANCEL", nil) : NSLocalizedString(@"OK_BUTTON", nil)
                                                     style:UIAlertActionStyleDefault handler:nil];

    if (!flagItem.reported) {
        [actionSheet addAction:action_spam];
    }
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void) flagImage:(Snap *)flagObject {
  [SnapServiceManager reportSnap:flagObject.ID OnSuccess:^(NSDictionary *responseObject) {
    [TAOverlay showOverlayWithLabel:NSLocalizedString(@"PUBLISH_DONE", nil) Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionAutoHide)];
  } OnFailure:^(NSError *error) {
    [TAOverlay showOverlayWithLabel:@"Oops! Try again later." Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError];
  }];
}

#pragma SHAREITEM
- (void)shareItem:(UIImage *)image {
    NSURL *url = [NSURL URLWithString:@"http://okjux.com/"];
    UIImage *imgData = image;
    
    NSArray *activityItems = [[NSArray alloc]  initWithObjects:imgData, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        _popController.popoverContentSize = CGSizeMake(self.view.frame.size.width/2, 800); //your custom size.
        [_popController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}


@end
