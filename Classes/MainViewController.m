//
//  MainViewController.m
//  iFreeThePostcode
//
//  Created by John McKerrell on 21/10/2008.
//  Copyright MKE Computing Ltd 2008. All rights reserved.
//

#import "MainViewController.h"
#import "iFreeThePostcodeAppDelegate.h"

@implementation MainViewController

/**
 * This is called when the view is loaded, now
 * we can initialise elements of the view.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * Are we submitting an update? NO
     */
    updating = NO;
    /**
     * Set our currentLocation to nil initially.
     */
    currentLocation = nil;
    /**
     * Set up the operations queue, we will use
     * this to submit the postcode in another thread.
     */
    queue = [[NSOperationQueue alloc] init];
    
    /**
     * Retrieve any user defaults that have been saved.
     */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    /**
     * Load the email address and the previous postcode from
     * the defaults.
     */
    [pcFirst setText: [userDefaults stringForKey:@"pcFirst"] ];
    [pcSecond setText: [userDefaults stringForKey:@"pcSecond"] ];
    [emailAddress setText: [userDefaults stringForKey:@"emailAddress"] ];
    [lockStatus setSelectedSegmentIndex: [[userDefaults stringForKey:@"lockStatus"] intValue] ];
    [self locationLockStatusChange:lockStatus];

    
    /**
     * Update the status of the submit button.
     */
    [self updateViewStatus];
    
//    CGRect frame = addressBookBtn.frame;
//    frame.origin.x -= 15;
//    frame.origin.y -= 15;
//    frame.size.width += 30;
//    frame.size.height += 30;
//    addressBookBtn.frame = frame;
    //[addressBookBtn setFrame:CGRectMake(262, 409, 58, 59)];
        

    timer = [NSTimer scheduledTimerWithTimeInterval:20
                                             target:self
                                           selector:@selector(checkForLocation)
                                           userInfo:nil
                                            repeats:NO];

}

/**
 * This function calls when the status of the location lock
 * is changed and allows us to change the text of the label.
 */
- (IBAction)locationLockStatusChange:(id)sender {
    NSLog( @"here - %d", (int)lockStatus.selectedSegmentIndex );
    switch ([lockStatus selectedSegmentIndex]) {
        case 0:
            lockStatusDescription.text = @"All location updates accepted";
            break;
        case 1:
            lockStatusDescription.text = @"More accurate locations accepted";
            break;
        case 2:
            lockStatusDescription.text = @"No location updates used";
            break;
    }
    /**
     * Retrieve a reference to the user defaults object
     * and set the value for this field.
     */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%d", (int)lockStatus.selectedSegmentIndex] forKey: @"lockStatus" ];


}

/**
 * This function is called when you click the
 * "Next" or "Done" button when editing a
 * text field. At this point we save the
 * entry in the user defaults. We also update
 * the status of the submit button.
 */
- (IBAction)textFieldUpdated:(id)sender {
    NSString *key = nil;
    UITextField *field = (UITextField*)sender;
    /**
     * The name of the key in the defaults depends
     * on the text field that sent the message.
     */
    if( sender == pcFirst ) {
        key = @"pcFirst";
    } else if( sender == pcSecond ) {
        key = @"pcSecond";
    } else if( sender == emailAddress ) {
        key = @"emailAddress";
    }
    if( key ) {
        /**
         * Retrieve a reference to the user defaults object
         * and set the value for this field.
         */
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[field text] forKey: key ];
    }
    
    /**
     * Update the status of the submit button, we might be
     * able to enable it now that the user has entered
     * some information.
     */
    [self updateViewStatus];
}

/**
 * Called when we begin editing a text field, we change the type of
 * the "Return" key depending on what's in the text fields.
 */
