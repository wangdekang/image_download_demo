//
//  ViewController.m
//  文件分块下载1
//
//  Created by 王德康 on 15/6/10.
//  Copyright (c) 2015年 王德康. All rights reserved.
//



#import "ViewController.h"
#import "SectionDownloadURLFile.h"

@interface ViewController ()<SectionDownloadURLFile>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *strUrl = @"http://youhui.live.189.cn/upload/2015/03/27/20150327145607000000_1_51898_79.jpg";
    NSURL *url = [NSURL URLWithString:strUrl];
    
    SectionDownloadURLFile *downloadFile = [[SectionDownloadURLFile alloc] init];
    downloadFile.delegate = self;
    [downloadFile downloadWithFile:url];
}

- (void)SectionDownloadURLFile:(SectionDownloadURLFile *)downloadFile filshFilePath:(NSString *)path {
    NSLog(@"SectionDownloadURLFile:%@", path);
}

- (void)SectionDownloadURLFile:(SectionDownloadURLFile *)downloadFile filshImage:(UIImage *)image {
    self.imageView.image = image;
    NSLog(@"%@", image);
}
@end
