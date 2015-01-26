//
//  iFreeThePostcodeAppDelegate.h
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RootViewController;

@interface iFreeThePostcodeAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet RootViewController *rootViewController;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *rootViewController;

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
    fromLocation:(CLLocation *)oldLocation;

- (void)submissionFinished:(NSString *) response;

- (void)testUpdateLocation;

- (void)linkToSafari:(NSString *)url;

@end

