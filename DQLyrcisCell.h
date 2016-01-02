//
//  DQLyrcisCell.h
//  MusicPlayer
//
//  Created by 强 on 15/11/1.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WIDTH     [UIScreen mainScreen].bounds.size.width
#define HEIGHT     [UIScreen mainScreen].bounds.size.height


@interface DQLyrcisCell : UITableViewCellB

@property (nonatomic, strong) CALayer *bottomLayer;
@property (nonatomic, strong) CALayer *topLayer;
@property (nonatomic, strong) CATextLayer *textLayer;

- (void)setLyrcis:(NSString *)word;
- (void)setContentWithRatio:(CGFloat)ratio;
- (void)resetLayer;
@end
