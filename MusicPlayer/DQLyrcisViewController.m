//
//  DQLyrcisViewController.m
//  MusicPlayer
//
//  Created by 强 on 15/10/30.
//  Copyright (c) 2015年 强. All rights reserved.
//

#import "DQLyrcisViewController.h"
#import "DQLyrcisCell.h"

@interface DQLyrcisViewController ()

@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic) NSInteger index;

@end

@implementation DQLyrcisViewController

static CGFloat _currentTime = 0;
static CGFloat _nextTime = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
    [self.tableView registerClass:[DQLyrcisCell class] forCellReuseIdentifier:@"cell"];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _times = [[NSMutableArray alloc] init];
        _words = [[NSMutableArray alloc] init];
        _index = 0;
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _times.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DQLyrcisCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0 || indexPath.section >= _times.count+1) {
        cell.textLabel.text = @"";
        return cell;
    }
    [cell setLyrcis:_words[indexPath.section - 1]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section >= _times.count+1) {
        return self.tableView.frame.size.height / 2;
    }
    return 45;
}

- (void)loadLyrics:(NSString *)title
{
    _currentTime = _nextTime = 0;
    if (_times.count >0 || _words.count >0) {
        [_times removeAllObjects];
        [_words removeAllObjects];
    }
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:title ofType:@"lrc"]];
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *sepArray = [content componentsSeparatedByString:@"["];
    for (int i = 1; i < sepArray.count; i ++) {
        //有两个元素，一个是时间，一个是歌词
        NSArray *arr = [sepArray[i] componentsSeparatedByString:@"]"];
        
//        [_times addObject:arr[0]];
        [_times addObject:@([self transferStringToTime:arr[0]])];
        if (arr.count == 1) {
            [_words addObject:@""];
        }
        [_words addObject:arr[1]];
    }
    [self.tableView reloadData];
}



//将字符串XX:XX转化成时间
- (CGFloat ) transferStringToTime:(NSString *)time
{
    NSArray *arr = [time componentsSeparatedByString:@":"];
    return [arr[0] doubleValue]*60+[arr[1] doubleValue];
}

//将时间转换成字符串xx:xx格式
- (NSString *)transferTimeToString:(CGFloat)time
{
    return [NSString stringWithFormat:@"%.2d:%.2d", (int)(time/60),(int)time%60];
}


- (void)syncLyrics:(CGFloat)time
{
    NSInteger index = [self findIndex:time];
    if (index < 0) {
        return;
    }
//    NSLog(@"%f %@ %@", time, self.times[index],self.times[index+1]);
    if (self.index == index) {
        [self changeLycrisColor:time index:index];
    }
    else
    {
        [self changeLycrisColor:time index:index];
        [self resetCellWithIndex:index];
        

        self.index = index;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.index+1 ] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)resetCellWithTime:(CGFloat)time
{
    NSInteger index = [self findIndex:time];
    if (index < 0) {
        return;
    }
    [self resetCellWithIndex:index + 1];
}

- (void)resetCellWithIndex:(NSInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
    DQLyrcisCell *cell = (DQLyrcisCell *)[self.tableView cellForRowAtIndexPath:path];;
    [cell resetLayer];
}
///
- (NSInteger)findIndex:(CGFloat)time
{
    if (_times.count <= 1) {
        return -1;
    }
//    比较当前歌词时间和下句歌词时间
//    处于两者之间就是还没到下句词，直接返回原下标
//    如果不在两者之间，那就二分近似查找出相应的下标，
//    这种情况可以解决时间相差非常大的问题
    if (time >= _currentTime && time < _nextTime) {
        return self.index;
    }
    NSInteger low = 0, high = _times.count - 1;
    while (low <= high) {
        NSInteger mid = (low + high)/2;
        if ([self.times[mid] doubleValue] == time) {
            return mid;
        } else if([self.times[mid] doubleValue] > time)
        {
            high = mid - 1;
        } else low =  mid+1;
    }
    if (high < 0) {
        return -1;
    }
    _currentTime = [_times[high] doubleValue];
    if (high >= _times.count-1) {
        _nextTime = _currentTime;
    }
    else _nextTime = [_times[high+1] doubleValue];
    return high;
}

- (void)changeLycrisColor:(CGFloat)time index:(NSInteger)index
{
    //计算这行歌词的时间距离下一行歌词的时间
    CGFloat totalTime =_nextTime - _currentTime;
    if (totalTime == 0) {
        NSLog(@"error");
        return ;
    }
//    计算当前歌词进行时间占歌词时间的比例
    CGFloat hasPlayTime = time - _currentTime;
//    当前已经播放的比例
    CGFloat ratio =  hasPlayTime / totalTime;
    
    NSLog(@"ratio:%f", ratio);
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index+1];
    DQLyrcisCell *cell = (DQLyrcisCell *)[self.tableView cellForRowAtIndexPath:path];
    [cell setContentWithRatio:ratio];
//    [cell setNeedsLayout];
}




@end
