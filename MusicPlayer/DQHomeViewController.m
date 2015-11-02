//
//  DQHomeViewController.m
//  MusicPlayer
//
//  Created by 强 on 15/10/30.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import "DQHomeViewController.h"
#import "DQSlider.h"
#import "DQLyrcisViewController.h"

#define WIDTH     [UIScreen mainScreen].bounds.size.width
#define HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface DQHomeViewController () <AVAudioPlayerDelegate>
//控件
//音量活动
@property (nonatomic, strong) DQSlider *soundSlider;
//播放进度条
@property (nonatomic, strong) DQSlider *progressSlider;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) DQLyrcisViewController *lyrcisVC;
//状态变量
//当前播放第几首歌曲
@property (nonatomic) NSInteger currentMusic;
//当前是否正在播放
@property (nonatomic, getter=isPlayed) BOOL played;
//歌曲播放模式
@property (nonatomic) AVPlayMode mode;
//当前音量
@property (nonatomic) CGFloat volume;
//进度条是否正在拖动
@property (nonatomic, getter=isDraging) BOOL draging;

//数据模型
//总歌曲,储存歌曲名字
@property (nonatomic, strong) NSArray *musics;

@property (nonatomic) CGFloat currentTime;
@end

@implementation DQHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _played = NO;
        _mode = AVPlayModeNormal;
        _volume = 0.5;
        _musics = @[@"不再犹豫",@"喜欢你", @"海阔天空"];
        _currentMusic = 0;
        _draging = 0;
    }
    return self;
}

//关闭定时器
- (void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    加载音量
    DQSlider *soundSlider = [[DQSlider alloc] initWithFrame:CGRectMake(30, 30, WIDTH - 60, 30)];
    soundSlider.value = 0.5;
    [soundSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
    [soundSlider setMinimumValueImage:nil];
    [soundSlider setMaximumValueImage:nil];
    [soundSlider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [soundSlider setMinimumTrackImage:nil forState:UIControlStateHighlighted];
    [soundSlider setMinimumTrackTintColor:[UIColor greenColor]];
    [soundSlider setMaximumTrackTintColor:[UIColor grayColor]];
    [self.view addSubview:soundSlider];
    _soundSlider = soundSlider;
    
//  设置背景图片
    self.view.layer.contents = (id)[UIImage imageNamed:@"homePage_default"].CGImage;
    
//   下方控制区域
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 140, WIDTH, 140)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:view];
    
    CGFloat viewWidth = view.frame.size.width;
    CGFloat viewHeight = view.frame.size.height;
//   播放按钮
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth / 2 - 39, viewHeight / 2 -30, 78, 60)];
    [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.adjustsImageWhenHighlighted = NO;
    [view addSubview:playBtn];
    _playBtn = playBtn;
    
//    上一首
    UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth / 2 - 100, viewHeight/2-15,39 ,30 )];
    [preBtn setImage:[UIImage imageNamed:@"aboveMusic"] forState:UIControlStateNormal];
    [preBtn addTarget:self action:@selector(preMusic) forControlEvents:UIControlEventTouchUpInside];
    preBtn.adjustsImageWhenHighlighted = NO;
    [view addSubview:preBtn];
    _preBtn = preBtn;
    
