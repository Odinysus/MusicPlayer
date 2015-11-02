//
//  DQHomeViewController.h
//  MusicPlayer
//
//  Created by 强 on 15/10/30.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "DQSlider.h"

typedef enum : NSUInteger {
    AVPlayModeNormal,
    AVPlayModeCycle,
    AVPlayModeRandom,
} AVPlayMode;

@interface DQHomeViewController : UIViewController

@end
