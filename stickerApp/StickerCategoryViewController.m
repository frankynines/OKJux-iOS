//
//  StickerCategoryViewController.m
//  catwang
//
//  Created by Fonky on 1/14/15.
//
//

#import "StickerCategoryViewController.h"
#import "StickerCategoryViewCell.h"

#import "SelectStickerQuickViewController.h"
#import "StickerCellCollectionViewCell.h"

#import "CWInAppHelper.h"
#import "TAOverlay.h"

@interface StickerCategoryViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SelectStickerQuickViewControllerDelegate>{

    
}

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView_recents;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;

@property (nonatomic, strong) NSArray * prop_stickerIDs;
@property (nonatomic, strong) NSDictionary * prop_stickerPacks;

@end

@implementation StickerCategoryViewController
@synthesize delegate;
@synthesize ibo_collectionView;

- (void)viewDidLoad {
    
    self.title = NSLocalizedString(@"PACK_TITLE", nil);
    
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTintColor:[UIColor magentaColor]];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        
    } else {
        
        _topMarginConstraint.constant = -44;
        
    }

   
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.toolbar.translucent = YES;
    
    _prop_stickerIDs = [[CBJSONDictionary shared] getBundleIDs];
    //NSLog(@"Sticker IDS %@", _prop_stickerIDs);
    
    _prop_stickerPacks = [[CBJSONDictionary shared] getBundleNameID];
    
    
    
    
    
    //BUTTONS FOR NAVBAR
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PACK_RESTORE", nil) style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(iba_restorePurchases:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PACK_DONE", nil) style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(iba_dismissCategoryView:)];
    
    
    
    
    
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    if (![[CWInAppHelper sharedHelper] products]){
        //NSLog(@"ALL IAP IDS %@", [[CBJSONDictionary shared] getAllPackIDs]);
        [[CWInAppHelper sharedHelper] startRequest:[[CBJSONDictionary shared] getAllPackIDs]];

    } else {
    
        self.navigationItem.leftBarButtonItem.enabled = YES;
    
    }

    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CWIAP_Restore
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [TAOverlay showOverlayWithLabel:@"" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionAutoHide)];
                                                      });
                                                      
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CWIAP_ProductsAvailable
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      self.navigationItem.leftBarButtonItem.enabled = YES;
                                                      
                                                  }];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iba_dismissCategoryView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)iba_restorePurchases:(id)sender{

    NSLog(@"Restore Purchases");
    [[CWInAppHelper sharedHelper] restore_purchases];
    
}


#pragma CollectionView Delegates
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //NSLog(@"ITEMS COUNT %d", [_prop_stickerPacks count]);
    return [_prop_stickerPacks count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    StickerCategoryViewCell *categoryCell = (StickerCategoryViewCell *)[collectionView
                                                                            dequeueReusableCellWithReuseIdentifier:@"categorycell"
                                                                            forIndexPath:indexPath];

    NSString *catName = [_prop_stickerPacks objectForKey:[_prop_stickerIDs objectAtIndex:indexPath.item]];
    categoryCell.ibo_categoryTitle.text = nil;
    categoryCell.ibo_categoryTitle.text = catName;
    
    [[CBJSONDictionary shared] getBundleHeroImageFromID:[_prop_stickerIDs objectAtIndex:indexPath.item]
                                             withReturn:^(NSURL *heroURL) {
        categoryCell.imageURL = heroURL;
        
    
                                             
    }];
    
    //NSLog(@"ITEMS PAGE %d", indexPath.item);
    
    //set offset accordingly
    CGFloat yOffset = ((ibo_collectionView.contentOffset.y - categoryCell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    categoryCell.imageOffset = CGPointMake(0.0f, yOffset);
    
    return categoryCell;
    
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for(StickerCategoryViewCell *view in ibo_collectionView.visibleCells) {
        
        CGFloat yOffset = ((ibo_collectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
        
    }
    
}



- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    StickerCategoryViewCell *categoryCell = (StickerCategoryViewCell *)[collectionView
                                                                        dequeueReusableCellWithReuseIdentifier:@"categorycell"
                                                                        forIndexPath:indexPath];

    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"StickerSelectStoryboard" bundle:[NSBundle mainBundle]];
    
    SelectStickerQuickViewController *newController = (SelectStickerQuickViewController *)[mainSB instantiateViewControllerWithIdentifier:@"seg_SelectStickerQuickViewController"];
    newController.delegate = self;
    newController.prop_bundleID = [_prop_stickerIDs objectAtIndex:indexPath.item];
    newController.prop_bundleName = [_prop_stickerPacks objectForKey:[_prop_stickerIDs objectAtIndex:indexPath.item]];
    newController.prop_BGImage = categoryCell.ibo_categoryHero.image;
    [self.navigationController pushViewController:newController animated:YES];


}



//SIZE
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(ibo_collectionView.frame.size.width, 140);
    
}

//STICKERSELECT DELEGATES
-(void) selectStickerPackQuickViewController:(SelectStickerQuickViewController *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID{
    
    NSLog(@"STICKER CATEGORY STICKER");
    [self.delegate stickerCategory:self didFinishPickingStickerImage:image withPackID:packID];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/






@end