//    下一首
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth / 2 + 61, viewHeight/2-15,39 ,30 )];
    [nextBtn setImage:[UIImage imageNamed:@"nextMusic"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextMusic) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.adjustsImageWhenHighlighted = NO;
    [view addSubview:nextBtn];
    _nextBtn = nextBtn;
    
//     当前播放时间
    _currentTimeLabel = [self createLabelWithFrame:CGRectMake(20, 20, 50, 40)];
    [view addSubview:_currentTimeLabel];
    
//    总时间
    _totalTimeLabel = [self createLabelWithFrame:CGRectMake(viewWidth - 70, 20, 50, 40)];
    [view addSubview:_totalTimeLabel];
    
//    播放进度
    DQSlider *progressSlider = [[DQSlider alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
    [progressSlider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
    [progressSlider setMinimumTrackTintColor:[UIColor greenColor]];
    [progressSlider setMaximumTrackTintColor:[UIColor grayColor]];
    [progressSlider addTarget:self action:@selector(beginDrag) forControlEvents:UIControlEventTouchDragInside];
    [progressSlider addTarget:self action:@selector(ModiefyProgress) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:progressSlider];
    _progressSlider = progressSlider;
    
//    为播放器添加定时器
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(UpdateProgress) userInfo:nil repeats:YES];

    
//    加载歌词
    DQLyrcisViewController *lyrcisVC = [[DQLyrcisViewController alloc] initWithStyle:UITableViewStylePlain];
    lyrcisVC.tableView.frame = CGRectMake(0, 70, WIDTH, HEIGHT - 250);
    _lyrcisVC = lyrcisVC;
    [self.view addSubview:lyrcisVC.tableView];
    [self addChildViewController:lyrcisVC];
    
    //    初始化播放器
    _timer = timer;
    [self initPlayer:self.musics[0]];
    
}

-(UILabel *)createLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label adjustsFontSizeToFitWidth];
    label.textColor = [UIColor whiteColor];
    label.text = @"00:00";
    return label;
}
//初始化播放器,每次跟换歌曲的时候都会初始化
- (void)initPlayer:(NSString *)title
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:title ofType:@"mp3"]];
    if (_player) {
        [_player stop];
        _player = nil;
    }
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.volume = self.volume;
    _player.currentTime = 0;
    _player.delegate = self;
    
    //根据player初始化进度条
    _progressSlider.value = 0;
    _progressSlider.maximumValue = _player.duration;
    _progressSlider.minimumValue = 0;
    
    //加载歌词
    [_lyrcisVC loadLyrics:title];
    [self syncProgress:0];
    _totalTimeLabel.text = [self transferTimeToString:_player.duration];
    [_player prepareToPlay];
    [self PlayOrPause];
    
}

//
//下一首
- (void)nextMusic
{
    switch (self.mode) {
        case AVPlayModeNormal:
            _currentMusic = (_currentMusic+1) % self.musics.count;
            break;
        case AVPlayModeRandom:
            _currentMusic = arc4random() % self.musics.count;
        case AVPlayModeCycle:
            break;
        default:
            break;
    }
    [self initPlayer:self.musics[self.currentMusic]];
    [self syncProgress:0];
    [self PlayOrPause];
}

//上一首
- (void)preMusic
{
    switch (self.mode) {
        case AVPlayModeNormal:
            _currentMusic = (_currentMusic + self.musics.count - 1) % self.musics.count;
            break;
        case AVPlayModeRandom:
            _currentMusic = arc4random() % self.musics.count;
        case AVPlayModeCycle:
            break;
        default:
            break;
    }
    [self initPlayer:self.musics[self.currentMusic]];
    [self syncProgress:0];
    [self PlayOrPause];
}

//播放或者暂停
- (void)PlayOrPause
{
    if (self.isPlayed) {
        [self.player play];
    }
}

//播放的按钮事件
- (void)playMusic:(UIButton *)btn
{
    if (self.isPlayed) {
        [btn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.player pause];
        self.played = NO;
    } else {
        [btn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.player play];
        self.played = YES;
    }
}

//定时器，更新进度条
- (void)UpdateProgress
{
    self.currentTime = self.player.currentTime;
    [self syncProgress:self.player.currentTime];
}

//根据时间,同步歌曲时间,歌词
- (void)syncProgress:(CGFloat)time
{
    self.currentTimeLabel.text = [self transferTimeToString:time];
    if (!self.isDraging) {
    [self.progressSlider setValue:time animated:YES];
    }
    
    //同步歌词
    [self.lyrcisVC syncLyrics:time];
}

#pragma mark - 进度条事件
//更改进度条,改变时间
- (void)ModiefyProgress
{
    self.draging = NO;
    self.player.currentTime = self.progressSlider.value;
    [self.lyrcisVC resetCellWithTime:self.currentTime];
    [self syncProgress:self.progressSlider.value];
}

- (void)beginDrag
{
    self.draging = YES;
}

//将时间转换成字符串xx:xx格式
- (NSString *)transferTimeToString:(CGFloat)time
{
    return [NSString stringWithFormat:@"%.2d:%.2d", (int)(time/60),(int)time%60];
}

//将字符串XX:XX转化成时间
- (CGFloat ) transferStringToTime:(NSString *)time
{
    NSArray *arr = [time componentsSeparatedByString:@":"];
    return [arr[0] doubleValue]+[arr[1] doubleValue];
}



#pragma mark - avaudio delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        NSLog(@"successfully");
        [self nextMusic];
    }
}
@end
