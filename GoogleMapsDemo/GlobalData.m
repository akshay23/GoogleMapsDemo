//
//  GlobalData.m
//  MyFavPins
//
//  Created by Akshay Bharath on 10/30/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData

@synthesize mainStoryboard;

static GlobalData *instance;

+ (GlobalData *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [GlobalData new];
        }
    }
    return instance;
}

+ (BOOL)stringIsNilOrEmpty:(NSString*)aString
{
    return !(aString && aString.length);
}

@end
