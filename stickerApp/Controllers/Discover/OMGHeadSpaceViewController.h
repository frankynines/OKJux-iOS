//
//  OMGHeadSpaceViewController.h
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class OMGHeadSpaceViewController;


@protocol OMGHeadSpaceViewControllerDelegate <NSObject>

- (void) centerMap;

@end


@interface OMGHeadSpaceViewController : OkJuxViewController

@property (nonatomic, weak) IBOutlet UILabel *ibo_titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *ibo_karmabtn;


- (void)updateKarma;
@property (nonatomic, unsafe_unretained) id <OMGHeadSpaceViewControllerDelegate> delegate;


@end
