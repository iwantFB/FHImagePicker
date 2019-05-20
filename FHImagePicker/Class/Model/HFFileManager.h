//
//  HFFileManager.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/20.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFFileManager : NSObject

+ (NSString *)avaliableFilePathInCacheForDirName:(NSString *)dirName
                                        fileType:(NSString *)fileType;


@end

NS_ASSUME_NONNULL_END
