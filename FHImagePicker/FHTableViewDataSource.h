//
//  FHTableViewDataSource.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ConfigBlock)(UITableViewCell * _Nonnull cell, id _Nonnull item);

NS_ASSUME_NONNULL_BEGIN

@interface FHTableViewDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, strong) NSMutableArray *items;

///singleSection 为YES 则只有设置items有效，如果为NO,则只有设置groups有效
+ (instancetype)datasourceWithCellIdentifier:(NSString *)identifier
                               mulitSection:(BOOL)isMulitSection
                          configureCellBlock:(ConfigBlock)configureCellBlock;

@end

NS_ASSUME_NONNULL_END