- (IBAction)textFieldBeganEditing:(id)sender {
    /**
     * We keep a reference to the currently active field.
     */
    NSLog(@"Setting activeField");
    activeField = sender;
    
    /**
     * Calculate the next field to be highlighted after
     * this one.
     */
    UITextField *nextField = nil;
    if( sender == pcFirst ) {
        nextField = pcSecond;
    } else if ( sender == pcSecond ) {
        nextField = emailAddress;
    } else if ( sender == emailAddress ) {
        nextField = pcFirst;
    }
    if( nextField ) {
        /**
        * If the next field has no text in it, then
        * we set the value of the "Return" key to "Next".
        * Otherwise we set it to "Done".
        */
        UITextField *textField = (UITextField*)sender;
        NSString *nextText = [nextField text];
        NSLog(@"Text field string is: %@", [textField text]);
        if( ! nextText || [nextText isEqualToString:@""] ) {
            [textField setReturnKeyType:UIReturnKeyNext];
            NSLog(@"Setting return key to Next");
        } else {
            [textField setReturnKeyType:UIReturnKeyDone];
            NSLog(@"Setting return key to Done");
        }
    }
}


/**
 * This function is called when the "Return" key is pressed
 * on the virtual keyboard. If the "Return" key is set to
 * show "Done" we hide the keyboard, if it is set to "Next"
 * then we pass focus to the next field.
 */
- (IBAction)textFieldDoneEditing:(id)sender {
    NSLog( @"returnKeyType=%i UIReturnKeyNext=%i UIReturnKeyDone=%i", (int)[sender returnKeyType], (int)UIReturnKeyNext, (int)UIReturnKeyDone );
    if( [sender returnKeyType] == UIReturnKeyNext ) {
        if( sender == pcFirst ) {
            [pcSecond becomeFirstResponder];
        } else if( sender == pcSecond ) {
            [emailAddress becomeFirstResponder];
        } else if( sender == emailAddress ) {
            [pcFirst becomeFirstResponder];
        }
    } else {
        [sender resignFirstResponder];
    }
}

/**
 * This function is attached to the buttons on the view and
 * is called when one of the buttons is clicked on.
 */
