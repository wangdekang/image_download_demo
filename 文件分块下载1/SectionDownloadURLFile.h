//
//  SectionDownloadURLFile.h
//  文件分块下载1
//
//  Created by 王德康 on 15/6/10.
//  Copyright (c) 2015年 王德康. All rights reserved.
//


#import <Foundation/Foundation.h>
@class SectionDownloadURLFile;
@class UIImage;

@protocol SectionDownloadURLFile <NSObject>
@optional
- (void)SectionDownloadURLFile:(SectionDownloadURLFile *)downloadFile filshFilePath:(NSString *)path;
- (void)SectionDownloadURLFile:(SectionDownloadURLFile *)downloadFile filshImage:(UIImage *)image;
@end

@interface SectionDownloadURLFile : NSObject
@property(nonatomic, weak) id <SectionDownloadURLFile> delegate;
- (void)downloadWithFile:(NSURL *)url;
@end
