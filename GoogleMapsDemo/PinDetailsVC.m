//
//  PinDetailsVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 11/7/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "PinDetailsVC.h"

@interface PinDetailsVC ()

@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation PinDetailsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Address label and button stuff
    self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAddress.numberOfLines = 4;
    self.btnDelete.layer.cornerRadius = 4;
    self.btnDelete.layer.borderWidth = 1;
    self.btnDelete.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnSaveChanges.layer.cornerRadius = 4;
    self.btnSaveChanges.layer.borderWidth = 1;
    self.btnSaveChanges.layer.borderColor = [UIColor blueColor].CGColor;
    
    // Set up Google Maps
    // Initialize google map view with camera position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.pinObject.latitude doubleValue] longitude:[self.pinObject.longitude doubleValue] zoom:16 bearing:0 viewingAngle:0];
    self.mapView = [GMSMapView mapWithFrame:self.mapContainer.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = NO;
    self.mapView.delegate = self;
    [self.mapView setMinZoom:12 maxZoom:18];

    // Get the pin details
    self.txtPinName.text = self.pinObject.name;
    self.lblAddress.text = self.pinObject.address;
    self.lblLatitude.text = [self.pinObject.latitude stringValue];
    self.lblLongitude.text = [self.pinObject.longitude stringValue];
    
    // Add views to main view
    [self.mapContainer addSubview:self.mapView];
    self.mapContainer.frame = CGRectMake(0, self.mapContainer.frame.origin.y, self.mapContainer.frame.size.width, self.mapContainer.frame.size.height);
    [self.view addSubview:self.mapContainer];
    
    // Create marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([self.pinObject.latitude doubleValue], [self.pinObject.longitude doubleValue]);
    marker.title = self.pinObject.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    // Add action for Done button
    [self.txtPinName addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // Gesture recognizer to hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Add share button to right side of nav
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(sharePin)];
    [self.navigationItem setRightBarButtonItem:share];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deletePin:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                     message:@"Are you sure you want to delete this pin?"
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

- (IBAction)saveChanges:(id)sender
{
    if (self.txtPinName.text && ![self.txtPinName.text isEqualToString:@""])
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"dateCreated=%@", self.pinObject.dateCreated];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:pred];
        
        NSError *error = nil;
        NSArray *result = [self.fetchedResultsController.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSManagedObject *pin = (NSManagedObject *)[result objectAtIndex:0];
        [pin setValue:self.txtPinName.text forKey:@"name"];
        
        NSError *saveError = nil;
        if (![pin.managedObjectContext save:&saveError]) {
            NSLog(@"Unable to save changes for pin.");
            NSLog(@"%@, %@", saveError, saveError.localizedDescription);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucess!" message:@"Changes successfully saved." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Save!" message:@"Pin name cannot be empty" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:self.indexPathOfObject];
        [self.fetchedResultsController.managedObjectContext deleteObject:managedObject];
        [self.fetchedResultsController.managedObjectContext save:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Hide keyboard when user taps something
-(void)dismissKeyboard
{
    [self.txtPinName resignFirstResponder];
}

// Hide keyboard when 'Done' is tapped
- (void)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

// Show ActionSheet of share options
- (void)sharePin
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Email", @"Facebook", @"Twitter", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

// Compose new email to send
- (void)composeEmail
{
    NSString *emailTitle = @"Check out this location";
    NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
    NSString *imgTag = [NSString stringWithFormat:@"<img src=https://maps.googleapis.com/maps/api/staticmap?zoom=16&size=290x200&key=AIzaSyC0fAHwD4w0rdPBBYxJlHQIbjUOD-2v4lc&markers=%@,%@>", self.pinObject.latitude, self.pinObject.longitude];
    NSString *messageBody = [NSString stringWithFormat:@"<p>I wanted to share this location with you. Its one of my favourite ones on the map.</p><p><b>Name:</b> %@<br><b>Latitude:</b> %@<br><b>Longitude:</b> %@<br><b>Address:</b> %@</p><a href=\"%@\">%@</a><p>I captured this location via the MyFavPins iPhone app.</p>",
                             self.pinObject.name, self.pinObject.latitude, self.pinObject.longitude, self.pinObject.address, pinURL, imgTag];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

// Create a new FB post
- (void)createFacebookPost
{
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
    params.link = [NSURL URLWithString:pinURL];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        // Put together the dialog parameters
        NSMutableDictionary *paramms = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Check out this cool location!!", @"name",
                                       self.pinObject.name, @"caption",
                                       @"This is one of my favourite locations on a map.", @"description",
                                       pinURL, @"link",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:paramms
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

// Create new Twitter post
- (void)createTweet
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *tweetFormatted = [NSString stringWithFormat:@"Check out this cool location: %@. #MyFavPinsApp", self.pinObject.name];
        NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
        NSURL *staticImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?zoom=16&size=290x200&key=AIzaSyC0fAHwD4w0rdPBBYxJlHQIbjUOD-2v4lc&markers=%@,%@", self.pinObject.latitude, self.pinObject.longitude]];
        UIImage *mapImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:staticImageURL]];
        [tweetSheet setInitialText:tweetFormatted];
        [tweetSheet addURL:[NSURL URLWithString:pinURL]];
        [tweetSheet addImage:mapImage];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Twitter Login"
                                                         message:@"Please login to Twitter on your phone first, then try again."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        
        [alert show];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)  // Email
    {
        NSLog(@"Share via Email");
        
        [self composeEmail];
    }
    else if (buttonIndex == 1) // Facebook
    {
        NSLog(@"Share via Facebook");
        
        [self createFacebookPost];
    }
    else if (buttonIndex == 2) // Twitter
    {
        NSLog(@"Share via Twitter");
        
        [self createTweet];
    }
}

#pragma mark MFMailComposeViewControllerDelegate delegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
