//
//  CityMapVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 10/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CityMapVC.h"
#import "UIFont+FlatUI.h"

@interface CityMapVC ()

@property BOOL viewInHalf;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) GMSMarker *currentMarker;
@property (strong, nonatomic) NSString *currentAddress;
@property (strong, nonatomic) SavedPinsTVC *savedPinsTVC;

@end

@implementation CityMapVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Storyboard
  if (![GlobalData getInstance].mainStoryboard)
  {
    // Instantiate new main storyboard instance
    [GlobalData getInstance].mainStoryboard = self.storyboard;
    NSLog(@"mainStoryboard instantiated");
  }
  self.savedPinsTVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"savedPinsTVC"];
  self.savedPinsTVC.delegate = self;
  
  // Get current location
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  // Setup map
  self.mainMapView.mapType = kGMSTypeNormal;
  self.mainMapView.myLocationEnabled = YES;
  self.mainMapView.settings.myLocationButton = YES;
  self.mainMapView.delegate = self;
  [self.mainMapView setMinZoom:12 maxZoom:18];
  
  // Address label and button stuff
  self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
  self.lblAddress.numberOfLines = 4;
  
  // Button and text box setup
  [self.txtPinName setFont:[UIFont flatFontOfSize:15]];
  [self.txtPinName setBackgroundColor:[UIColor clearColor]];
  [self.txtPinName.layer setCornerRadius:2.0];
  [self.txtPinName.layer setBorderWidth:1.0];
  [self.txtPinName addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
  
  [self.btnSavePin setShadowHeight:4.0f];
  [self.btnSavePin setButtonColor:[UIColor peterRiverColor]];
  [self.btnSavePin setShadowColor:[UIColor belizeHoleColor]];
  [self.btnSavePin setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [self.btnSavePin setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  [self.btnSavePin setEnabled:NO];
  
  [self.bntClear setShadowHeight:4.0f];
  [self.bntClear setButtonColor:[UIColor concreteColor]];
  [self.bntClear setShadowColor:[UIColor asbestosColor]];
  [self.bntClear setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
  [self.bntClear setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
  [self.bntClear setEnabled:NO];

  // Core Data setup
  self.appDelegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [self.appDelegate managedObjectContext];
  
  // Gesture recognizer to hide keyboard
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.view addGestureRecognizer:tap];
  
  // Add bar button to nav bar
  UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"View Saved Pins" style:UIBarButtonItemStylePlain target:self action:@selector(viewSavedPins)];
  [right configureFlatButtonWithColor:[UIColor peterRiverColor] highlightedColor:[UIColor belizeHoleColor] cornerRadius:3];
  [right setTintColor:[UIColor cloudsColor]];
  self.navigationItem.rightBarButtonItem = right;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
  if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
      authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
  {
    [self.locationManager startUpdatingLocation];
  }
  else
  {
    [self.locationManager requestWhenInUseAuthorization];
  }
  
  // Hide text controls
  [self.mapBottomConstraint setConstant:30];
  [self.myScrollView setHidden:YES];
  [self.lblInfo setHidden:NO];
  
  [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self deregisterFromKeyboardNotifications];
  
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// Adjust padding for map view
- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 50, 0, self.bottomLayoutGuide.length + 30, 0);
}

// Custom marker info window
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
  UIView *infoWindow = [[UIView alloc] init];
  infoWindow.frame = CGRectMake(0, 0, 200, 70);
  infoWindow.backgroundColor = [UIColor grayColor];
  
  UILabel *title = [[UILabel alloc] init];
  title.frame = CGRectMake(14, 12, 175, 16);
  title.text = marker.title;
  title.textColor = [UIColor whiteColor];
  [infoWindow addSubview:title];
  
  UILabel *snippet = [[UILabel alloc] init];
  snippet.frame = CGRectMake(14, 42, 175, 20);
  snippet.text = marker.snippet;
  snippet.textColor = [UIColor greenColor];
  [infoWindow addSubview:snippet];
  
  return infoWindow;
}

// Hide keyboard when 'Done' is tapped
- (void)textFieldFinished:(id)sender
{
  [sender resignFirstResponder];
}

// Move to next view to see saved pins
- (void)viewSavedPins
{
  if (self.currentMarker)
  {
    self.currentMarker.map = nil;
    self.currentMarker = nil;
  }
  
  self.viewInHalf = NO;
  
  // Custom transition
  [UIView animateWithDuration:0.75 animations:^
  {
     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
  }];

  [self.savedPinsTVC setManagedObjectContext:self.managedObjectContext];
  [self.txtPinName resignFirstResponder];
  [self.navigationController pushViewController:self.savedPinsTVC animated:YES];
}

// Hide keyboard when user taps something
-(void)dismissKeyboard
{
  [self.txtPinName resignFirstResponder];
}

// Save to CoreData
- (void)saveToCoreData:(MyPin *)pin
{
  NSEntityDescription *entityList = [NSEntityDescription entityForName:@"MyPin" inManagedObjectContext:self.managedObjectContext];
  NSManagedObject *newPin = [[NSManagedObject alloc] initWithEntity:entityList insertIntoManagedObjectContext:self.managedObjectContext];
  [newPin setValue:pin.name forKey:@"name"];
  [newPin setValue:pin.address forKey:@"address"];
  [newPin setValue:pin.dateCreated forKey:@"dateCreated"];
  [newPin setValue:pin.latitude forKey:@"latitude"];
  [newPin setValue:pin.longitude forKey:@"longitude"];
  
  NSError *error = nil;
  if (![newPin.managedObjectContext save:&error])
  {
    NSLog(@"Unable to save new pin.");
    NSLog(@"%@, %@", error, error.localizedDescription);
  }
}

