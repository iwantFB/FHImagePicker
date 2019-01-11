//
//  FHTableViewDataSource.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import "FHTableViewDataSource.h"

@interface FHTableViewDataSource ()

@property (nonatomic, copy) ConfigBlock configBlock;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BOOL isMulitSection;

@end

@implementation FHTableViewDataSource

+ (instancetype)datasourceWithCellIdentifier:(NSString *)identifier
                                mulitSection:(BOOL)isMulitSection
                          configureCellBlock:(ConfigBlock)configureCellBlock
{
    FHTableViewDataSource *datasource = [[FHTableViewDataSource alloc] init];
    datasource.isMulitSection = isMulitSection;
    datasource.identifier = identifier;
    datasource.configBlock = configureCellBlock;
    return datasource;
}

#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isMulitSection ? _groups.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_isMulitSection){
        NSArray *sections = _groups[section];
        return sections.count;
    }
    
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    id item = nil;
    if(_isMulitSection){
        NSArray *sections = _groups[indexPath.section];
        item = sections[indexPath.row];
    }else{
        item = _items[indexPath.row];
    }
    if(_configBlock)_configBlock(cell,item);
    return cell;
}



@end
