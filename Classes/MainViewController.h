//
//  MainViewController.h
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PostCodeSubmitOperation.h"

@interface MainViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate> {
    IBOutlet UILabel *latitude, *longitude, *accuracy, *lastUpdated, *lockStatusDescription;
    IBOutlet UITextField *pcFirst, *pcSecond, *emailAddress, *activeField;
    IBOutlet UILabel *accuracyMessage;
    IBOutlet UIButton *submitBtn, *addressBookBtn, *infoBtn;
    IBOutlet UIActivityIndicatorView *activity;
    IBOutlet UISegmentedControl *lockStatus;
    CLLocation *currentLocation;
    BOOL updating, keyboardShown;
    NSOperationQueue *queue;
    NSTimer *timer;
}

- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)textFieldUpdated:(id)sender;
- (IBAction)textFieldBeganEditing:(id)sender;
- (IBAction)buttonClicked:(id)sender;
- (void)locationUpdated:(CLLocation*) newLocation;
- (void)updateViewStatus;
- (void)submissionResponse:(NSString*)response;
- (void)setPostcodeFirstPart:(NSString*)first secondPart:(NSString*)second;
- (IBAction)locationLockStatusChange:(id)sender;

@end
