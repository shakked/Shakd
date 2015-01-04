//
//  UIView+Borders.h
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Borders)

- (void)addUpperBorder:(float)thickness withColor:(UIColor *)color;
- (void)addLowerBorder:(float)thickness withColor:(UIColor *)color;
- (void)addRightBorder:(float)thickness withColor:(UIColor *)color;
- (void)addLeftBorder:(float)thickness withColor:(UIColor *)color;

@end
