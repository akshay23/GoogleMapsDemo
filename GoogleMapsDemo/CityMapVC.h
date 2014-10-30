//
//  CityMapVC.h
//  GoogleMapsDemo
//
//  Created by Akshay Bharath on 10/17/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PinDetailsTV.h"
#import "GlobalData.h"

@interface CityMapVC : UIViewController <GMSMapViewDelegate>

@property (strong, nonatomic) NSMutableSet *myMarkers;
@property (strong, nonatomic) IBOutlet UIView *mapContainerView;
@property (strong, nonatomic) IBOutlet UIView *tableContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtPinName;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnSavePin;
@property (strong, nonatomic) IBOutlet UIButton *bntClear;

@end

