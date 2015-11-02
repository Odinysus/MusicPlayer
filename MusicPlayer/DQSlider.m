//
//  DQSlider.m
//  MusicPlayer
//
//  Created by 强 on 15/10/30.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import "DQSlider.h"

@implementation DQSlider
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    rect.origin.x-= 30;
    
    rect.size.width+= 60;
    
//    bounds.size.width -=30;
//    bounds.size.height -= 30;
    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value],10,10);
    
}


@end
