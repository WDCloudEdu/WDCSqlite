//
//  WDCPerson.m
//  WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/6.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import "WDCPerson.h"

@implementation WDCPerson

/////返回建表时需要忽略的成员变量名
//+ (NSArray<NSString *> *)ignoredColumnNames{
//    ///数据库不存储age、height属性
//    return @[@"age", @"height"];
//}

/////新表字段名与旧表字段名的对映关系（用于字段改名时数据迁移）
//+ (NSDictionary *)newNameToOldNameDic{
//    ///模型中的原oldAge属性改名为age,那么需要在该字典中添加本键值对。下次插入数据时，数据库表自动更新，迁移旧数据时会将原表中oldAge字段的内容赋值给新表中的age字段。
//    return @{@"oldAge": @"age"};
//}
@end
