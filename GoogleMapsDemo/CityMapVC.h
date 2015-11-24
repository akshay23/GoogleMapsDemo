//
//  CityMapVC.h
//  MyFavPins
//
//  Created by Akshay Bharath on 10/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "GlobalData.h"
#import "MyPin.h"
#import "SavedPinsTVC.h"

@interface CityMapVC : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet GMSMapView *mainMapView;
@property (strong, nonatomic) IBOutlet UIView *tableContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtPinName;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnSavePin;
@property (strong, nonatomic) IBOutlet UIButton *bntClear;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) IBOutlet UILabel *lblPinNameTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitudeTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitudeTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblAddressTitle;


- (IBAction)SavePin:(id)sender;
- (IBAction)ClearInfo:(id)sender;

@end

