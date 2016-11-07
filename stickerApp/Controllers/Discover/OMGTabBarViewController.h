//
//  OMGTabBarViewController.h
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import <UIKit/UIKit.h>
#import "OMGHeadSpaceViewController.h"

@interface OMGTabBarViewController : UITabBarController

@property (nonatomic, strong) OMGHeadSpaceViewController *ibo_headSpace;



- (void)shareItem:(UIImage *)image;
- (void)showSnapFullScreen:(PFObject *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;
- (void) lightBoxItemFlag:(PFObject *)flagItem;

- (BOOL) checkUserInArray:(NSMutableArray *)array;

@end