//
//  PinDetailsVC.h
//  GoogleMapsDemo
//
//  Created by Akshay Bharath on 11/7/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MyPin.h"

@interface PinDetailsVC : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) MyPin *pinObject;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) IBOutlet UILabel *lblPinName;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UIView *mapContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;

- (IBAction)deletePin:(id)sender;

@end
