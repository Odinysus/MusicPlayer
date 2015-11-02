//
//  DQLyrcisCell.m
//  MusicPlayer
//
//  Created by 强 on 15/11/1.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import "DQLyrcisCell.h"

@interface DQLyrcisCell ()

@property (nonatomic) CGFloat start;
@property (nonatomic) CGFloat wordLenght;

@end

@implementation DQLyrcisCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         _bottomLayer = [CALayer layer];
        _topLayer = [CALayer layer];
        _textLayer = [CATextLayer layer];
        
        _bottomLayer.backgroundColor = [UIColor whiteColor].CGColor;
        
        _topLayer.backgroundColor = [UIColor greenColor].CGColor;
        [_bottomLayer addSublayer:_topLayer];
        [self.layer addSublayer: _bottomLayer];
        
        _textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        _textLayer.fontSize = 17;

        _bottomLayer.mask = _textLayer;


           }
    return self;
}



- (void)setLyrcis:(NSString *)word
{
    _textLayer.string = word;
    _bottomLayer.frame = CGRectMake(0, 0, WIDTH, self.frame.size.height);
    _textLayer.frame = _bottomLayer.bounds;
    
    self.wordLenght = [self.textLayer.string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}].width;
    self.start = (WIDTH - self.wordLenght) / 2;
    CGRect rect = CGRectMake(self.start,0, 0, self.frame.size.height);
    _topLayer.frame = rect;

}

- (void)setContentWithRatio:(CGFloat)ratio
{
    CGRect frame = _topLayer.frame;
    
    [CATransaction begin];
    frame.size.width = roundf(self.wordLenght * (ratio + 0.2));
    _topLayer.frame = frame;
    [CATransaction setAnimationDuration:0.03];
    [CATransaction commit];

}

- (void)resetLayer
{
    CGRect rect = self.topLayer.frame;
    rect.size.width = 0;
    self.topLayer.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
