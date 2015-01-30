//
//  DismissSegue.m
//  iFreeThePostcode
//
//  Created by John McKerrell on 30/01/2015.
//
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
