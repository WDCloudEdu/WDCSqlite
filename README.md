# WDCSqlite

[![CI Status](https://img.shields.io/travis/xiongwei/WDCSqlite.svg?style=flat)](https://travis-ci.org/xiongwei/WDCSqlite)
[![Version](https://img.shields.io/cocoapods/v/WDCSqlite.svg?style=flat)](https://cocoapods.org/pods/WDCSqlite)
[![License](https://img.shields.io/cocoapods/l/WDCSqlite.svg?style=flat)](https://cocoapods.org/pods/WDCSqlite)
[![Platform](https://img.shields.io/cocoapods/p/WDCSqlite.svg?style=flat)](https://cocoapods.org/pods/WDCSqlite)

有时候我们需要将model保存到本地数据库中。使用ORM框架可以让我们免于编写繁琐的sql语句，增强代码可读性。还能让我们免于关注建表、表字段修改、旧数据迁移等细节，更专注于业务逻辑的处理。WDCSqlilte是一个轻量级的ORM框架，可以应对基本的数据库需求。

## Simple Use

首先, 我们需要建立model。比如下面：

```objc
///注：本ORM框架不支持保存自定义类型属性，不支持保存装有自定义类型对象的NSArray,NSDictionary属性
@interface WDCPerson : NSObject

@property (nonatomic, copy) NSString *idCard;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) float height;
@property (nonatomic, strong) NSArray<NSString *> *tagArray;
@property (nonatomic, strong) NSDictionary *extraDict;
@property (nonatomic, strong) NSData *customData;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSDate *importantDate;

@end
```

> `tips: 本框架不支持保存自定义类型属性，不支持保存装有自定义类型对象的NSArray,NSDictionary属性(如果有这类属性，会忽略保存)`

本框架默认保存model中所有的成员变量，如果想要忽略部分成员变量，在model中实现以下方法：

```objc
///返回建表时需要忽略的成员变量名
+ (NSArray<NSString *> *)ignoredColumnNames{
///数据库不存储age、height属性
return @[@"age", @"height"];
}
```

当model的成员变量列表发生了变化，下次进行插入数据操作时，会自动对表结构进行更新，并且将旧数据迁移到新的表结构中。数据迁移时，新表中某个字段的内容默认从旧表中同名的字段获取，如果有字段改名的情况，在model中实现以下方法：

```objc
///新表字段名与旧表字段名的对映关系（用于字段改名时数据迁移）
+ (NSDictionary *)newNameToOldNameDic{
///模型中的原oldAge属性改名为age,那么需要在该字典中添加本键值对。下次插入数据时，数据库表自动更新，迁移旧数据时会将原表中oldAge字段的内容赋值给新表中的age字段。
return @{@"oldAge": @"age"};
}
```

然后，我们可以将model插入到数据库（表不存在时会自动建表）：

```objc
WDCPerson *insertPerson = [self createOnePerson];
[WDCSqliteAPI insertModel:insertPerson uid:nil completionHandler:^(BOOL res) {
NSLog(@"插入%@%@", insertPerson, res?@"成功":@"失败");
}];
```

> `tips: uid:不同用户的数据存放在不同的db里，如"zhangsan.db"(如果传nil则在common.db中进行操作)`


批量插入数据接口（框架内部使用了准备语句和显式事务，性能十分优秀）：

```objc
NSMutableArray<WDCPerson *> *insertPersons = [NSMutableArray array];
for(NSInteger i = 0; i < 10000; i ++){
@autoreleasepool {
[insertPersons addObject:[self createOnePerson]];
}
}
CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
///注：不要大批量插入含有图片属性的model
[WDCSqliteAPI insertModels:insertPersons uid:nil completionHandler:^(BOOL res) {
NSLog(@"批量插入%zd条数据%@, 消耗时间%lf", insertPersons.count, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
}];
```

然后，我们可以查询数据库中符合条件的model集合：

```objc
CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
[WDCSqliteAPI queryModels:[WDCPerson class] uid:nil condition:^(WDCSqliteConditionMaker *maker) {
///注：(name = '老'野'猪' and age > 18) or (height < 170) order by height asc limit 0, 10
maker.begin.prop(@"name").equalTo(@"老'野'猪").and.prop(@"age").moreThan(@(18)).end();
maker.begin.prop(@"height").lessThan(@(170)).end();
maker.begin.orderBy(@"height", YES).limit(0, 2000).end();
} completionHandler:^(NSArray *models) {
NSLog(@"查询到%zd条数据，消耗时间%lf", models.count, CFAbsoluteTimeGetCurrent()-startTime);
self.personArray = [models mutableCopy];
[self.resultTableView reloadData];
}];
```

maker是一个用于构造数据库查询条件的对象，使用时需要注意：
* 1.每行代码构造一个子条件，子条件间是'或'的关系(orderBy、limit除外)
* 2.每行代码以begin开头，以end()结尾，注意结尾一定不要忘记写end(),不然这行条件就无法生效了
* 3.如果要加orderBy、limit条件，一定要加到最后一行


其实本质上就是构造了一条sql条件语句，为了封装的安全性才暴露的这种形式的接口。考虑到这种形式无论从易用性还是可读性都不如直接写sql条件语句，我也保留了直接传sql条件语句的接口：

```objc
CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
[WDCSqliteAPI queryModels:[WDCPerson class] whereStr:@"(name = '老'野'猪' and age > 18) or (height < 170) order by height asc limit 0, 10" uid:nil completionHandler:^(NSArray *models) {
NSLog(@"查询到%zd条数据，消耗时间%lf", models.count, CFAbsoluteTimeGetCurrent()-startTime);
self.personArray = [models mutableCopy];
[self.resultTableView reloadData];
}];
```

> `tips: 不要传奇奇怪怪的字符串进来`


最后，我们把查询出来的model对象从数据库中删除：

```objc
CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
NSArray<WDCPerson *> *deletedPersons = [self.personArray subarrayWithRange:NSMakeRange(0, self.personArray.count/2)];
[WDCSqliteAPI deleteModels:deletedPersons uid:nil completionHandler:^(BOOL res) {
NSLog(@"删除%zd条数据%@ 消耗时间%lf", deletedPersons.count, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
}];
```

> `tips: 只能删查询出来的model对象`

也可以按条件删除数据库中的model：

```objc
CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
[WDCSqliteAPI deleteModels:[WDCPerson class] uid:nil condition:^(WDCSqliteConditionMaker *maker) {
maker.begin.prop(@"name").equalTo(@"老'野'猪").and.prop(@"age").moreThan(@(18)).end();
maker.begin.prop(@"height").lessThan(@(170)).end();
maker.begin.orderBy(@"height", YES).limit(0, 2000).end();
} completionHandler:^(BOOL res) {
NSLog(@"删除%@ 消耗时间%lf", res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
}];
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WDCSqlite is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WDCSqlite'
```

## Author

xiongwei, xiongwei@wdcloud.cc

## License

WDCSqlite is available under the MIT license. See the LICENSE file for more info.
