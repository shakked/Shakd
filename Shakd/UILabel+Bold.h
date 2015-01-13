//
//  UILabel+Bold.h
//  Shakd
//
//  Created by Zachary Shakked on 1/12/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Bold)

- (void) boldSubstring: (NSString*) substring;
- (void) boldRange: (NSRange) range;

@end
