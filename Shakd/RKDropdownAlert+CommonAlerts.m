//
//  RKDropdownAlert+CommonAlerts.m
//  Shakd
//
//  Created by Zachary Shakked on 1/8/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "RKDropdownAlert+CommonAlerts.h"
#import "NSString+Extras.h"
#import "UIColor+ShakdColors.h"

@implementation RKDropdownAlert (CommonAlerts)

+ (void)error:(NSError *)error {
    NSString *errorMessage = [error userInfo][@"error"];
   [self title:[errorMessage capitalString] backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
    
}

@end
