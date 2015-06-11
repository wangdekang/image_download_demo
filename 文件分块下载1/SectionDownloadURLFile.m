//
//  SectionDownloadURLFile.m
//  文件分块下载1
//
//  Created by 王德康 on 15/6/10.
//  Copyright (c) 2015年 王德康. All rights reserved.
//  分块下载文件

// 请求超时时间
#define kTimeOut 2.0f

// 每次请求的大小
#define kBytesPerTimes 2048
#import <UIKit/UIKit.h>
#import "SectionDownloadURLFile.h"
#import "NSString+Password.h"

@interface SectionDownloadURLFile()
// 远程文件大小
@property(nonatomic, assign) long long urlFileSize;
// 远程文件类型
@property(nonatomic, strong) NSString *urlFileType;
// 文件名称
@property(nonatomic, strong) NSString *urlSuggestedFilename;
// 生成文件的路径
@property(nonatomic, strong) NSString *filePath;
// 生成图片Image
@property(nonatomic, strong) UIImage  *cacheImage;
// 远程文件URL
@property(nonatomic, strong) NSURL    *url;
@end

@implementation SectionDownloadURLFile

- (void)downloadWithFile:(NSURL *)url {
    
    // 保存需要数据
    self.url = url;
    
    // 保存文件头信息
    [self getURLFileHeader];
    
    [self downLoadFileWithUrl:url];
}


- (UIImage *)cacheImage {
    if (_cacheImage == nil) {
        _cacheImage = [UIImage imageWithContentsOfFile:self.filePath];
    }
    return _cacheImage;
}

- (NSString *)filePath {
    if (_filePath == nil) {
        NSString *md5Name = [[self.url absoluteString] MD5];
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _filePath = [path stringByAppendingPathComponent:md5Name];
    }
    return _filePath;
}

- (void)getURLFileHeader{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeOut];
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    self.urlSuggestedFilename = response.suggestedFilename;
    self.urlFileType = response.MIMEType;
    self.urlFileSize = response.expectedContentLength;
}

/**
 * 获取文件长度
 * @params NSURL 请求的文件地址
 */
- (long long)getURLFileSize:(NSURL *)url {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeOut];
    request.HTTPMethod = @"HEAD";
    
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return response.expectedContentLength;
}

/**
 * 分块进行文件下载
 * @params NSURL 请求的文件地址
 */
- (void)downLoadFileWithUrl:(NSURL *)url {
    
    // GCD串行异步方法
    dispatch_queue_t q = dispatch_queue_create("download.net", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        
        // 1、获取文件大小
        long long fileSize      = self.urlFileSize;
        long long localFileSize = [self getFileSize];
        
        if (fileSize == localFileSize) {

            [self callDelegate];
            return;
        }
        
        
        // 开始字节数
        long long fromByte = 0;
        
        // 结束字节数
        long long toByte = 0;
        
        // 2、分段下载
        while (fileSize > kBytesPerTimes) {
            
            // 计算当前段的结束字节
            toByte = fromByte + kBytesPerTimes - 1;
            
            [self downloadDataRangeFile:url fromByte:fromByte toByte:toByte];
            
            // 当前大小减少
            fileSize -= kBytesPerTimes;
            
            // 下一次起始字节
            fromByte += kBytesPerTimes;
        }
        
        // 下载剩余字节数
        [self downloadDataRangeFile:url fromByte:fromByte toByte:fromByte + fileSize - 1];
        
    });

}

- (void)downloadDataRangeFile:(NSURL *)url fromByte:(long long)fromByte toByte:(long long)toByte {
    // 设置忽略本地缓存
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeOut];
    
    // 设置请求头,获取数据的区间
    NSString *range = [NSString stringWithFormat:@"Bytes=%lld-%lld", fromByte, toByte];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    [self appendData:data];
}

- (void)appendData:(NSData *)data {
    
    NSFileHandle *fp = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    // 如果文件存在，判断大小,写入
    if (!fp) {
        [data writeToFile:self.filePath atomically:YES];
    } else {
        [fp seekToEndOfFile];
        [fp writeData:data];
        [fp closeFile];
    }
    
    // 数据下载完成
    long long localFileSize = [self getFileSize];
    if (self.urlFileSize == localFileSize) {
        [self callDelegate];
    }
    
}

// 返回文件大小
- (long long)getFileSize {
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
    return [dict[NSFileSize] longLongValue];
}

// 调用代理方法,注意在主线程回调，否则图片显示不出来
- (void)callDelegate {
   
  dispatch_async(dispatch_get_main_queue(), ^{
      if ([self.delegate respondsToSelector:@selector(SectionDownloadURLFile:filshFilePath:)]) {
          [self.delegate SectionDownloadURLFile:self filshFilePath:self.filePath];
      }
      
      if ([self.delegate respondsToSelector:@selector(SectionDownloadURLFile:filshImage:)]) {
          [self.delegate SectionDownloadURLFile:self filshImage:self.cacheImage];
      }
  });
}

@end
