//
//  PostCodeSubmitOperation.m
//  iFreeThePostcode
//
//  Created by John McKerrell on 27/10/2008.
//  Copyright 2008 MKE Computing Ltd. All rights reserved.
//

#import "PostCodeSubmitOperation.h"
#import "iFreeThePostcodeAppDelegate.h"


/**
 * This operation is used to submit the postcode to freethepostcode.org
 * We use an operation so that this network-intensive bit of code doesn't
 * interrupt the view.
 */
 @implementation PostCodeSubmitOperation

/**
 * Pass in the submission URL.
 */
- (id)initWithURL:(NSURL*)url;
{
    self = [super init];
    if (self) {
        submitURL = url;
    }
    return self;
}
 
- (void)dealloc {
    submitURL = nil;
}

/**
 * Simply retrieves the contents of the page then passes it back to the app.
 */
- (void)main {
    /**
     * Retrieve the contents of the URL.
     */
    NSString *webpageString = [[NSString alloc] initWithContentsOfURL:submitURL encoding:NSUTF8StringEncoding error:nil];
 
    /**
     * Retrieve a reference to the app and pass the content in.
     */
    id appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate performSelectorOnMainThread:@selector(submissionFinished:)
                                           withObject:webpageString
                                        waitUntilDone:YES];
}

@end
