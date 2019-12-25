//
//  WDCPerson.h
//  WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/6.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

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
