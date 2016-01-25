//
//  EffectItem.h
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-12-02.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EffectItem : NSObject

@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) UIImage   *image;
@property                     CGFloat    value;
@property                     CGFloat    default_value;
@property                     CGFloat    min_value;
@property                     CGFloat    max_value;

@end
