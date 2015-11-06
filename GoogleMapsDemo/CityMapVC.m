//
//  CityMapVC.m
//  MyFavPins
//
//  Created by Akshay Bharath on 10/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CityMapVC.h"

@interface CityMapVC ()

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
  
  [self.view setAutoresizesSubviews:YES];
  
  // Get current location
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
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
  
  // Initialize google map view with camera position
  self.mapContainerView.frame = CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 80);
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.729451 longitude:-73.992041 zoom:16 bearing:0 viewingAngle:0];
  self.mapView = [GMSMapView mapWithFrame:self.mapContainerView.bounds camera:camera];
  self.mapView.mapType = kGMSTypeNormal;
  self.mapView.myLocationEnabled = YES;
  self.mapView.settings.myLocationButton = YES; // Doesnt work in iOS 8 yet
  self.mapView.delegate = self;
  
  // Address label and button stuff
  self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
  self.lblAddress.numberOfLines = 4;
  self.btnSavePin.layer.cornerRadius = 4;
  self.btnSavePin.layer.borderWidth = 1;
  self.btnSavePin.layer.borderColor = [UIColor blueColor].CGColor;
  self.bntClear.layer.cornerRadius = 4;
  self.bntClear.layer.borderWidth = 1;
  self.bntClear.layer.borderColor = [UIColor blueColor].CGColor;
  self.btnSavePin.enabled = NO;
  self.bntClear.enabled = NO;
  self.appDelegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [self.appDelegate managedObjectContext];
  
  // Add action for Done button
  [self.txtPinName addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
  
  // Storyboard
  if (![GlobalData getInstance].mainStoryboard)
  {
    // Instantiate new main storyboard instance
    [GlobalData getInstance].mainStoryboard = self.storyboard;
    NSLog(@"mainStoryboard instantiated");
  }
  self.savedPinsTVC = [[GlobalData getInstance].mainStoryboard instantiateViewControllerWithIdentifier:@"savedPinsTVC"];
  self.savedPinsTVC.delegate = self;
  
  // Set min and max zoom
  [self.mapView setMinZoom:8 maxZoom:18];
  
  // Set up the markers
  [self setupMarkers];
  
  // Add views to main view
  [self.mapContainerView addSubview:self.mapView];
  [self.view addSubview:self.mapContainerView];
  [self.view addSubview:self.myScrollView];
  self.myScrollView.hidden = YES;
  
  // Gesture recognizer to hide keyboard
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.view addGestureRecognizer:tap];
  
  // Add bar button to nav bar
  UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"View Saved Pins" style:UIBarButtonItemStylePlain target:self action:@selector(ViewSavedPins)];
  self.navigationItem.rightBarButtonItem = right;
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

// Create markers
- (void)setupMarkers
{
  // Create MSG marker
  GMSMarker *marker1 = [[GMSMarker alloc]init];
  marker1.position = CLLocationCoordinate2DMake(40.750382, -73.993285);
  marker1.title = @"Madison Square Garden";
  marker1.snippet = @"Where the Knicks play.";
  marker1.appearAnimation = kGMSMarkerAnimationPop;
  marker1.map = self.mapView;
  
  // Create Freedom Tower marker
  GMSMarker *marker2 = [[GMSMarker alloc]init];
  marker2.position = CLLocationCoordinate2DMake(40.713008, -74.013169);
  marker2.title = @"Freedom Tower";
  marker2.snippet = @"Nuff' said.";
  marker2.appearAnimation = kGMSMarkerAnimationPop;
  marker2.map = self.mapView;
  
  // Create Otto's marker
  GMSMarker *marker3 = [[GMSMarker alloc]init];
  marker3.position = CLLocationCoordinate2DMake(40.729125, -73.987529);
  marker3.title = @"Otto's Tacos";
  marker3.snippet = @"Best tacos in the city.";
  marker3.appearAnimation = kGMSMarkerAnimationPop;
  marker3.map = self.mapView;
  
  // Create Halal Guys marker
  GMSMarker *marker4 = [[GMSMarker alloc]init];
  marker4.position = CLLocationCoordinate2DMake(40.761788, -73.979084);
  marker4.title = @"Halal Guys";
  marker4.snippet = @"Late night food.";
  marker4.appearAnimation = kGMSMarkerAnimationPop;
  marker4.map = self.mapView;
}

