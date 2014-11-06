//
//  MyPin.m
//  GoogleMapsDemo
//
//  Created by Akshay Bharath on 10/31/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "MyPin.h"

@implementation MyPin

- (id)initWithDetails:(NSString *)name latitude:(NSNumber *)lat longitude:(NSNumber *)longi address:(NSString *)theAddress
{
    self.name = name;
    self.latitude = lat;
    self.longitude = longi;
    self.address = theAddress;
    self.dateCreated = [NSDate date];

    return self;
}

@end
