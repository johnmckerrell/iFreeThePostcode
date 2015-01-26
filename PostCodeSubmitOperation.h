//
//  PostCodeSubmitOperation.h
//  iFreeThePostcode
//
//  Created by John McKerrell on 27/10/2008.
//  Copyright 2008 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostCodeSubmitOperation : NSOperation {
    NSURL *submitURL;
}

- (id)initWithURL:(NSURL*)url;

@end