- (IBAction)buttonClicked:(id)sender {
    NSLog( @"Button clicked: %@", sender );
    if( sender == addressBookBtn ) {
        // Create an addressbook picker and present it,
        // this object will be the delegate.
        ABPeoplePickerNavigationController *picker =
                [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonAddressProperty]];
     
        [self presentViewController:picker animated:YES completion:nil];
    } else if( sender == submitBtn && currentLocation ) {
        /**
         * Submit the postcode.
         */
         
        /**
         * Set the flag that says we're updating.
         */
        updating = YES;
        
        /**
         * Update the submit button's status so the user
         * can't click it again.
         */
        [self updateViewStatus];
        
        /**
         * Generate the submission URL.
         */
            //http://www.freethepostcode.org/submit?email=someone%40example.com&lat=1.234567890&lon=1.234567890&postcode1=SW1A&postcode2=0AA
        NSLog( @"currentLocation=%@", currentLocation );

        NSLog( @"lat=%+.6f lon=%+.6f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude );
        NSString *urlString = [NSString stringWithFormat:@"http://www.freethepostcode.org/submit?email=%@&lat=%.6f&lon=%.6f&postcode1=%@&postcode2=%@",
            [[emailAddress text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            currentLocation.coordinate.latitude,
            currentLocation.coordinate.longitude,
            [[pcFirst text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [[pcSecond text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
        NSURL *url = [NSURL URLWithString:urlString];
        
        /**
         * Create a PostCodeSubmitOperation with the generated URL
         * and add it to our queue.
         */
        PostCodeSubmitOperation *plo = [[PostCodeSubmitOperation alloc] initWithURL:url];
        [queue addOperation:plo];
    }
}

/**
 * If the user cancels the addressbook picker then make sure
 * we hide it.
 */
- (void)peoplePickerNavigationControllerDidCancel:
            (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
 
 

/**
 * The user has clicked on a value within the person record.
 * The addresses are in a multi value property so identifier
 * will be zero or higher, we then check the type of the
 * property. If that's ok we look for a ZIP value, if there
 * is one then we parse it, set the postcode fields and hide
 * the address book picker.
 */
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if( identifier != -1 ) {
        ABPropertyType type = ABPersonGetTypeOfProperty(property);
        if( type == 261 ) {
            ABMultiValueRef ref = (__bridge ABMultiValueRef)((NSString*)CFBridgingRelease(ABRecordCopyValue(person, property)));
            CFDictionaryRef address = ABMultiValueCopyValueAtIndex(ref, identifier);
            
            if( CFDictionaryContainsKey(address, @"ZIP") ) {
                NSString *postcode = (NSString*)CFDictionaryGetValue(address, @"ZIP");
                NSString *firstHalf = [postcode substringToIndex:([postcode length]-3)];
                NSString *secondHalf = [postcode substringFromIndex:([postcode length]-3)];
                NSUInteger index = [firstHalf length];
                while( index > 0 ) {
                    if( [firstHalf characterAtIndex:index-1] != ' ' ) {
                        break;
                    }
                    --index;
                }
                firstHalf = [firstHalf substringToIndex:index];
                NSLog(@"firstHalf=%@ secondHalf=%@", firstHalf, secondHalf);
                if( ! ( [firstHalf isEqualToString:@""] || [secondHalf isEqualToString:@""] ) ) {
                    [self setPostcodeFirstPart:firstHalf secondPart:secondHalf];
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }
            }
        }
    }
}

/**
 * The user has clicked on a person, we will let them continue
 * on into the person's details so that they can then select
 * an address property that we can take the postcode from.
 */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

/**
 * Called when we get a submission response. It gets passed the
 * full contents of the HTML page which is then parsed to find
 * out what happened.
 */
- (void)submissionResponse:(NSString*)page {
    if( page && [page rangeOfString:@"You should have an email on its way to confirm"].location != NSNotFound) {
        [[[UIAlertView alloc] 
          initWithTitle:@"Success!" 
          message:@"You should get an email to confirm shortly." 
          delegate:self
          cancelButtonTitle:@"Close" 
          otherButtonTitles:nil]
         show];
    } else if( page ) {
        [[[UIAlertView alloc] 
          initWithTitle:@"Submission Failed" 
          message:@"We did not get a success message back from freethepostcode.org\nPlease make sure you have entered valid input." 
          delegate:self
          cancelButtonTitle:@"Close" 
          otherButtonTitles:nil]
         show];
    } else {
        [[[UIAlertView alloc] 
          initWithTitle:@"Submission Failed" 
          message:@"There was a problem accessing freethepostcode.org" 
          delegate:self
          cancelButtonTitle:@"Close" 
          otherButtonTitles:nil]
         show];
    }
    
    /**
     * Set the flag that says we're updating.
     */
    updating = NO;
    
    /**
     * Update the status of the submit button. It should now be
     * clickable if we have an accurate enough location.
     */
    [self updateViewStatus];
}

/**
 * Any unhandled touches on the display cause editing to stop
 * and the keyboard to hide.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog( @"touchesEnded" );
    [activeField resignFirstResponder];
}

/**
 * Makes sure we release UIAlertView objects when we're done with them
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

/**
 * Fills in the postcode fields.
 */
- (void)setPostcodeFirstPart:(NSString*)first secondPart:(NSString*)second {
    pcFirst.text = first;
    pcSecond.text = second;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:first forKey: @"pcFirst" ];
    [userDefaults setObject:second forKey: @"pcSecond" ];
}

/**
 * Called when the app delegate receives a new location.
 */
- (void)locationUpdated:(CLLocation *)newLocation {
    /**
     * If the user has locked the current location, ignore any updates.
     */

    CLLocationAccuracy acc = [newLocation horizontalAccuracy];
    
    /**
     * Handle the locking status, discard if we're fully locked or
     * if we're partially locked, check the accuracy.
     */
    if( lockStatus.selectedSegmentIndex == 2 ) {
        return;
    } else if( currentLocation && lockStatus.selectedSegmentIndex == 1 ) {
        CLLocationAccuracy oldAcc = [currentLocation horizontalAccuracy];
        // No more accurate, discard
        if( oldAcc <= acc ) {
            return;
        }
    }

    /**
     * Check that this location came within the last 5 minutes.
     */
    NSTimeInterval interval = [[newLocation timestamp] timeIntervalSinceNow];
    NSLog( @"timestamp=%f", interval );
    if( interval < -300 ) {
        return;
    }

    /**
     * Update the views to reflect the new location's information.
     */
    [latitude setText:[NSString stringWithFormat: @"%+.6f", newLocation.coordinate.latitude]];
    [longitude setText:[NSString stringWithFormat: @"%+.6f", newLocation.coordinate.longitude]];
    [accuracy setText:[NSString stringWithFormat:@"%.0f m", acc]];
    
    /**
     * Keep a reference to this location.
     */
    currentLocation = newLocation;
    
    /**
     * Update the status of the submit button.
     */
    [self updateViewStatus];
}

/**
 * Checks whether we've got a location yet and if not alerts the user
 * that something is taking a long time.
 */
- (void)checkForLocation
{
    if( ! currentLocation ) {
        [[[UIAlertView alloc]
           initWithTitle:@"Location problem"
           message:@"It is taking a long time to detect your location. Please make sure you have an internet connection and location services are turned on." 
           delegate:self
           cancelButtonTitle:@"Close" 
           otherButtonTitles:nil]
          show];
    }
    timer = nil;
}

/**
 * Updates the status of the view depending on the accuracy of the 
 * currently stored location. Updates the submit button, the timestamp
 * and the colour of the accuracy.
 * Also sets the activity control animating. 
 */
- (void)updateViewStatus{

    /**
     * This default accuracy is just used for testing,
     * should be overwritten in most cases though.
     */
    CLLocationAccuracy acc = 200;
    if( currentLocation ) {
        acc = [currentLocation horizontalAccuracy];
        NSLog( @"current location = %@", currentLocation );
    }
    
    /**
     * Updates the timestamp to display when the most recent location
     * was received.
     */
    if( ! currentLocation ) {
        [lastUpdated setText:@"Last updated: Loading..."];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [lastUpdated setText:[NSString stringWithFormat:@"Last updated: %@", [dateFormatter stringFromDate:[currentLocation timestamp]]]];
    }

    /**
     * If the text fields are not empty and we have an accurate
     * location, and we're not already submitting, then set the submit
     * button to be enabled, otherwise set it to be disabled.
     */
    //NSLog(@"acc=%f updating=%@", acc, updating);
    if( updating ) {
        [submitBtn setEnabled:NO];
        [submitBtn setHidden:NO];
        [accuracyMessage setHidden:YES];
    } else if( [emailAddress.text length] && [pcFirst.text length] && [pcSecond.text length]
     && acc < 50 ) {
        NSLog(@"Enabled");
        [submitBtn setEnabled:YES];
        [submitBtn setHidden:NO];
        [accuracyMessage setHidden:YES];
    } else {
        NSLog(@"Disabled - %@", [pcFirst text] );
        //[submitBtn setEnabled:NO];
        [submitBtn setHidden:YES];
        [accuracyMessage setHidden:NO];
    }
    
    /**
     * Set the colour of the accuracy label to red or green.
     */
    if( acc < 50 ) {
        [accuracy setTextColor:[UIColor greenColor]];
    } else {
        [accuracy setTextColor:[UIColor redColor]];
    }
    
    /**
     * If we are updating (submitting) then show the activity control
     * and start it animating.
     */
    if( updating ) {
        [activity startAnimating];
        [activity setHidden:NO];
    } else {
        [activity setHidden:YES];
        [activity stopAnimating];
    }

}


/**
 * Not really much we can do if we receive a memory warning.
 */
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

/**
 * De-allocating, so we release the current location and the queue.
 */
- (void)dealloc {
    currentLocation = nil;
    queue = nil;
}


@end
