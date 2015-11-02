//
//  DQLyrcisViewController.h
//  MusicPlayer
//
//  Created by 强 on 15/10/30.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HEIGHT     [UIScreen mainScreen].bounds.size.height
@interface DQLyrcisViewController : UITableViewController
- (void)resetCellWithIndex:(NSInteger)index;
- (void)loadLyrics:(NSString *)title;
- (void)syncLyrics:(CGFloat)time;
- (void)resetCellWithTime:(CGFloat)time;
@end
