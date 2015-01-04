//
//  NSString+Extras.m
//  Shakd
//
//  Created by Zachary Shakked on 1/4/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "NSString+Extras.h"

@implementation NSString (Extras)

- (NSString *)capitalString {
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
}

@end
