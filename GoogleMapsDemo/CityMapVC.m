//
//  CityMapVC.m
//  GoogleMapsDemo
//
//  Created by Akshay Bharath on 10/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "CityMapVC.h"

@interface CityMapVC ()

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSURLSession *markerSession;
@property (strong, nonatomic) NSArray *steps;

@end

@implementation CityMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize NSURLRequest object for incoming network requests
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                    diskCapacity:10 * 1024 * 1024
                                                        diskPath:@"MarkerData"];
    self.markerSession = [NSURLSession sessionWithConfiguration:config];
    
    // iOS 8 workaround to get current location
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.729451 longitude:-73.992041 zoom:14 bearing:0 viewingAngle:0];
    self.mapView = [GMSMapView mapWithFrame:self.mapContainerView.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES; // Doesnt work in iOS 8 yet
    self.mapView.delegate = self;
    
    // Address label stuff
    self.lblAddress.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAddress.numberOfLines = 4;
    
    // Set min and max zoom
    [self.mapView setMinZoom:8 maxZoom:18];
    
    // Set up the markers
    [self setupMarkers];
    
    // Add views to main view
    [self.mapContainerView addSubview:self.mapView];
    self.mapContainerView.frame = CGRectMake(0, 45, self.mapContainerView.frame.size.width, self.mapContainerView.frame.size.height);
    [self.view addSubview:self.mapContainerView];
    [self.view addSubview:self.myScrollView];
    
    // Gesture recognizer to hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Hide top status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    marker1.map = nil;
    
    // Create Freedom Tower marker
    GMSMarker *marker2 = [[GMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake(40.713008, -74.013169);
    marker2.title = @"Freedom Tower";
    marker2.snippet = @"Nuff' said.";
    marker2.appearAnimation = kGMSMarkerAnimationPop;
    marker2.map = nil;
    
    // Create Otto's marker
    GMSMarker *marker3 = [[GMSMarker alloc]init];
    marker3.position = CLLocationCoordinate2DMake(40.729125, -73.987529);
    marker3.title = @"Otto's Tacos";
    marker3.snippet = @"Best tacos in the city.";
    marker3.appearAnimation = kGMSMarkerAnimationPop;
    marker3.map = nil;
    
    // Create Halal Guys marker
    GMSMarker *marker4 = [[GMSMarker alloc]init];
    marker4.position = CLLocationCoordinate2DMake(40.761788, -73.979084);
    marker4.title = @"Halal Guys";
    marker4.snippet = @"Late night food.";
    marker4.appearAnimation = kGMSMarkerAnimationPop;
    marker4.map = nil;
    
    self.myMarkers = [NSMutableSet setWithObjects:marker1, marker2, marker3, marker4, nil];
    
    [self drawAllMarkers];
}

// Draw on map
- (void)drawMarker:(GMSMarker *)marker
{
    if (!marker.map)
    {
        marker.map = self.mapView;
    }
}

// Draw markers on the map
- (void)drawAllMarkers
{
    for (GMSMarker *m in self.myMarkers)
    {
        [self drawMarker:m];
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
    snippet.frame = CGRectMake(14, 42, 175, 16);
    snippet.text = marker.snippet;
    snippet.textColor = [UIColor greenColor];
    [infoWindow addSubview:snippet];
    
    return infoWindow;
}

// Create marker where user long presses on map
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.txtPinName resignFirstResponder];
    GMSGeocoder *geocoder = [[GMSGeocoder alloc]init];
    [geocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error){
        GMSMarker *marker = [[GMSMarker alloc]init];
        marker.position = coordinate;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = nil;
        marker.title = response.firstResult.thoroughfare;  // Street address
        marker.snippet = response.firstResult.locality;    // City

        [self drawMarker:marker];
        
        self.lblLatitude.text = [[NSNumber numberWithDouble:marker.position.latitude] stringValue];
        self.lblLongitude.text = [[NSNumber numberWithDouble:marker.position.longitude] stringValue];
        NSString *addressFormat = [NSString stringWithFormat:@"%@,\n%@,\n%@", response.firstResult.thoroughfare, response.firstResult.locality, response.firstResult.administrativeArea];
        self.lblAddress.text = addressFormat;
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

@end
