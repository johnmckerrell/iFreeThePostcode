//
//  iFreeThePostcodeAppDelegate.m
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import "iFreeThePostcodeAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>

@implementation iFreeThePostcodeAppDelegate


@synthesize window;
@synthesize rootViewController;

/**
 * Simple function to pass test locations as the iPhone simulator
 * will only send one location in Cupertino. This version will
 * send one of three locations iterating over them each time
 * it's called. This is attached to testBtn which is normally hidden.
 */
- (void)testUpdateLocation
{
    static int toggle = 0;
    NSDate *now = [[NSDate alloc] init];
    CLLocation *loc;
    CLLocationCoordinate2D coord;
    switch( toggle ) {
    case 0:
        // Fleet Street @75m accuracy - (51.51431,-0.1082)
        coord.latitude = 51.51431;
        coord.longitude = -0.1082;
        loc = [[CLLocation alloc] initWithCoordinate:coord altitude:1000 horizontalAccuracy:75 verticalAccuracy:100 timestamp:now];
        break;
    case 1:
        // Fleet Street @49m accuracy - (51.51431,-0.1082)
        coord.latitude = 51.51431;
        coord.longitude = -0.1082;
        loc = [[CLLocation alloc] initWithCoordinate:coord altitude:1000 horizontalAccuracy:49 verticalAccuracy:100 timestamp:now];
        break;
    case 2:
        // Liverpool @100m accuracy - (53.40793,-2.98631)
        coord.latitude = 53.40793;
        coord.longitude = -2.98631;
        loc = [[CLLocation alloc] initWithCoordinate:coord altitude:1000 horizontalAccuracy:100 verticalAccuracy:100 timestamp:now];
        break;
    }
    // Increment and modulate the toggle
    toggle = ( toggle + 1 ) % 3;
    
    // Call our delegate function
    [self locationManager:locationManager didUpdateToLocation:loc fromLocation:loc];
    [now release];
    [loc release];
}

/**
 * This is the delegate function called by the location manager.
 * It should pass a reference to the manager and a reference
 * to the previous and current locations.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
    fromLocation:(CLLocation *)oldLocation
{
    MainViewController *controller = [[self rootViewController] mainViewController];
    [currentLocation release];
    currentLocation = newLocation;
    [currentLocation retain];
    NSLog( @"New location %@", newLocation );
    [controller locationUpdated:newLocation];
}

/**
 * Opens the link to freethepostcode.org in iPhone Safari.
 */
- (void)linkToSafari:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}

/**
 * If the iPhone passes us a URL in the format ifreethepostcode:EC4A+2DY
 * then decode the postcode and use it in the app.
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if( [[url scheme] isEqualToString:@"ifreethepostcode"] ) {
        NSString *url_str = [NSString stringWithFormat:@"%@",url];
        NSMutableString *postcode = [url_str mutableCopy];
        NSScanner* scanner = [NSScanner scannerWithString:url_str];
        [scanner setScanLocation:17];
        [scanner scanUpToString:@"" intoString:&postcode];
        postcode = [[postcode stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [postcode replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [postcode length])];
        
        NSString *firstHalf = [postcode mutableCopy];
        NSString *secondHalf = [postcode mutableCopy];
        scanner = [NSScanner scannerWithString:postcode];
        [postcode release];
        [scanner scanUpToString:@" " intoString:&firstHalf];
        [scanner scanUpToString:@"" intoString:&secondHalf];
        
        MainViewController *controller = [[self rootViewController] mainViewController];
        [controller setPostcodeFirstPart:firstHalf secondPart:secondHalf];
        return YES;
    }
    return NO;
}

/**
 * Function that calls when the app has finished loading.
 * We setup the location manager and tell it to start
 * updating us with the current location.
 */
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    window.rootViewController = rootViewController;
	[window makeKeyAndVisible];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

/**
 * This function is called when our postcode submission finishes
 * so we tell the main view controller that we're done and it'll
 * re-enable the submit button.
 */
- (void)submissionFinished:(NSString *) response {
    MainViewController *controller = [[self rootViewController] mainViewController];
    [controller submissionResponse: response];
}

/**
 * De-allocate the resources we've used.
 */
- (void)dealloc {
	[rootViewController release];
    [currentLocation release];
    [locationManager release];
	[window release];
	[super dealloc];
}

@end
