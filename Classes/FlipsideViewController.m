//
//  FlipsideViewController.m
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import "FlipsideViewController.h"
#import "iFreeThePostcodeAppDelegate.h"

@implementation FlipsideViewController

/**
 * This is the only thing added to this file.
 */

/**
 * Tell iPhone Safari to show freethepostcode.org
 */
- (IBAction)linkClicked:(id)sender {
     id appDelegate = [[UIApplication sharedApplication] delegate];
     [appDelegate linkToSafari:@"http://www.freethepostcode.org"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
	//self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];		
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}




@end