- (void)keyboardWasShown:(NSNotification *)notification
{
  NSDictionary* info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  
  [self.mapBottomConstraint setConstant:self.mapBottomConstraint.constant + (keyboardSize.height - 220)];
  [self.view setNeedsUpdateConstraints];
  
  [UIView animateWithDuration:0.25f animations:^{
    [self.view layoutIfNeeded];
  }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
  [self.mapBottomConstraint setConstant:280];
  [self.view setNeedsUpdateConstraints];
  
  [UIView animateWithDuration:0.25f animations:^{
    [self.view layoutIfNeeded];
  }];

}

- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)deregisterFromKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

#pragma mark - IBActions

// Add to array
- (IBAction)SavePin:(id)sender
{
  if (![self.txtPinName.text isEqualToString:@""] && self.currentMarker)
  {
    MyPin *pin = [[MyPin alloc] initWithDetails:self.txtPinName.text
                                       latitude:[NSNumber numberWithDouble:self.currentMarker.position.latitude]
                                      longitude:[NSNumber numberWithDouble:self.currentMarker.position.longitude]
                                        address:self.currentAddress];
    
    [self saveToCoreData:pin];
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Pin Saved"
                                                          message:@"Pin was successfully saved!"
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
    
    self.currentMarker.map = nil;
    self.currentMarker = nil;
    self.currentAddress = nil;
    self.txtPinName.text = @"";
    self.lblAddress.text = @"";
    self.lblLatitude.text = @"";
    self.lblLongitude.text = @"";
    self.btnSavePin.enabled = NO;
    self.bntClear.enabled = NO;
    [self.txtPinName resignFirstResponder];
    
    // Hide everything but the map
    self.myScrollView.hidden = YES;
    self.viewInHalf = NO;
    self.lblInfo.hidden = NO;

    // Increase map container height
    [self.mapBottomConstraint setConstant:30];
    
    NSLog(@"Pin added to set.");
  }
  else
  {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Pin was NOT saved! Please enter a name."
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
    
    NSLog(@"Pin was not added.");
  }
}

// Clear fields
- (IBAction)ClearInfo:(id)sender
{
  if (self.currentMarker)
  {
    self.currentMarker.map = nil;
    self.currentMarker = nil;
  }
  
  self.txtPinName.text = @"";
  self.lblAddress.text = @"";
  self.lblLatitude.text = @"";
  self.lblLongitude.text = @"";
  
  self.btnSavePin.enabled = NO;
  self.bntClear.enabled = NO;
  
  // Hide everything but the map
  self.myScrollView.hidden = YES;
  self.viewInHalf = NO;
  self.lblInfo.hidden = NO;
  
  // Increase map container height
  [self.mapBottomConstraint setConstant:30];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if (status == kCLAuthorizationStatusAuthorizedAlways ||
      status == kCLAuthorizationStatusAuthorizedWhenInUse)
  {
    [manager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  NSLog(@"Stopped updating location");
  [manager stopUpdatingLocation];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locations.firstObject.coordinate.latitude
                                                          longitude:locations.firstObject.coordinate.longitude
                                                               zoom:18 bearing:0 viewingAngle:0];
  [self.mainMapView animateToCameraPosition:camera];
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
  // Remove current marker from map
  if (self.currentMarker)
  {
    self.currentMarker.map = nil;
    self.currentMarker = nil;
  }
  
  if (!self.viewInHalf)
  {
    // Reduce map container height
    [self.mapBottomConstraint setConstant:280];
    
    // Unhide everything but the map
    self.myScrollView.hidden = NO;
    self.lblInfo.hidden = YES;
    
    // Set the bool
    self.viewInHalf = YES;
  }
  
  [self.txtPinName resignFirstResponder];
  GMSGeocoder *geocoder = [[GMSGeocoder alloc]init];
  [geocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error){
    self.currentMarker = [[GMSMarker alloc]init];
    self.currentMarker.position = coordinate;
    self.currentMarker.appearAnimation = kGMSMarkerAnimationPop;
    self.currentMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    self.currentMarker.map = self.mainMapView;
    self.currentMarker.title = response.firstResult.thoroughfare;  // Street address
    self.currentMarker.snippet = response.firstResult.locality;    // City
    
    [self.mainMapView animateToLocation:coordinate];
    
    self.lblLatitude.text = [[NSNumber numberWithDouble:self.currentMarker.position.latitude] stringValue];
    self.lblLongitude.text = [[NSNumber numberWithDouble:self.currentMarker.position.longitude] stringValue];
    NSString *addressPart = (response.firstResult.thoroughfare != nil) ? [NSString stringWithFormat:@"%@", response.firstResult.thoroughfare] : @"(No street number)";
    NSString *cityPart = (response.firstResult.locality != nil) ? [NSString stringWithFormat:@",\r%@", response.firstResult.locality] : @",\r(No city/district info)";
    NSString *statePart = (response.firstResult.administrativeArea != nil) ? [NSString stringWithFormat:@",\r%@", response.firstResult.administrativeArea] : @"";
    NSString *addressFormat = [NSString stringWithFormat:@"%@%@%@", addressPart, cityPart, statePart];
    self.lblAddress.text = addressFormat;
    self.currentAddress = addressFormat;
    
    self.btnSavePin.enabled = YES;
    self.bntClear.enabled = YES;
    self.txtPinName.text = @"";
  }];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
  [self.txtPinName resignFirstResponder];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
  [self.txtPinName resignFirstResponder];
}

@end
