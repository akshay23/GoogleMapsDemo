//
//  PinDetailsTV.h
//  GoogleMapsDemo
//
//  Created by Akshay Bharath on 10/30/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface PinDetailsTV : UITableView

@property (strong, nonatomic) NSMutableArray *myPins;
@property (strong, nonatomic) IBOutlet UITableView *myTable;

@end
