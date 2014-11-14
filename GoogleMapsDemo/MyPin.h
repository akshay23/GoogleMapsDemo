//
//  MyPin.h
//  MyFavPins
//
//  Created by Akshay Bharath on 10/31/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPin : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSDate *dateCreated;

- (id)initWithDetails:(NSString *)name latitude:(NSNumber *)lat longitude:(NSNumber *)longi address:(NSString *)theAddress;

@end