// Draw on map
- (void)drawMarker:(GMSMarker *)marker
{
  if (!marker.map)
  {
    marker.map = self.mapView;
  }
}

// Clear marker from map
- (void)clearMarker:(GMSMarker *)marker
{
  marker.map = nil;
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

// Create marker where user long presses on map
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
  // Remove current marker from map
  if (self.currentMarker)
  {
    self.currentMarker.map = nil;
    self.currentMarker = nil;
  }
  
  // Reduce map container height
  self.mapContainerView.frame = CGRectMake(0, 45, self.mapContainerView.frame.size.width, 270);
  self.mapView.frame = self.mapContainerView.bounds;
  
  // Unhide everything but the map
  self.myScrollView.hidden = NO;
  
  [self.txtPinName resignFirstResponder];
  GMSGeocoder *geocoder = [[GMSGeocoder alloc]init];
  [geocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error){
    self.currentMarker = [[GMSMarker alloc]init];
    self.currentMarker.position = coordinate;
    self.currentMarker.appearAnimation = kGMSMarkerAnimationPop;
    self.currentMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    self.currentMarker.map = nil;
    self.currentMarker.title = response.firstResult.thoroughfare;  // Street address
    self.currentMarker.snippet = response.firstResult.locality;    // City
    
    [self drawMarker:self.currentMarker];
    
    self.lblLatitude.text = [[NSNumber numberWithDouble:self.currentMarker.position.latitude] stringValue];
    self.lblLongitude.text = [[NSNumber numberWithDouble:self.currentMarker.position.longitude] stringValue];
    NSString *addressFormat = [NSString stringWithFormat:@"%@,\n%@,\n%@", response.firstResult.thoroughfare, response.firstResult.locality, response.firstResult.administrativeArea];
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

// Move scrollview up
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.myScrollView.contentOffset = CGPointMake(0, textField.frame.origin.y);
}

// Hide keyboard when user taps something
-(void)dismissKeyboard
{
  [self.txtPinName resignFirstResponder];
}

// Add to array
- (IBAction)SavePin:(id)sender
{
  if (![self.txtPinName.text isEqualToString:@""] && self.currentMarker)
  {
    MyPin *pin = [[MyPin alloc] initWithDetails:self.txtPinName.text
                                       latitude:[NSNumber numberWithDouble:self.currentMarker.position.latitude]
                                      longitude:[NSNumber numberWithDouble:self.currentMarker.position.longitude]
                                        address:self.currentAddress];
    
    [self SaveToCoreData:pin];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Pin Saved" message:@"Pin was successfully saved!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    
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
    
    // Increase map container height
    self.mapContainerView.frame = CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 80);
    self.mapView.frame = self.mapContainerView.bounds;
    
    NSLog(@"Pin added to set.");
  }
  else
  {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Pin was NOT saved! Please enter a name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
    
    NSLog(@"Pin was not added.");
  }
}

// Save to CoreData
- (void)SaveToCoreData:(MyPin *)pin
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
  
  // Increase map container height
  self.mapContainerView.frame = CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 80);
  self.mapView.frame = self.mapContainerView.bounds;
}

// Hide keyboard when 'Done' is tapped
- (void)textFieldFinished:(id)sender
{
  [sender resignFirstResponder];
}

// Move to next view to see saved pins
- (void)ViewSavedPins
{
  // Custom transition
  [UIView animateWithDuration:0.75
                   animations:^{
                     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                   }];
  
  [self.savedPinsTVC setManagedObjectContext:self.managedObjectContext];
  [self.txtPinName resignFirstResponder];
  [self.navigationController pushViewController:self.savedPinsTVC animated:YES];
}

@end
