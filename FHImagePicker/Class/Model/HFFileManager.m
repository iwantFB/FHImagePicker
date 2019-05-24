//
//  HFFileManager.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/20.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFFileManager.h"

@implementation HFFileManager

+ (NSString *)avaliableFilePathInCacheForDirName:(NSString *)dirName
                                        fileType:(NSString *)fileType
{
    NSString *cacheDicName = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Cache"];
    dirName = [cacheDicName stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:cacheDicName]){
        NSError *error;
        [fileManager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:&error];
        if(error)return nil;
    }
    
    NSDate *date = [NSDate date];
    //强转数据
    int ts = date.timeIntervalSince1970;
    NSString *trailName = [NSString stringWithFormat:@"movie_%d.%@",ts,fileType];
    NSString *fileName = [dirName stringByAppendingPathComponent:trailName];
    
    return fileName;
}

@end
