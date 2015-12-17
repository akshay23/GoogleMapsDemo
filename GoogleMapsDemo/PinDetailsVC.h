//
//  PinDetailsVC.h
//  MyFavPins
//
//  Created by Akshay Bharath on 11/7/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FlatUIKit.h"
#import "SavedPinsTVC.h"
#import "MyPin.h"

@interface PinDetailsVC : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MyPin *pinObject;
@property (strong, nonatomic) SavedPinsTVC *delegate;
@property (strong, nonatomic) NSIndexPath *indexPathOfObject;
@property (strong, nonatomic) IBOutlet UITextField *txtPinName;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet FUIButton *btnDelete;
@property (strong, nonatomic) IBOutlet FUIButton *btnSaveChanges;
@property (strong, nonatomic) IBOutlet GMSMapView *mainMapView;

- (IBAction)deletePin:(id)sender;
- (IBAction)saveChanges:(id)sender;

@end
