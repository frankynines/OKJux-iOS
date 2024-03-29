//
//  OMGSnapHeaderView.m
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import "OMGSnapHeaderView.h"
#import "DataManager.h"
#import "SnapServiceManager.h"
#import "OMGMapAnnotation.h"
#import "OMGSnapLocationPicker.h"

@interface OMGSnapHeaderView () <MKMapViewDelegate, OMGSnapLocationPickerDelegate>
//UI
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) OMGSnapLocationPicker *locationPicker;


@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) BOOL didFinishPlacingTheAnnotations;
@property (nonatomic, strong) NSArray *snapsArray;
@end

@implementation OMGSnapHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.isFirstLoad = YES;
    self.mapView = [[MKMapView alloc] initWithFrame:self.frame];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self addSubview:self.mapView];

    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.center = self.center;
    [self addSubview:self.activityIndicator];

    self.locationPicker = [[OMGSnapLocationPicker alloc] initWithFrame:CGRectMake(0, -100, self.bounds.size.width, 100)];
    self.locationPicker.hidden = YES;
    self.locationPicker.delegate = self;
    [self addSubview:self.locationPicker];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.activityIndicator.center = self.center;
    self.mapView.frame = self.bounds;
    self.locationPicker.frame = CGRectMake(0, self.locationPicker.frame.origin.y, self.frame.size.width, self.locationPicker.frame.size.height);
}

#pragma mark - 
#pragma mark Fetch Data

- (void)fetchSnapsByCoordinates:(CLLocationCoordinate2D)coodinates {

    NSString *currentLat = [NSString stringWithFormat:@"%f", coodinates.latitude];
    NSString *currentLong = [NSString stringWithFormat:@"%f", coodinates.longitude];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user_id"] = [DataManager userID];
    params[@"lat"] = currentLat;
    params[@"lng"] = currentLong;
    params[@"radius"] = [NSString stringWithFormat:@"%f", (long)kMinDistance * metersInMile];

    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    [SnapServiceManager getSnapsNearBy:params OnSuccess:^(NSArray* responseObject) {
        self.snapsArray = [responseObject copy];
        [self.activityIndicator stopAnimating];
        [self loadMapData];
    } OnFailure:^(NSError *error) {
        [self.activityIndicator stopAnimating];
    }];
}

- (void)loadMapData {

    [self.mapView removeAnnotations:self.mapView.annotations];

    __block int count = 1;
    for (Snap *snap in self.snapsArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:snap.thumbnailUrl]];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image  = [UIImage imageWithData:imageData];
                NSArray *geoPoint = snap.location;
                CLLocationCoordinate2D coord;
                coord.latitude = [geoPoint[0] doubleValue];
                coord.longitude = [geoPoint[1] doubleValue];

                OMGMapAnnotation *anno = [[OMGMapAnnotation alloc] initWithCoordinates:coord andTitle:@"turkey" andThumbNail:image];
                anno.snap = snap;
                [self.mapView addAnnotation:anno];

                if (count == self.snapsArray.count)
                    [self zoomToFitMapAnnotations];
                else
                    count++;
            });
        });
    }

}

#pragma mark - 
#pragma mark Utils

-(void)zoomToFitMapAnnotations
{
//    self.didFinishPlacingTheAnnotations = YES;
//    if([self.mapView.annotations count] == 0)
//        return;
//
//    MKMapRect zoomRect = MKMapRectNull;
//    for (id <MKAnnotation> annotation in _mapView.annotations)
//    {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//        zoomRect = MKMapRectUnion(zoomRect, pointRect);
//    }
//    [_mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void)centerMap {
//    if (/*!self.didFinishPlacingTheAnnotations && */)
//        return;
//    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[DataManager currentLatitud] doubleValue];
    zoomLocation.longitude= [[DataManager currentLongitud] doubleValue];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    [self.mapView setRegion:[self.mapView regionThatFits:viewRegion] animated:YES];

    if (self.isFirstLoad) {
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[DataManager currentLatitud] doubleValue], [[DataManager currentLongitud] doubleValue]);
        [self fetchSnapsByCoordinates: coordinates];
    }
}

- (void)showLocationPicker {
    self.locationPicker.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.locationPicker.frame = CGRectMake(0, 0, self.frame.size.width, self.locationPicker.frame.size.height);
    }];

}
- (void)hideLocationPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.locationPicker.frame = CGRectMake(0, -self.locationPicker.frame.size.height, self.frame.size.width, self.locationPicker.frame.size.height);
    } completion:^(BOOL finished) {
        self.locationPicker.hidden = YES;
    }];
}


#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (self.isFirstLoad) {
        [self centerMap];
        self.isFirstLoad = NO;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[OMGMapAnnotation class]]) {
        OMGMapAnnotation *myAnno = (OMGMapAnnotation *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"com.anno"];
        annotationView = myAnno.annotationView;
        annotationView.canShowCallout = NO;

        return annotationView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[OMGMapAnnotation class]]) {
        OMGMapAnnotation *anno = view.annotation;
        [self.parent showFullScreenSnap:anno.snap preload:anno.thumbnail shouldShowVoter:NO];
    }
}

#pragma mark -
#pragma mark OMGSnapLocationPickerDelegate

- (void)OMGSnapLocationPicker:(OMGSnapLocationPicker*)snapLocationPicker didSelectLocationCoordinates:(CGPoint)coordinates {
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(coordinates.x,
                                                      coordinates.y);
    [self fetchSnapsByCoordinates:zoomLocation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];

}

@end
