//
//  iFreeThePostcodeAppDelegate.h
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface iFreeThePostcodeAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	IBOutlet UIWindow *window;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (nonatomic, strong) UIWindow *window;

- (void)submissionFinished:(NSString *) response;

- (void)testUpdateLocation;

- (void)linkToSafari:(NSString *)url;

@end

