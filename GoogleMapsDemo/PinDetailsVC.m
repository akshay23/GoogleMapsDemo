//
//  PinDetailsVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 11/7/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "PinDetailsVC.h"
#import "AHKActionSheet.h"
#import "MBProgressHud.h"

@implementation PinDetailsVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Address label and button stuff
  self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
  self.lblAddress.numberOfLines = 4;
  
  // Set up Google Maps
  // Initialize google map view with camera position
  self.mainMapView.mapType = kGMSTypeNormal;
  self.mainMapView.myLocationEnabled = YES;
  self.mainMapView.settings.myLocationButton = YES;
  self.mainMapView.delegate = self;
  [self.mainMapView setMinZoom:12 maxZoom:18];
  
  // Make buttons look nice
  [self.btnSaveChanges setShadowHeight:4.0f];
  [self.btnSaveChanges setButtonColor:[UIColor peterRiverColor]];
  [self.btnSaveChanges setShadowColor:[UIColor belizeHoleColor]];
  [self.btnSaveChanges setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [self.btnSaveChanges setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  
  [self.btnDelete setShadowHeight:4.0f];
  [self.btnDelete setButtonColor:[UIColor alizarinColor]];
  [self.btnDelete setShadowColor:[UIColor pomegranateColor]];
  [self.btnDelete setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [self.btnDelete setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  
  // Get the pin details
  self.txtPinName.text = self.pinObject.name;
  self.lblAddress.text = self.pinObject.address;
  self.lblLatitude.text = [self.pinObject.latitude stringValue];
  self.lblLongitude.text = [self.pinObject.longitude stringValue];
  
  // Create marker
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.position = CLLocationCoordinate2DMake([self.pinObject.latitude doubleValue], [self.pinObject.longitude doubleValue]);
  marker.title = self.pinObject.name;
  marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
  marker.appearAnimation = kGMSMarkerAnimationPop;
  marker.map = self.mainMapView;
  
  // Add action for Done button
  [self.txtPinName addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
  
  // Gesture recognizer to hide keyboard
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.view addGestureRecognizer:tap];
  
  // Add custom left navi button
  UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Back to List" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
  [left configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [left setTintColor:[UIColor cloudsColor]];
  self.navigationItem.leftBarButtonItem = left;
  
  // Add share button to right side of nav
  UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(sharePin)];
  [share configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [share setTintColor:[UIColor cloudsColor]];
  self.navigationItem.rightBarButtonItem = share;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.pinObject.latitude doubleValue]
                                                          longitude:[self.pinObject.longitude doubleValue] zoom:18 bearing:0 viewingAngle:0];
  [self.mainMapView animateToCameraPosition:camera];

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)deletePin:(id)sender
{
  FUIAlertView * alertView = [[FUIAlertView alloc] initWithTitle:@"Confirm Delete"
                                                   message:@"Are you sure you want to delete this pin?"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes", nil];
  
  alertView.titleLabel.textColor = [UIColor cloudsColor];
  alertView.messageLabel.textColor = [UIColor cloudsColor];
  alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
  alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
  alertView.defaultButtonColor = [UIColor cloudsColor];
  alertView.defaultButtonShadowColor = [UIColor asbestosColor];
  alertView.defaultButtonTitleColor = [UIColor asbestosColor];
  [alertView show];
}

- (IBAction)saveChanges:(id)sender
{
  FUIAlertView *alertView;
  if (self.txtPinName.text && ![self.txtPinName.text isEqualToString:@""])
  {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"dateCreated=%@", self.pinObject.dateCreated];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.delegate.fetchedResultsController.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:pred];
    
    NSError *error = nil;
    NSArray *result = [self.delegate.fetchedResultsController.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSManagedObject *pin = (NSManagedObject *)[result objectAtIndex:0];
    [pin setValue:self.txtPinName.text forKey:@"name"];
    
    NSError *saveError = nil;
    if (![pin.managedObjectContext save:&saveError]) {
      NSLog(@"Unable to save changes for pin.");
      NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
    
    self.pinObject = [self.delegate.fetchedResultsController objectAtIndexPath:self.indexPathOfObject];
    
    alertView = [[FUIAlertView alloc] initWithTitle:@"Success"
                                            message:@"Changes successfully saved."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
  }
  else
  {
    alertView = [[FUIAlertView alloc] initWithTitle:@"Can't Save!"
                                            message:@"Pin name cannot be empty!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
  }
  
  alertView.titleLabel.textColor = [UIColor cloudsColor];
  alertView.messageLabel.textColor = [UIColor cloudsColor];
  alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
  alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
  alertView.defaultButtonColor = [UIColor cloudsColor];
  alertView.defaultButtonShadowColor = [UIColor asbestosColor];
  alertView.defaultButtonTitleColor = [UIColor asbestosColor];
  [alertView show];
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    NSManagedObject *managedObject = [self.delegate.fetchedResultsController objectAtIndexPath:self.indexPathOfObject];
    [self.delegate.fetchedResultsController.managedObjectContext deleteObject:managedObject];
    [self.delegate.fetchedResultsController.managedObjectContext save:nil];
    [self.navigationController popViewControllerAnimated:YES];
  }
}

// Hide keyboard when user taps something
-(void)dismissKeyboard
{
  [self.txtPinName setText:self.pinObject.name];
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
  // Hide keyboard if showing
  [self dismissKeyboard];
  
  AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Share via"];
  
  [actionSheet addButtonWithTitle:@"Email" image:[UIImage imageNamed:@"EmailIcon"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
    NSLog(@"Email share option tapped");
    [self composeEmail];
  }];
  
  [actionSheet addButtonWithTitle:@"Twitter" image:[UIImage imageNamed:@"TwitterIcon"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
    NSLog(@"Twitter share option tapped");
    [self createTweet];
  }];
  
  [actionSheet addButtonWithTitle:@"Facebook" image:[UIImage imageNamed:@"FacebookIcon"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
    NSLog(@"Facebook share option tapped");
    [self createFacebookPost];
  }];
  
  [actionSheet show];
}

// Compose new email to send
- (void)composeEmail
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.mode = MBProgressHUDModeIndeterminate;
  hud.labelText = @"Loading";
  
  NSString *emailTitle = @"Check out this location";
  NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
  NSString *imgTag = [NSString stringWithFormat:@"<img src=https://maps.googleapis.com/maps/api/staticmap?zoom=16&size=290x200&key=AIzaSyC0fAHwD4w0rdPBBYxJlHQIbjUOD-2v4lc&markers=%@,%@>", self.pinObject.latitude, self.pinObject.longitude];
  NSString *messageBody = [NSString stringWithFormat:@"<p>I wanted to share this location with you. Its one of my favourite ones on the map.</p><p><b>Name:</b> %@<br><b>Latitude:</b> %@<br><b>Longitude:</b> %@<br><b>Address:</b> %@</p><a href=\"%@\">%@</a><p>I captured this location via the MyFavPins iPhone app.</p>",
                           self.pinObject.name, self.pinObject.latitude, self.pinObject.longitude, self.pinObject.address, pinURL, imgTag];
  MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
  mc.mailComposeDelegate = self;
  [mc setSubject:emailTitle];
  [mc setMessageBody:messageBody isHTML:YES];
  [hud hide:YES];
  
  // Present mail view controller on screen
  [self presentViewController:mc animated:YES completion:NULL];
}

// Create a new FB post
- (void)createFacebookPost
{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.mode = MBProgressHUDModeIndeterminate;
  hud.labelText = @"Loading";
  
  NSString *postFormatted = [NSString stringWithFormat:@"Check out this cool location: %@", self.pinObject.name];
  NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
  
  FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
  content.contentURL = [NSURL URLWithString:pinURL];
  content.contentTitle = postFormatted;
  
  [hud hide:YES];
  
  [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
}

// Create new Twitter post
- (void)createTweet
{
  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
  {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *tweetFormatted = [NSString stringWithFormat:@"Check out this cool location: %@. #MyFavPinsApp", self.pinObject.name];
    NSString *pinURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.pinObject.latitude, self.pinObject.longitude];
    NSURL *staticImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?zoom=16&size=290x200&key=AIzaSyC0fAHwD4w0rdPBBYxJlHQIbjUOD-2v4lc&markers=%@,%@", self.pinObject.latitude, self.pinObject.longitude]];
    UIImage *mapImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:staticImageURL]];
    [tweetSheet setInitialText:tweetFormatted];
    [tweetSheet addURL:[NSURL URLWithString:pinURL]];
    [tweetSheet addImage:mapImage];
    [hud hide:YES];
    
    [self presentViewController:tweetSheet animated:YES completion:nil];
  }
  else
  {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Twitter Login"
                                                          message:@"Please login to Twitter on your device first, then try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
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
    [kv[1] stringByRemovingPercentEncoding];
    params[kv[0]] = val;
  }
  return params;
}

// Pops controller with custom animation
- (void)goBack
{
  [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark FBSDKSharingDelegate delegate

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
  NSLog(@"FB share failed with error %@", error.debugDescription);
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
  NSLog(@"Location was shared on FB successfully");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
  NSLog(@"User cancelled FB share");
}

@end
